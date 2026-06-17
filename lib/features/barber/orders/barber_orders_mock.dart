import 'package:trim_flow/features/products/domain/models/cart_item.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/product_order.dart';

/// Almacen mock de pedidos para la vista del BARBERO (incluye el nombre del
/// cliente). Demo: el barbero ve los pedidos de la tienda y avanza su estado a
/// mano (pagado / listo / recogido). Sin backend todavia.
class BarberOrdersStore {
  BarberOrdersStore._();
  static final BarberOrdersStore instance = BarberOrdersStore._();

  static const String _pickup = 'Barbería Ocean · Av. Larco 345, Miraflores';

  final List<ProductOrder> _orders = _seed();

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

  static Product _p(String id, String name, double price, String img) => Product(
        id: id,
        name: name,
        description: '',
        price: price,
        imageUrl: img,
        categoryId: '',
        barcode: id,
      );

  static List<ProductOrder> _seed() {
    return [
      ProductOrder(
        id: 'bord_1',
        code: 'TF-620145',
        customerName: 'Sergio Pinto',
        customerPhone: '987 654 321',
        items: [
          CartItem(
              product: _p('p1', 'Cera Mate Premium', 39.90, 'images/mustache.png'),
              quantity: 2),
          CartItem(product: _p('p2', 'Aceite para Barba', 45.00, 'images/beard.png')),
        ],
        total: 124.80,
        paymentMethod: PaymentMethod.yape,
        createdAt: DateTime(2026, 6, 12, 9, 15),
        status: OrderStatus.paid,
        pickupLocation: _pickup,
        paidAt: DateTime(2026, 6, 12, 9, 16),
      ),
      ProductOrder(
        id: 'bord_2',
        code: 'TF-620150',
        customerName: 'Tomás Vera',
        customerPhone: '999 112 233',
        items: [
          CartItem(product: _p('p3', 'Shampoo Anticaspa', 29.50, 'images/barbershop.png')),
        ],
        total: 29.50,
        paymentMethod: PaymentMethod.efectivo,
        createdAt: DateTime(2026, 6, 13, 10, 5),
        status: OrderStatus.pendingPayment,
        pickupLocation: _pickup,
      ),
      ProductOrder(
        id: 'bord_3',
        code: 'TF-620162',
        customerName: 'Nicolás Ríos',
        customerPhone: '955 778 900',
        items: [
          CartItem(product: _p('p4', 'Pomada Clásica', 35.00, 'images/mustache.png')),
          CartItem(
              product: _p('p5', 'Peine de Madera', 18.00, 'images/beard.png'),
              quantity: 2),
        ],
        total: 71.00,
        paymentMethod: PaymentMethod.bcp,
        createdAt: DateTime(2026, 6, 13, 11, 40),
        status: OrderStatus.ready,
        pickupLocation: _pickup,
        paidAt: DateTime(2026, 6, 13, 11, 41),
      ),
      ProductOrder(
        id: 'bord_4',
        code: 'TF-619980',
        customerName: 'Gabriel Luna',
        customerPhone: '988 445 100',
        items: [
          CartItem(product: _p('p6', 'Kit Afeitado Premium', 89.90, 'images/barbershop.png')),
        ],
        total: 89.90,
        paymentMethod: PaymentMethod.yape,
        createdAt: DateTime(2026, 6, 11, 17, 30),
        status: OrderStatus.completed,
        pickupLocation: _pickup,
        paidAt: DateTime(2026, 6, 11, 17, 31),
        completedAt: DateTime(2026, 6, 12, 12, 10),
      ),
      ProductOrder(
        id: 'bord_5',
        code: 'TF-619820',
        customerName: 'Álvaro Mejía',
        customerPhone: '977 220 540',
        items: [
          CartItem(product: _p('p7', 'Cera Mate Premium', 39.90, 'images/mustache.png')),
        ],
        total: 39.90,
        paymentMethod: PaymentMethod.efectivo,
        createdAt: DateTime(2026, 6, 10, 14, 0),
        status: OrderStatus.cancelled,
        pickupLocation: _pickup,
        cancellationReason: 'El cliente no recogió a tiempo',
      ),
    ];
  }
}
