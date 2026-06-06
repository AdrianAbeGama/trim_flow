import 'package:trim_flow/features/admin/domain/models/admin_promotion.dart';
import 'package:trim_flow/features/admin/domain/models/admin_reports.dart';
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
}
