import 'package:trim_flow/features/products/domain/models/cart_item.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

/// Almacen en memoria de pedidos (mock). Persiste durante la sesion.
/// Los cambios de estado reales (pagado/recogido/cancelado) los hace el
/// administrador desde la web; aqui se simulan para visualizar el flujo.
class OrdersStore {
  OrdersStore._();
  static final OrdersStore instance = OrdersStore._();

  static const String defaultPickup = 'Barbería Ocean · Av. Larco 345, Miraflores';

  final List<ProductOrder> _orders = _seed();

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

  static List<ProductOrder> _seed() {
    Product p(String id, String name, double price, String img) => Product(
          id: id,
          name: name,
          description: '',
          price: price,
          imageUrl: img,
          categoryId: '',
          barcode: id,
        );

    return [
      ProductOrder(
        id: 'ord_seed_1',
        code: 'TF-480921',
        items: [
          CartItem(product: p('s1', 'Cera Mate Premium', 39.90, 'images/mustache.png'), quantity: 2),
          CartItem(product: p('s2', 'Aceite para Barba', 45.00, 'images/beard.png')),
        ],
        total: 124.80,
        paymentMethod: PaymentMethod.yape,
        createdAt: DateTime(2026, 5, 28, 16, 12),
        status: OrderStatus.completed,
        pickupLocation: defaultPickup,
        paidAt: DateTime(2026, 5, 28, 16, 12),
        completedAt: DateTime(2026, 5, 29, 11, 5),
      ),
      ProductOrder(
        id: 'ord_seed_2',
        code: 'TF-503377',
        items: [
          CartItem(product: p('s3', 'Shampoo Anticaspa', 29.50, 'images/barbershop.png')),
        ],
        total: 29.50,
        paymentMethod: PaymentMethod.bcp,
        createdAt: DateTime(2026, 6, 1, 10, 40),
        status: OrderStatus.ready,
        pickupLocation: defaultPickup,
        paidAt: DateTime(2026, 6, 1, 10, 41),
      ),
      ProductOrder(
        id: 'ord_seed_3',
        code: 'TF-511204',
        items: [
          CartItem(product: p('s4', 'Pomada Clásica', 35.00, 'images/mustache.png')),
          CartItem(product: p('s5', 'Peine de Madera', 18.00, 'images/beard.png'), quantity: 1),
        ],
        total: 53.00,
        paymentMethod: PaymentMethod.efectivo,
        createdAt: DateTime(2026, 6, 3, 18, 22),
        status: OrderStatus.pendingPayment,
        pickupLocation: defaultPickup,
      ),
    ];
  }
}
