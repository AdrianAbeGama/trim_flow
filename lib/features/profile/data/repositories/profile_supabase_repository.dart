import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/profile/data/mappers/coupon_mappers.dart';
import 'package:trim_flow/features/profile/data/mappers/profile_mappers.dart';
import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

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
    if (user == null || fallbackTenantId.isEmpty) return null;

    // RPC del backend (resuelve por auth.uid() + tenant). Reemplaza la lectura
    // directa de customers.
    try {
      final json = await _client.rpc(
        'get_my_profile',
        params: {'p_tenant_id': fallbackTenantId},
      );
      if (json is! Map<String, dynamic>) return null;
      return CustomerProfileMapper.fromMyProfile(
        json: json,
        authUser: user,
        tenantId: fallbackTenantId,
      );
    } on PostgrestException catch (e) {
      // Cliente sin ficha en esta barberia → sin perfil aqui (no es error).
      if (e.message.contains('customer_not_linked')) return null;
      rethrow;
    }
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
  Future<int> claimProfileByTicket({required String accessCode}) async {
    final res = await _client.rpc(
      'claim_profile_by_ticket',
      params: {'p_access_code': accessCode},
    );
    if (res is Map) {
      final count = res['count'];
      if (count is int) return count;
      final ids = res['linkedTenantIds'];
      if (ids is List) return ids.length;
    }
    return 0;
  }

  @override
  Future<MyReservationsResult> loadMyReservations({
    required String tenantId,
  }) async {
    final json = await _client.rpc(
      'get_my_reservations',
      params: {'p_tenant_id': tenantId},
    );
    if (json is! Map<String, dynamic>) return const MyReservationsResult();
    final upcoming = (json['upcoming'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((r) => ReservationMapper.fromMyReservation(r, tenantId))
        .toList();
    final recent = (json['recent'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PastAppointmentMapper.fromMyReservation)
        .whereType<PastAppointment>()
        .toList();
    return MyReservationsResult(
      upcoming: upcoming,
      recent: recent,
      recentHasMore: (json['recentHasMore'] as bool?) ?? false,
    );
  }

  @override
  Future<List<CustomerCoupon>> loadCustomerCoupons({
    required String tenantId,
  }) async {
    final json = await _client.rpc(
      'get_my_coupons',
      params: {'p_tenant_id': tenantId},
    );
    final list = (json as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CouponMapper.fromMyCoupon)
        .whereType<CustomerCoupon>()
        .toList();
  }
}
