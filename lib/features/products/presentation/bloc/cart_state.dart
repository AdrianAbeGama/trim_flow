import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/products/domain/models/cart_item.dart';

part 'cart_state.freezed.dart';

@freezed
abstract class CartState with _$CartState {
  const factory CartState({
    @Default(<CartItem>[]) List<CartItem> items,
  }) = CartStateData;

  const CartState._();

  double get totalPrice => items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
