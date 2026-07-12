import 'dart:io';

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
  Future<void> deleteMyAccount() async {
    await _client.rpc('delete_my_account');
  }

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

    final result = StaffProfileMapper.fromRow(
      row: row,
      authUser: user,
      fallbackTenantId: fallbackTenantId,
    );

    // Rol autoritativo via RPC SECURITY DEFINER (resuelve por auth.uid()).
    // Si la RPC falla o devuelve null, se mantiene el role del row (fallback).
    final authoritativeRole = await _fetchMyRole();
    if (authoritativeRole == null) return result;

    return ProfileLoadResult(
      user: result.user.copyWith(role: authoritativeRole),
      loyaltyPoints: result.loyaltyPoints,
      isRewardAvailable: result.isRewardAvailable,
      clientCode: result.clientCode,
      lastVisit: result.lastVisit,
      branchName: result.branchName,
    );
  }

  Future<String?> _fetchMyRole() async {
    try {
      final res = await _client.rpc('get_my_role');
      return (res is String && res.isNotEmpty) ? res : null;
    } catch (_) {
      return null;
    }
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
    final whatsapp = input.phone.isEmpty ? null : '+51${input.phone}';
    final birth = input.birthDate.isEmpty ? null : input.birthDate;
    // Editar via update_customer_profile (contrato B2C: protege campos sensibles
    // y hace inmutable la fecha de nacimiento). Si aun no hay ficha en este
    // tenant, la crea con bootstrap_customer_self (tenant-scoped). ADR-0015.
    try {
      await _client.rpc('update_customer_profile', params: {
        // Requerido por el backend (hotfix tenant_scope): sin esto, un cliente
        // con ficha en varias barberias recibe 'tenant_id_required'.
        'p_tenant_id': tenantId,
        'p_full_name': fullName,
        'p_whatsapp': whatsapp,
        'p_email': null,
        'p_birth_date': birth,
      });
    } on PostgrestException catch (e) {
      if (!e.message.contains('customer_not_found')) rethrow;
      await _client.rpc('bootstrap_customer_self', params: {
        'p_tenant_id': tenantId,
        'p_full_name': fullName,
        'p_whatsapp': whatsapp,
        'p_birth_date': birth,
      });
    }
  }

  @override
  Future<void> updateStaffProfile({
    required String authUserId,
    required String? tenantId,
    required ProfileUpdateInput input,
  }) async {
    final fullName = '${input.firstName} ${input.lastName}'.trim();
    // Mismo formato +51 que el cliente (ver updateCustomerProfile).
    final phone =
        input.phone.isEmpty ? null : _withPeruPrefix(input.phone);
    // Mutacion via RPC SECURITY DEFINER (ADR-0015).
    await _client.rpc(
      'update_staff_self',
      params: {
        'p_full_name': fullName,
        'p_phone': phone,
      },
    );
  }

  String _withPeruPrefix(String phone) =>
      phone.startsWith('+51') ? phone : '+51$phone';

  @override
  Future<void> updateStaffAvatar({required String localImagePath}) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const StaffRowMissingException('unauthenticated');

    final bytes = await File(localImagePath).readAsBytes();
    final ext = _imageExt(localImagePath);
    // Ruta permitida por la policy de storage para staff: media/staff/<uid>/...
    final path = 'staff/$uid/avatar_${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _client.storage.from('media').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _imageMime(ext), upsert: true),
        );
    final url = _client.storage.from('media').getPublicUrl(path);
    await _client.rpc('update_my_avatar', params: {'p_avatar_url': url});
  }

  @override
  Future<void> removeStaffAvatar() async {
    await _client.rpc('update_my_avatar', params: {'p_avatar_url': null});
  }

  // El bucket `media` solo admite jpeg/png/webp; todo lo demas se sube como jpeg
  // (el recorte ya entrega JPEG).
  String _imageExt(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    return (ext == 'png' || ext == 'webp') ? ext : 'jpg';
  }

  String _imageMime(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
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
  Future<ReferralStats> getReferralStats({required String tenantId}) async {
    final res = await _client
        .rpc('get_my_referral_stats', params: {'p_tenant_id': tenantId});
    final m = (res is Map) ? res.cast<String, dynamic>() : const {};
    return ReferralStats(
      code: m['code'] as String?,
      usesCount: (m['usesCount'] as num?)?.toInt() ?? 0,
      maxUses: (m['maxUses'] as num?)?.toInt() ?? 0,
      referredCount: (m['referredCount'] as num?)?.toInt() ?? 0,
      totalEarned: (m['totalEarned'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<String> generateReferralCode({required String tenantId}) async {
    final res = await _client
        .rpc('generate_referral_code', params: {'p_tenant_id': tenantId});
    final m = (res is Map) ? res.cast<String, dynamic>() : const {};
    return (m['code'] as String?) ?? '';
  }

  @override
  Future<String> applyReferralCode({
    required String tenantId,
    required String code,
  }) async {
    final res = await _client.rpc('apply_referral_code',
        params: {'p_tenant_id': tenantId, 'p_code': code});
    final m = (res is Map) ? res.cast<String, dynamic>() : const {};
    return (m['message'] as String?) ?? 'Código aplicado.';
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
