import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/products/domain/models/cart_item.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

part 'orders_event.freezed.dart';

@freezed
class OrdersEvent with _$OrdersEvent {
  const factory OrdersEvent.started() = OrdersStarted;

  const factory OrdersEvent.placeOrder({
    required List<CartItem> items,
    required double total,
    required PaymentMethod paymentMethod,
  }) = OrdersPlaceOrder;

  const factory OrdersEvent.cancelOrder({
    required String orderId,
    required String reason,
  }) = OrdersCancelOrder;
}
