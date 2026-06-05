import 'package:trim_flow/features/profile/domain/models/customer_coupon.dart';

class CouponMapper {
  static CustomerCoupon? fromRow(Map<String, dynamic> row) {
    final validRaw = row['valid_until'] as String?;
    final validUntil =
        validRaw != null ? DateTime.tryParse(validRaw)?.toLocal() : null;
    if (validUntil == null) return null;

    final promo = row['promotion'] as Map<String, dynamic>?;
    final redeemedRaw = row['redeemed_at'] as String?;

    return CustomerCoupon(
      id: row['id'] as String,
      code: (row['unique_code'] as String?) ?? '',
      name: (promo?['name'] as String?) ?? 'Promoción',
      discountType: (promo?['discount_type'] as String?) ?? 'percentage',
      discountValue: (promo?['discount_value'] as num?)?.toDouble() ?? 0,
      validUntil: validUntil,
      redeemedAt:
          redeemedRaw != null ? DateTime.tryParse(redeemedRaw)?.toLocal() : null,
      promoActive: (promo?['is_active'] as bool?) ?? true,
    );
  }
}
