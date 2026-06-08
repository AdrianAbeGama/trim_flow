import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String barcode,
    @Default(false) bool isFavorite,
    @Default(0) int stock,
    @Default(1) int crossAxisCellCount,
    @Default(1) int mainAxisCellCount,
    String? inventoryItemId, // Vínculo con inventario
    String? catalogId,      // Vínculo con catálogo
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
