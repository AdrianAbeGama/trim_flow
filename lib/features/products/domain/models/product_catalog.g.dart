// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductCatalog _$ProductCatalogFromJson(Map<String, dynamic> json) =>
    _ProductCatalog(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductCatalogToJson(_ProductCatalog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isActive': instance.isActive,
    };
