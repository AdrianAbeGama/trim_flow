// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductOrder _$ProductOrderFromJson(Map<String, dynamic> json) =>
    _ProductOrder(
      id: json['id'] as String,
      code: json['code'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status:
          $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
          OrderStatus.pendingPayment,
      pickupLocation: json['pickupLocation'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$ProductOrderToJson(_ProductOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'items': instance.items,
      'total': instance.total,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'pickupLocation': instance.pickupLocation,
      'cancellationReason': instance.cancellationReason,
      'paidAt': instance.paidAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.yape: 'yape',
  PaymentMethod.bcp: 'bcp',
  PaymentMethod.efectivo: 'efectivo',
};

const _$OrderStatusEnumMap = {
  OrderStatus.pendingPayment: 'pendingPayment',
  OrderStatus.paid: 'paid',
  OrderStatus.ready: 'ready',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};
