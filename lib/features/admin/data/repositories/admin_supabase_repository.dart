import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/models/business_hour.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';

String _uuidV4() {
  final r = Random();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  String h(int x) => x.toRadixString(16).padLeft(2, '0');
  final s = b.map(h).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-'
      '${s.substring(16, 20)}-${s.substring(20)}';
}

@LazySingleton(as: AdminRepository)
class AdminSupabaseRepository implements AdminRepository {
  AdminSupabaseRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AdminDashboard> fetchDashboard({
    required String tenantId,
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _client.rpc('get_dashboard_kpis', params: {
      'p_tenant_id': tenantId,
      'p_period_start': start.toUtc().toIso8601String(),
      'p_period_end': end.toUtc().toIso8601String(),
      'p_filter_to_caller_barber': false,
    });
    return AdminDashboard.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<AdminCashReport> fetchCashReport({
    required String tenantId,
    required DateTime start,
    required DateTime end,
  }) async {
    final res =
        await _client.rpc('get_daily_cash_close_report', params: {
      'p_tenant_id': tenantId,
      'p_period_start': start.toUtc().toIso8601String(),
      'p_period_end': end.toUtc().toIso8601String(),
    });
    return AdminCashReport.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<AdminCommissionsReport> fetchCommissions({
    required String tenantId,
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await _client.rpc('get_commissions_report', params: {
      'p_tenant_id': tenantId,
      'p_period_start': start.toUtc().toIso8601String(),
      'p_period_end': end.toUtc().toIso8601String(),
      'p_barber_filter': null,
    });
    return AdminCommissionsReport.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<List<BusinessHour>> fetchBusinessHours({
    required String tenantId,
  }) async {
    final rows = await _client
        .from('business_hours')
        .select('day_of_week, open_time, close_time, is_closed')
        .eq('tenant_id', tenantId)
        .order('day_of_week', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(BusinessHour.fromRow)
        .toList();
  }

  @override
  Future<void> saveBusinessHours({
    required String tenantId,
    required String actorId,
    required List<BusinessHour> hours,
  }) async {
    await _client.rpc('update_tenant_settings', params: {
      'p_tenant_id': tenantId,
      'p_section': 'business_hours',
      'p_patch': {'specs': hours.map((h) => h.toSpec()).toList()},
      'p_actor_id': actorId,
      'p_idempotency_key': _uuidV4(),
    });
  }

  @override
  Future<List<AdminPromotion>> fetchPromotions({
    required String tenantId,
  }) async {
    final rows = await _client
        .from('promotions')
        .select('*')
        .eq('tenant_id', tenantId)
        .filter('deleted_at', 'is', null)
        .order('created_at', ascending: false);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(AdminPromotion.fromRow)
        .toList();
  }

  @override
  Future<void> savePromotion({
    required String tenantId,
    required AdminPromotion promo,
  }) async {
    await _client.rpc('upsert_promotion', params: promo.toParams(tenantId));
  }

  @override
  Future<void> archivePromotion({
    required String tenantId,
    required String promotionId,
  }) async {
    await _client.rpc('archive_promotion', params: {
      'p_promotion_id': promotionId,
      'p_tenant_id': tenantId,
      'p_reason': 'Archivada desde la app',
    });
  }
}
