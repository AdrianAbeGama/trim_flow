import 'package:trim_flow/features/products/domain/models/cart_item.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

/// Almacen en memoria de pedidos (mock). Persiste durante la sesion.
/// Los cambios de estado reales (pagado/recogido/cancelado) los hace el
/// administrador desde la web; aqui se simulan para visualizar el flujo.
class OrdersStore {
  OrdersStore._();
  static final OrdersStore instance = OrdersStore._();

  static const String defaultPickup = 'Barbería Ocean · Av. Larco 345, Miraflores';

  final List<ProductOrder> _orders = [];

  /// Pedidos mas recientes primero.
  List<ProductOrder> list() => List.unmodifiable(_orders.reversed);

  ProductOrder place({
    required List<CartItem> items,
    required double total,
    required PaymentMethod paymentMethod,
  }) {
    final now = DateTime.now();
    final stamp = now.millisecondsSinceEpoch;
    // Yape/BCP se asumen pagados al confirmar; efectivo queda por pagar.
    final paid = paymentMethod != PaymentMethod.efectivo;
    final order = ProductOrder(
      id: 'ord_$stamp',
      code: 'TF-${stamp.toString().substring(stamp.toString().length - 6)}',
      items: items,
      total: total,
      paymentMethod: paymentMethod,
      createdAt: now,
      status: paid ? OrderStatus.paid : OrderStatus.pendingPayment,
      pickupLocation: defaultPickup,
      paidAt: paid ? now : null,
    );
    _orders.add(order);
    return order;
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
