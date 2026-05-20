import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';

part 'product_order.freezed.dart';
part 'product_order.g.dart';

enum PaymentMethod { yape, bcp, efectivo }

@freezed
abstract class ProductOrder with _$ProductOrder {
  const factory ProductOrder({
    required String id,
    required List<CartItem> items,
    required double total,
    required PaymentMethod paymentMethod,
    required DateTime createdAt,
    @Default('PENDIENTE') String status,
  }) = _ProductOrder;

  factory ProductOrder.fromJson(Map<String, dynamic> json) =>
      _$ProductOrderFromJson(json);
}
