import 'package:trim_flow/features/products/domain/models/product_order.dart';

/// Almacen de pedidos para la vista del BARBERO (incluye el nombre del
/// cliente). Demo sin backend: arranca vacio hasta que el socio entregue la
/// tabla de pedidos.
class BarberOrdersStore {
  BarberOrdersStore._();
  static final BarberOrdersStore instance = BarberOrdersStore._();

  final List<ProductOrder> _orders = <ProductOrder>[];

  /// Pedidos mas recientes primero.
  List<ProductOrder> list() => List.unmodifiable(_orders.reversed);

  ProductOrder? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// Avanza el estado: pendiente -> pagado -> listo -> recogido.
  void advance(String id) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) return;
    final o = _orders[i];
    final next = switch (o.status) {
      OrderStatus.pendingPayment => OrderStatus.paid,
      OrderStatus.paid => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.completed,
      _ => o.status,
    };
    _orders[i] = o.copyWith(
      status: next,
      paidAt: next == OrderStatus.paid ? DateTime.now() : o.paidAt,
      completedAt:
          next == OrderStatus.completed ? DateTime.now() : o.completedAt,
    );
  }

  /// Retrocede el estado un paso (por si el encargado se equivoca). Desde
  /// cancelado, reactiva a pendiente de pago.
  void revert(String id) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) return;
    final o = _orders[i];
    final prev = switch (o.status) {
      OrderStatus.completed => OrderStatus.ready,
      OrderStatus.ready => OrderStatus.paid,
      OrderStatus.paid => OrderStatus.pendingPayment,
      OrderStatus.cancelled => OrderStatus.pendingPayment,
      _ => o.status,
    };
    _orders[i] = o.copyWith(
      status: prev,
      completedAt: prev == OrderStatus.completed ? o.completedAt : null,
      paidAt: prev == OrderStatus.pendingPayment ? null : o.paidAt,
      cancellationReason: null,
    );
  }

  void cancel(String id, String reason) {
    final i = _orders.indexWhere((o) => o.id == id);
    if (i == -1) return;
    _orders[i] = _orders[i].copyWith(
      status: OrderStatus.cancelled,
      cancellationReason: reason,
    );
  }
}
