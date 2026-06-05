import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';

class ProductMockDatasource {
  static final List<ProductCategory> _categories = [
    ProductCategory(id: 'todos', name: 'TODOS', icon: 'all', catalogId: 'default'),
    ProductCategory(id: '1', name: 'POMADAS', icon: 'pomade', catalogId: 'default'),
    ProductCategory(id: '2', name: 'ACEITES', icon: 'oil', catalogId: 'default'),
    ProductCategory(id: '3', name: 'MÁQUINAS', icon: 'machine', catalogId: 'default'),
  ];
  static final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Pomada Reuzel Azul',
      description: 'Pomada soluble en agua con fijación fuerte y alto brillo.',
      price: 65.0,
      stock: 12,
      imageUrl: 'https://m.media-amazon.com/images/I/61k1jY-Vw1L.jpg',
      categoryId: '1',
      isFavorite: false,
      barcode: '7112345678910',
    ),
    Product(
      id: 'p2',
      name: 'Aceite para barba',
      description: 'Aceite premium para suavizar e hidratar la barba.',
      price: 45.0,
      stock: 8,
      imageUrl: 'https://m.media-amazon.com/images/I/71YvU01qJFL.jpg',
      categoryId: '2',
      isFavorite: true,
      barcode: '7112345678911',
    ),
    Product(
      id: 'p3',
      name: 'Wahl Magic Clip',
      description: 'Máquina profesional inalámbrica con cuchilla microdentada.',
      price: 420.0,
      stock: 3,
      imageUrl: 'https://m.media-amazon.com/images/I/61r59Fz+bYL.jpg',
      categoryId: '3',
      isFavorite: false,
      barcode: '7112345678912',
    ),
    Product(
      id: 'p4',
      name: 'Cera Mate Uppercut',
      description: 'Cera de fijación media con acabado mate natural.',
      price: 75.0,
      stock: 15,
      imageUrl: 'https://m.media-amazon.com/images/I/61p3YQe0iJL.jpg',
      categoryId: '1',
      isFavorite: false,
      barcode: '7112345678913',
    ),
    Product(
      id: 'p5',
      name: 'Shampoo King C. Gillette',
      description: 'Shampoo especializado para el cuidado de la barba y rostro.',
      price: 35.0,
      stock: 20,
      imageUrl: 'https://m.media-amazon.com/images/I/61B7d5Z-GvL.jpg',
      categoryId: '2',
      isFavorite: false,
      barcode: '7112345678914',
    ),
  ];
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
