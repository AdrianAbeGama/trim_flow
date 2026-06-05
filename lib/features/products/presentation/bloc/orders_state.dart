import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

part 'orders_state.freezed.dart';

@freezed
abstract class OrdersState with _$OrdersState {
  const factory OrdersState({
    @Default(<ProductOrder>[]) List<ProductOrder> orders,
    ProductOrder? lastPlaced,
  }) = _OrdersState;
}
