import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';

part 'cart_event.freezed.dart';

@freezed
class CartEvent with _$CartEvent {
  const factory CartEvent.started() = _Started;
  const factory CartEvent.addItem(Product product) = _AddItem;
  const factory CartEvent.removeItem(String productId) = _RemoveItem;
  const factory CartEvent.updateQuantity(String productId, int delta) = _UpdateQuantity;
  const factory CartEvent.clear() = _Clear;
}
