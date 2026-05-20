import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';

part 'product_state.freezed.dart';

@freezed
abstract class ProductState with _$ProductState {
  const factory ProductState({
    @Default(false) bool isLoading,
    @Default(<Product>[]) List<Product> products, // Lista filtrada
    @Default(<Product>[]) List<Product> allProducts, // Lista completa
    @Default(<ProductCategory>[]) List<ProductCategory> categories,
    @Default(<InventoryItem>[]) List<InventoryItem> inventoryItems,
    @Default(<ProductCatalog>[]) List<ProductCatalog> catalogs,
    String? selectedCategoryId,
    @Default('') String searchQuery,
    @Default(false) bool isEditing,
    @Default(<String>{}) Set<String> expandedProductIds,
    String? error,
  }) = ProductStateData;
}
