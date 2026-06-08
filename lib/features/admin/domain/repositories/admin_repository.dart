import 'package:trim_flow/features/admin/domain/models/admin_commission_config.dart';
import 'package:trim_flow/features/admin/domain/models/admin_customer.dart';
import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
import 'package:trim_flow/features/admin/domain/models/admin_tenant_settings.dart';
import 'package:trim_flow/features/admin/domain/models/business_hour.dart';

abstract class AdminRepository {
  Future<AdminDashboard> fetchDashboard({
    required String tenantId,
    required DateTime start,
    required DateTime end,
  });

  Future<AdminCashReport> fetchCashReport({
    required String tenantId,
    required DateTime start,
    required DateTime end,
  });

  Future<AdminCommissionsReport> fetchCommissions({
    required String tenantId,
    required DateTime start,
    required DateTime end,
  });

  Future<List<BusinessHour>> fetchBusinessHours({required String tenantId});

  Future<void> saveBusinessHours({
    required String tenantId,
    required String actorId,
    required List<BusinessHour> hours,
  });

  Future<List<AdminPromotion>> fetchPromotions({required String tenantId});

  Future<void> savePromotion({
    required String tenantId,
    required AdminPromotion promo,
  });

  Future<void> archivePromotion({
    required String tenantId,
    required String promotionId,
  });

  Future<List<AdminBarberRef>> fetchBarbers({required String tenantId});

  Future<List<CommissionLine>> fetchCommissionLines({
    required String tenantId,
    required String barberId,
  });

  Future<void> saveCommissionOverride({
    required String tenantId,
    required String barberId,
    required String serviceId,
    required String type,
    required double value,
  });

  Future<void> deleteCommissionOverride({
    required String tenantId,
    required String barberId,
    required String serviceId,
  });

  Future<List<AdminCustomer>> fetchCustomers({required String tenantId});

  Future<void> adjustCustomerPoints({
    required String tenantId,
    required String customerId,
    required int delta,
    required String reason,
  });

  /// Emite un cupón de una promoción a un cliente. Devuelve el código único.
  Future<String> emitCustomerCoupon({
    required String tenantId,
    required String customerId,
    required String promotionId,
    required String emittedBy,
  });

  Future<AdminTenantSettings> fetchTenantSettings({required String tenantId});

  Future<void> saveTenantGeneral({
    required String tenantId,
    required String actorId,
    required String name,
    required String phone,
    required String address,
    required String email,
  });

  Future<void> saveTenantAutomation({
    required String tenantId,
    required String actorId,
    required bool enabled,
    required int days,
    required String message,
  });

  Future<void> registerCashAdjustment({
    required String tenantId,
    required double amount,
    required String reasonCode,
    required String idempotencyKey,
    String? reasonText,
  });
}
