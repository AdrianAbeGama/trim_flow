import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';

class ProductMockDatasource {
  static final List<Product> _products = [];
  static final List<ProductCategory> _categories = [];
  static final List<ProductCatalog> _catalogs = [];
  static final List<InventoryItem> _inventoryItems = [];

  ProductMockDatasource();

  List<Product> get products => _products;
  List<ProductCategory> get categories => _categories;
  List<ProductCatalog> get catalogs => _catalogs;
  List<InventoryItem> get inventoryItems => _inventoryItems;

  void saveProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    } else {
      _products.add(product);
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
  }

  void saveCategory(ProductCategory category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _categories[index] = category;
    } else {
      _categories.add(category);
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
  }

  void saveCatalog(ProductCatalog catalog) {
    final index = _catalogs.indexWhere((c) => c.id == catalog.id);
    if (index >= 0) {
      _catalogs[index] = catalog;
    } else {
      _catalogs.add(catalog);
    }
  }

  void deleteCatalog(String id) {
    _catalogs.removeWhere((c) => c.id == id);
  }

  void saveInventoryItem(InventoryItem item) {
    final index = _inventoryItems.indexWhere((i) => i.id == item.id || i.name.trim().toLowerCase() == item.name.trim().toLowerCase());
    if (index >= 0) {
      _inventoryItems[index] = item;
    } else {
      _inventoryItems.add(item);
    }
  }

  void deleteInventoryItem(String id) {
    _inventoryItems.removeWhere((i) => i.id == id);
  }
}
