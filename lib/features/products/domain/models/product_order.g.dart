// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductOrder _$ProductOrderFromJson(Map<String, dynamic> json) =>
    _ProductOrder(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'PENDIENTE',
    );

Map<String, dynamic> _$ProductOrderToJson(_ProductOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'total': instance.total,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': instance.status,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.yape: 'yape',
  PaymentMethod.bcp: 'bcp',
  PaymentMethod.efectivo: 'efectivo',
};
