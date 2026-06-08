import 'package:freezed_annotation/freezed_annotation.dart';
import 'cart_item.dart';

part 'product_order.freezed.dart';
part 'product_order.g.dart';

enum PaymentMethod { yape, bcp, efectivo }

enum OrderStatus { pendingPayment, paid, ready, completed, cancelled }

@freezed
abstract class ProductOrder with _$ProductOrder {
  const factory ProductOrder({
    required String id,
    required String code,
    required List<CartItem> items,
    required double total,
    required PaymentMethod paymentMethod,
    required DateTime createdAt,
    @Default(OrderStatus.pendingPayment) OrderStatus status,
    @Default('') String pickupLocation,
    String? cancellationReason,
    DateTime? paidAt,
    DateTime? completedAt,
  }) = _ProductOrder;

  const ProductOrder._();

  factory ProductOrder.fromJson(Map<String, dynamic> json) =>
      _$ProductOrderFromJson(json);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isPaid =>
      status == OrderStatus.paid ||
      status == OrderStatus.ready ||
      status == OrderStatus.completed;

  bool get isCancellable =>
      status == OrderStatus.pendingPayment ||
      status == OrderStatus.paid ||
      status == OrderStatus.ready;

  String get branchName {
    final parts = pickupLocation.split(' · ');
    return parts.isNotEmpty ? parts.first.trim() : pickupLocation;
  }

  String get pickupAddress {
    final parts = pickupLocation.split(' · ');
    return parts.length > 1 ? parts.sublist(1).join(' · ').trim() : '';
  }
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.yape:
        return 'Yape';
      case PaymentMethod.bcp:
        return 'BCP';
      case PaymentMethod.efectivo:
        return 'Efectivo';
    }
  }

  static PaymentMethod fromLabel(String raw) {
    switch (raw.toUpperCase()) {
      case 'YAPE':
        return PaymentMethod.yape;
      case 'BCP':
        return PaymentMethod.bcp;
      default:
        return PaymentMethod.efectivo;
    }
  }
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 'PENDIENTE DE PAGO';
      case OrderStatus.paid:
        return 'PAGADO';
      case OrderStatus.ready:
        return 'LISTO PARA RECOGER';
      case OrderStatus.completed:
        return 'RECOGIDO';
      case OrderStatus.cancelled:
        return 'CANCELADO';
    }
  }

  String get short {
    switch (this) {
      case OrderStatus.pendingPayment:
        return 'POR PAGAR';
      case OrderStatus.paid:
        return 'PAGADO';
      case OrderStatus.ready:
        return 'LISTO';
      case OrderStatus.completed:
        return 'RECOGIDO';
      case OrderStatus.cancelled:
        return 'CANCELADO';
    }
  }
}
