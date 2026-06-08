// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String,
  categoryId: json['categoryId'] as String,
  barcode: json['barcode'] as String,
  isFavorite: json['isFavorite'] as bool? ?? false,
  stock: (json['stock'] as num?)?.toInt() ?? 0,
  crossAxisCellCount: (json['crossAxisCellCount'] as num?)?.toInt() ?? 1,
  mainAxisCellCount: (json['mainAxisCellCount'] as num?)?.toInt() ?? 1,
  inventoryItemId: json['inventoryItemId'] as String?,
  catalogId: json['catalogId'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
  'categoryId': instance.categoryId,
  'barcode': instance.barcode,
  'isFavorite': instance.isFavorite,
  'stock': instance.stock,
  'crossAxisCellCount': instance.crossAxisCellCount,
  'mainAxisCellCount': instance.mainAxisCellCount,
  'inventoryItemId': instance.inventoryItemId,
  'catalogId': instance.catalogId,
};
