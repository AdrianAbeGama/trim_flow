import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/products/domain/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartEvent>((event, emit) {
      event.when(
        started: () {},
        addItem: (product) {
          final items = List<CartItem>.from(state.items);
          final index = items.indexWhere((i) => i.product.id == product.id);

          if (index >= 0) {
            final current = items[index];
            final nextQty = _clampToStock(current.quantity + 1, product.stock);
            items[index] = current.copyWith(quantity: nextQty);
          } else {
            items.add(CartItem(product: product, quantity: 1));
          }
          emit(state.copyWith(items: items));
        },
        removeItem: (productId) {
          final items = state.items.where((i) => i.product.id != productId).toList();
          emit(state.copyWith(items: items));
        },
        updateQuantity: (productId, delta) {
          final items = List<CartItem>.from(state.items);
          final index = items.indexWhere((i) => i.product.id == productId);

          if (index >= 0) {
            final newQty = items[index].quantity + delta;
            if (newQty <= 0) {
              items.removeAt(index);
            } else {
              final clamped = _clampToStock(newQty, items[index].product.stock);
              items[index] = items[index].copyWith(quantity: clamped);
            }
            emit(state.copyWith(items: items));
          }
        },
        clear: () => emit(const CartState()),
      );
    });
  }

  int _clampToStock(int quantity, int stock) {
    if (stock > 0 && quantity > stock) {
      return stock;
    }
    return quantity;
  }
}
