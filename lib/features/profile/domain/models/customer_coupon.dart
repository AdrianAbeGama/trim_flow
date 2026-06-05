import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_coupon.freezed.dart';

@freezed
abstract class CustomerCoupon with _$CustomerCoupon {
  const CustomerCoupon._();

  const factory CustomerCoupon({
    required String id,
    required String code,
    required String name,
    required String discountType,
    required double discountValue,
    required DateTime validUntil,
    DateTime? redeemedAt,
    @Default(true) bool promoActive,
  }) = _CustomerCoupon;

  bool get isRedeemed => redeemedAt != null;
  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isUsable => !isRedeemed && !isExpired && promoActive;

  String get discountLabel => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}%'
      : 'S/ ${discountValue.toStringAsFixed(0)}';
}
