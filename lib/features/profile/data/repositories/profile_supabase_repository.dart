import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/profile/data/mappers/profile_mappers.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

const List<String> _kActiveReservationStatuses = ['pending', 'confirmed'];

class CustomerRowMissingException implements Exception {
  final String message;
  const CustomerRowMissingException(this.message);
  @override
  String toString() => 'CustomerRowMissingException: $message';
}

class StaffRowMissingException implements Exception {
  final String message;
  const StaffRowMissingException(this.message);
  @override
  String toString() => 'StaffRowMissingException: $message';
}

@LazySingleton(as: ProfileRepository)
class ProfileSupabaseRepository implements ProfileRepository {
  final SupabaseClient _client;

  ProfileSupabaseRepository(this._client);

  @override
  Future<ProfileLoadResult?> loadCustomerProfile({
    required String authUserId,
    required String fallbackTenantId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('customers')
        .select('id, tenant_id, full_name, whatsapp, email, birth_date, points, client_code, is_app_user, last_visit_at')
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    if (row == null) return null;

    return CustomerProfileMapper.fromRow(
      row: row,
      authUser: user,
      fallbackTenantId: fallbackTenantId,
    );
  }

  @override
  Future<ProfileLoadResult?> loadStaffProfile({
    required String authUserId,
    required String fallbackTenantId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('profiles')
        .select('id, tenant_id, full_name, phone, specialty, avatar_url, role, is_active, branch_id, hired_at')
        .eq('id', authUserId)
        .maybeSingle();

    if (row == null) return null;

    return StaffProfileMapper.fromRow(
      row: row,
      authUser: user,
      fallbackTenantId: fallbackTenantId,
    );
  }

  @override
  Future<void> updateCustomerProfile({
    required String authUserId,
    required String? tenantId,
    required ProfileUpdateInput input,
  }) async {
    final fullName = '${input.firstName} ${input.lastName}'.trim();
    final payload = <String, dynamic>{
      'full_name': fullName,
      'whatsapp': input.phone.isEmpty ? null : '+51${input.phone}',
      'birth_date': input.birthDate.isEmpty ? null : input.birthDate,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (tenantId != null && tenantId.isNotEmpty) {
      payload['tenant_id'] = tenantId;
    }

    final updated = await _client
        .from('customers')
        .update(payload)
        .eq('auth_user_id', authUserId)
        .select('id');

    if (updated.isNotEmpty) return;

    if (tenantId == null || tenantId.isEmpty) {
      throw CustomerRowMissingException(
        'No existe fila customer para auth_user_id=$authUserId y no hay tenant_id resuelto. '
        'Se requiere RPC bootstrap_customer_self del backend (ADR-0015).',
      );
    }

    try {
      await _client.from('customers').upsert(
        {
          ...payload,
          'auth_user_id': authUserId,
          'is_app_user': true,
        },
        onConflict: 'tenant_id,auth_user_id',
      );
    } on PostgrestException catch (e) {
      throw CustomerRowMissingException(
        'Upsert customer rechazado por RLS (${e.code}): ${e.message}. '
        'La policy customers_insert_staff exige get_staff_tenant_id() = tenant_id, '
        'que es NULL para clientes B2C. Se requiere RPC bootstrap_customer_self del backend.',
      );
    }
  }

  @override
  Future<void> updateStaffProfile({
    required String authUserId,
    required String? tenantId,
    required ProfileUpdateInput input,
  }) async {
    final fullName = '${input.firstName} ${input.lastName}'.trim();
    final payload = <String, dynamic>{
      'full_name': fullName,
      'phone': input.phone.isEmpty ? null : input.phone,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (tenantId != null && tenantId.isNotEmpty) {
      payload['tenant_id'] = tenantId;
    }

    final updated = await _client
        .from('profiles')
        .update(payload)
        .eq('id', authUserId)
        .select('id');

    if (updated.isEmpty) {
      throw StaffRowMissingException(
        'No existe fila profile para id=$authUserId. '
        'El trigger handle_new_auth_user no la creo (falta raw_app_meta_data.user_type=staff).',
      );
    }
  }

  @override
  Future<List<Reservation>> loadActiveReservations({
    required String customerId,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final rows = await _client
        .from('reservations')
        .select(
          'id, tenant_id, branch_id, service_id, barber_id, '
          'start_time, end_time, status, price_at_booking, '
          'service:services!service_id(id, name, duration_minutes, price_pen, category_id), '
          'branch:branches!branch_id(id, name, address_line), '
          'barber:profiles!barber_id(id, full_name, avatar_url, specialty)',
        )
        .eq('customer_id', customerId)
        .inFilter('status', _kActiveReservationStatuses)
        .filter('deleted_at', 'is', null)
        .gte('start_time', nowIso)
        .order('start_time', ascending: true);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(ReservationMapper.fromRow)
        .toList();
  }

  @override
  Future<List<PastAppointment>> loadAppointmentHistory({
    required String customerId,
    int limit = 50,
  }) async {
    final rows = await _client
        .from('ledger_entries')
        .select(
          'id, occurred_at, amount_value, payment_method, '
          'service_name_snapshot, discount_applied, coupon_code_snapshot, '
          'transaction_type, barber_id, reservation_id, '
          'barber:profiles!barber_id(id, full_name), '
          'reservation:reservations!reservation_id(id, status, cancellation_reason, branch_id, branch:branches!branch_id(id, name))',
        )
        .eq('customer_id', customerId)
        .order('occurred_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(PastAppointmentMapper.fromLedgerRow)
        .whereType<PastAppointment>()
        .toList();
  }
}
