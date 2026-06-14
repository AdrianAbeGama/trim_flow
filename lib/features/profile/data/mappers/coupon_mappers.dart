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

  /// Mapea un item de la RPC get_my_coupons (backend) a CustomerCoupon.
  static CustomerCoupon? fromMyCoupon(Map<String, dynamic> json) {
    final validRaw = json['validUntil'] as String?;
    final validUntil =
        validRaw != null ? DateTime.tryParse(validRaw)?.toLocal() : null;
    if (validUntil == null) return null;
    final redeemedRaw = json['redeemedAt'] as String?;
    final code = (json['code'] as String?) ?? '';

    return CustomerCoupon(
      id: code,
      code: code,
      name: (json['description'] as String?) ?? 'Promoción',
      discountType: (json['discountType'] as String?) ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      validUntil: validUntil,
      redeemedAt:
          redeemedRaw != null ? DateTime.tryParse(redeemedRaw)?.toLocal() : null,
      promoActive: true,
    );
  }
}
