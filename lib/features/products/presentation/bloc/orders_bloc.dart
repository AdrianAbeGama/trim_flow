import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/products/data/orders_store.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersStore _store;

  OrdersBloc([OrdersStore? store])
      : _store = store ?? OrdersStore.instance,
        super(const OrdersState()) {
    on<OrdersStarted>((event, emit) {
      emit(state.copyWith(orders: _store.list()));
    });

    on<OrdersPlaceOrder>((event, emit) {
      final order = _store.place(
        items: event.items,
        total: event.total,
        paymentMethod: event.paymentMethod,
      );
      emit(state.copyWith(orders: _store.list(), lastPlaced: order));
    });

    on<OrdersCancelOrder>((event, emit) {
      _store.cancel(event.orderId, event.reason);
      emit(state.copyWith(orders: _store.list()));
    });
  }
}
