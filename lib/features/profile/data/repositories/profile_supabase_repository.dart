import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/profile/data/mappers/coupon_mappers.dart';
import 'package:trim_flow/features/profile/data/mappers/profile_mappers.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';
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
        .eq('tenant_id', fallbackTenantId)
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
        .select('id, tenant_id, full_name, phone, specialty, avatar_url, role, is_active, branch_id, hired_at, '
            'branch:branches!branch_id(id, name)')
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
    if (tenantId == null || tenantId.isEmpty) {
      throw const CustomerRowMissingException(
        'No hay tenant resuelto para guardar el perfil del cliente.',
      );
    }
    final fullName = '${input.firstName} ${input.lastName}'.trim();
    // Mutacion via RPC SECURITY DEFINER (ADR-0015): no escribimos la tabla directo.
    await _client.rpc(
      'bootstrap_customer_self',
      params: {
        'p_tenant_id': tenantId,
        'p_full_name': fullName,
        'p_whatsapp': input.phone.isEmpty ? null : '+51${input.phone}',
        'p_birth_date': input.birthDate.isEmpty ? null : input.birthDate,
      },
    );
  }

  @override
  Future<ProfileUpdateInput?> loadKnownCustomerInfo({
    required String authUserId,
  }) async {
    final rows = await _client
        .from('customers')
        .select('full_name, whatsapp, birth_date')
        .eq('auth_user_id', authUserId)
        .not('birth_date', 'is', null)
        .not('whatsapp', 'is', null)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    final row = list.first as Map<String, dynamic>;
    final whatsapp = (row['whatsapp'] as String?) ?? '';
    final phone = whatsapp.startsWith('+51') ? whatsapp.substring(3) : whatsapp;
    final birthDate = (row['birth_date'] as String?) ?? '';
    if (phone.isEmpty || birthDate.isEmpty) return null;
    final fullName = ((row['full_name'] as String?) ?? '').trim();
    final spaceIdx = fullName.indexOf(' ');
    final firstName =
        spaceIdx == -1 ? fullName : fullName.substring(0, spaceIdx);
    final lastName = spaceIdx == -1 ? '' : fullName.substring(spaceIdx + 1).trim();
    return ProfileUpdateInput(
      firstName: firstName.isEmpty ? 'Cliente' : firstName,
      lastName: lastName,
      phone: phone,
      birthDate: birthDate,
    );
  }

  @override
  Future<void> updateStaffProfile({
    required String authUserId,
    required String? tenantId,
    required ProfileUpdateInput input,
  }) async {
    final fullName = '${input.firstName} ${input.lastName}'.trim();
    // Mutacion via RPC SECURITY DEFINER (ADR-0015).
    await _client.rpc(
      'update_staff_self',
      params: {
        'p_full_name': fullName,
        'p_phone': input.phone.isEmpty ? null : input.phone,
      },
    );
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
    // Leemos desde las reservas propias del cliente (RLS lo permite), no desde
    // ledger_entries (solo legible por staff). Citas terminadas/canceladas.
    final rows = await _client
        .from('reservations')
        .select(
          'id, status, start_time, price_at_booking, cancellation_reason, '
          'service:services!service_id(name), '
          'branch:branches!branch_id(name), '
          'barber:profiles!barber_id(full_name)',
        )
        .eq('customer_id', customerId)
        .inFilter('status', ['completed', 'cancelled', 'no_show'])
        .filter('deleted_at', 'is', null)
        .order('start_time', ascending: false)
        .limit(limit);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(PastAppointmentMapper.fromReservationRow)
        .whereType<PastAppointment>()
        .toList();
  }

  @override
  Future<List<CustomerCoupon>> loadCustomerCoupons({
    required String customerId,
  }) async {
    final rows = await _client
        .from('customer_coupons')
        .select(
          'id, unique_code, redeemed_at, valid_until, '
          'promotion:promotions!promotion_id(name, discount_type, discount_value, is_active)',
        )
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(CouponMapper.fromRow)
        .whereType<CustomerCoupon>()
        .toList();
  }
}
