// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'center.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BarberCenter _$BarberCenterFromJson(Map<String, dynamic> json) =>
    _BarberCenter(
      tenantId: json['tenantId'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$BarberCenterToJson(_BarberCenter instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'imageUrl': instance.imageUrl,
    };
