import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/admin/domain/models/admin_commission_config.dart';
import 'package:trim_flow/features/admin/domain/models/admin_customer.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/models/admin_tenant_settings.dart';
import 'package:trim_flow/features/admin/domain/models/business_hour.dart';
import 'package:trim_flow/features/admin/domain/repositories/admin_repository.dart';

double _toD(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

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

  @override
  Future<List<AdminBarberRef>> fetchBarbers({required String tenantId}) async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name')
        .eq('tenant_id', tenantId)
        .eq('role', 'barber')
        .eq('is_active', true)
        .filter('deleted_at', 'is', null)
        .order('full_name', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map((r) => AdminBarberRef(
              id: r['id'] as String,
              name: (r['full_name'] as String?) ?? 'Barbero',
            ))
        .toList();
  }

  @override
  Future<List<CommissionLine>> fetchCommissionLines({
    required String tenantId,
    required String barberId,
  }) async {
    final services = await _client
        .from('services')
        .select('id, name, price_pen, commission_type, commission_value')
        .eq('tenant_id', tenantId)
        .eq('is_active', true)
        .filter('deleted_at', 'is', null)
        .order('display_order', ascending: true);
    final overrides = await _client
        .from('barber_commission_overrides')
        .select('service_id, commission_type, commission_value')
        .eq('tenant_id', tenantId)
        .eq('barber_id', barberId);

    final byService = <String, Map<String, dynamic>>{
      for (final o in (overrides as List).whereType<Map<String, dynamic>>())
        o['service_id'] as String: o,
    };

    return (services as List).whereType<Map<String, dynamic>>().map((s) {
      final sid = s['id'] as String;
      final ov = byService[sid];
      final isOv = ov != null;
      return CommissionLine(
        serviceId: sid,
        serviceName: (s['name'] as String?) ?? 'Servicio',
        price: _toD(s['price_pen']),
        type: (isOv ? ov['commission_type'] : s['commission_type']) as String? ??
            'percentage',
        value: _toD(isOv ? ov['commission_value'] : s['commission_value']),
        isOverride: isOv,
      );
    }).toList();
  }

  @override
  Future<void> saveCommissionOverride({
    required String tenantId,
    required String barberId,
    required String serviceId,
    required String type,
    required double value,
  }) async {
    await _client.rpc('upsert_commission_override', params: {
      'p_tenant_id': tenantId,
      'p_barber_id': barberId,
      'p_service_id': serviceId,
      'p_commission_type': type,
      'p_commission_value': value,
      'p_notes': null,
    });
  }

  @override
  Future<void> deleteCommissionOverride({
    required String tenantId,
    required String barberId,
    required String serviceId,
  }) async {
    await _client.rpc('delete_commission_override', params: {
      'p_tenant_id': tenantId,
      'p_barber_id': barberId,
      'p_service_id': serviceId,
      'p_reason': 'Revertido a comisión por defecto',
    });
  }

  @override
  Future<List<AdminCustomer>> fetchCustomers({required String tenantId}) async {
    final rows = await _client
        .from('customers')
        .select('id, full_name, whatsapp, points, last_visit_at')
        .eq('tenant_id', tenantId)
        .filter('deleted_at', 'is', null)
        .order('full_name', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(AdminCustomer.fromRow)
        .toList();
  }

  @override
  Future<void> adjustCustomerPoints({
    required String tenantId,
    required String customerId,
    required int delta,
    required String reason,
  }) async {
    await _client.rpc('adjust_customer_points', params: {
      'p_tenant_id': tenantId,
      'p_customer_id': customerId,
      'p_delta': delta,
      'p_reason': reason,
      'p_metadata': <String, dynamic>{},
    });
  }

  @override
  Future<String> emitCustomerCoupon({
    required String tenantId,
    required String customerId,
    required String promotionId,
    required String emittedBy,
  }) async {
    final res = await _client.rpc('emit_customer_coupon', params: {
      'p_tenant_id': tenantId,
      'p_customer_id': customerId,
      'p_promotion_id': promotionId,
      'p_emitted_by_profile_id': emittedBy,
    });
    final rows = res as List;
    if (rows.isEmpty) return '';
    final row = rows.first as Map<String, dynamic>;
    return (row['out_unique_code'] as String?) ?? '';
  }

  @override
  Future<AdminTenantSettings> fetchTenantSettings({
    required String tenantId,
  }) async {
    final row = await _client
        .from('tenants')
        .select(
            'name, branding, comeback_reminder_enabled, comeback_reminder_days, comeback_reminder_message_template')
        .eq('id', tenantId)
        .maybeSingle();
    return AdminTenantSettings.fromRow(
        (row ?? const <String, dynamic>{}).cast<String, dynamic>());
  }

  @override
  Future<void> saveTenantGeneral({
    required String tenantId,
    required String actorId,
    required String name,
    required String phone,
    required String address,
    required String email,
  }) async {
    await _client.rpc('update_tenant_settings', params: {
      'p_tenant_id': tenantId,
      'p_section': 'general',
      'p_patch': {
        'name': name,
        'contact': {
          'phone': phone,
          'address_line': address,
          'email': email,
        },
      },
      'p_actor_id': actorId,
      'p_idempotency_key': _uuidV4(),
    });
  }

  @override
  Future<void> saveTenantAutomation({
    required String tenantId,
    required String actorId,
    required bool enabled,
    required int days,
    required String message,
  }) async {
    await _client.rpc('update_tenant_settings', params: {
      'p_tenant_id': tenantId,
      'p_section': 'automation',
      'p_patch': {
        'comeback_reminder_enabled': enabled,
        'comeback_reminder_days': days,
        'comeback_reminder_message_template': message,
      },
      'p_actor_id': actorId,
      'p_idempotency_key': _uuidV4(),
    });
  }

  @override
  Future<void> registerCashAdjustment({
    required String tenantId,
    required double amount,
    required String reasonCode,
    required String idempotencyKey,
    String? reasonText,
  }) async {
    await _client.rpc('register_manual_ledger_adjustment', params: {
      'p_tenant_id': tenantId,
      'p_amount': amount,
      'p_adjustment_reason_code': reasonCode,
      'p_idempotency_key': idempotencyKey,
      'p_adjustment_reason_text': reasonText,
    });
  }
}
