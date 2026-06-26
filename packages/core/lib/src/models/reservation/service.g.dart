// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Service _$ServiceFromJson(Map<String, dynamic> json) => _Service(
  tenantId: json['tenantId'] as String,
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  durationInMinutes: (json['durationInMinutes'] as num).toInt(),
  category: json['category'] as String,
  isFeatured: json['isFeatured'] as bool? ?? false,
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$ServiceToJson(_Service instance) => <String, dynamic>{
  'tenantId': instance.tenantId,
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'durationInMinutes': instance.durationInMinutes,
  'category': instance.category,
  'isFeatured': instance.isFeatured,
  'description': instance.description,
};
