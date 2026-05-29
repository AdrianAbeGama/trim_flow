import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';

class ProductMockDatasource {
  static final List<Product> _products = [];
  static final List<ProductCategory> _categories = [];
  static final List<ProductCatalog> _catalogs = [];
  static final List<InventoryItem> _inventoryItems = [];

  ProductMockDatasource() {
    if (_categories.isEmpty) {
      _categories.addAll([
        const ProductCategory(id: 'cat_cera', name: 'Cera para cabello', icon: '0xe88a'),
        const ProductCategory(id: 'cat_shampoo', name: 'Shampoo', icon: '0xe88a'),
        const ProductCategory(id: 'cat_aceite', name: 'Aceite de barba', icon: '0xe88a'),
        const ProductCategory(id: 'cat_gel', name: 'Gel Fijador', icon: '0xe88a'),
      ]);
    }
    
    if (_products.isEmpty) {
      _products.addAll([
        const Product(
          id: 'prod_1',
          name: 'Cera Mate TrimFlow',
          description: 'Cera de fijación fuerte y acabado mate.',
          price: 35.0,
          imageUrl: 'https://images.unsplash.com/photo-1599305090598-fe179d501227?w=500&q=80',
          categoryId: 'cat_cera',
          barcode: '11111111',
        ),
        const Product(
          id: 'prod_2',
          name: 'Shampoo Carbón',
          description: 'Limpieza profunda con carbón activado.',
          price: 28.0,
          imageUrl: 'https://images.unsplash.com/photo-1585232351009-aa87416fca90?w=500&q=80',
          categoryId: 'cat_shampoo',
          barcode: '22222222',
        ),
        const Product(
          id: 'prod_3',
          name: 'Aceite de Barba Premium',
          description: 'Hidratación profunda con aroma a madera.',
          price: 45.0,
          imageUrl: 'https://images.unsplash.com/photo-1621607512214-68297480165e?w=500&q=80',
          categoryId: 'cat_aceite',
          barcode: '33333333',
        ),
        const Product(
          id: 'prod_4',
          name: 'Cera Brillante Clásica',
          description: 'Acabado brillante para estilos clásicos.',
          price: 30.0,
          imageUrl: 'https://images.unsplash.com/photo-1599305090598-fe179d501227?w=500&q=80', // Reuse image for now
          categoryId: 'cat_cera',
          barcode: '44444444',
        ),
        const Product(
          id: 'prod_5',
          name: 'Gel Extra Fuerte',
          description: 'Gel fijador que dura todo el día.',
          price: 20.0,
          imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=500&q=80',
          categoryId: 'cat_gel',
          barcode: '55555555',
        ),
      ]);
    }
  }

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
