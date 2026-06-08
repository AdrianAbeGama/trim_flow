import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';

part 'product_event.freezed.dart';

@freezed
sealed class ProductEvent with _$ProductEvent {
  const factory ProductEvent.started() = _Started;
  const factory ProductEvent.searchChanged(String query) = _SearchChanged;
  const factory ProductEvent.categorySelected(String? categoryId) = _CategorySelected;
  
  // Productos
  const factory ProductEvent.addProduct(Product product) = _AddProduct;
  const factory ProductEvent.deleteProduct(String productId) = _DeleteProduct;
  const factory ProductEvent.toggleFavorite(String productId) = _ToggleFavorite;
  const factory ProductEvent.toggleEditMode() = _ToggleEditMode;
  const factory ProductEvent.toggleExpansion(String productId) = _ToggleExpansion;

  // Inventario
  const factory ProductEvent.addInventoryItem(InventoryItem item) = _AddInventoryItem;
  const factory ProductEvent.updateInventoryItem(InventoryItem item) = _UpdateInventoryItem;
  const factory ProductEvent.deleteInventoryItem(String id) = _DeleteInventoryItem;

  // Catálogos y Categorías
  const factory ProductEvent.addCatalog(ProductCatalog catalog) = _AddCatalog;
  const factory ProductEvent.deleteCatalog(String id) = _DeleteCatalog;
  const factory ProductEvent.toggleCatalogActive(String id) = _ToggleCatalogActive;
  const factory ProductEvent.addCategory(ProductCategory category) = _AddCategory;
  const factory ProductEvent.deleteCategory(String id) = _DeleteCategory;
}

