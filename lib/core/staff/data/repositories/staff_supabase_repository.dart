import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/constants/app_roles.dart';
import 'package:trim_flow/core/staff/domain/models/staff_member.dart';
import 'package:trim_flow/core/staff/domain/repositories/staff_repository.dart';

@LazySingleton(as: StaffRepository)
class StaffSupabaseRepository implements StaffRepository {
  final SupabaseClient _client;

  StaffSupabaseRepository(this._client);

  @override
  Future<List<StaffMember>> listActiveBarbers({String? tenantId}) async {
    try {
      final base = _client
          .from('profiles')
          .select('id, full_name, specialty, avatar_url, phone, role, is_active');

      final filtered = (tenantId != null && tenantId.isNotEmpty)
          ? base.eq('tenant_id', tenantId)
          : base;

      final rows = await filtered
          .eq('is_active', true)
          .inFilter('role', AppRoles.accepted)
          .filter('deleted_at', 'is', null)
          .order('full_name', ascending: true);

      return (rows as List).whereType<Map<String, dynamic>>().map((row) {
        return StaffMember(
          id: (row['id'] as String?) ?? '',
          fullName: (row['full_name'] as String?) ?? 'Barbero',
          specialty: row['specialty'] as String?,
          avatarUrl: row['avatar_url'] as String?,
          phone: row['phone'] as String?,
          role: (row['role'] as String?) ?? AppRoles.barber,
          isActive: (row['is_active'] as bool?) ?? true,
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('StaffSupabaseRepository.list error: $e\n$stack');
      return const [];
    }
  }
}
