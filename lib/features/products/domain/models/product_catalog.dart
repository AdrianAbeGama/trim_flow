import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_catalog.freezed.dart';
part 'product_catalog.g.dart';

@freezed
abstract class ProductCatalog with _$ProductCatalog {
  const factory ProductCatalog({
    required String id,
    required String name,
    @Default(false) bool isActive,
  }) = _ProductCatalog;

  factory ProductCatalog.fromJson(Map<String, dynamic> json) =>
      _$ProductCatalogFromJson(json);
}

