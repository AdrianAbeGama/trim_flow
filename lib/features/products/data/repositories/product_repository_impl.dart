import '../../domain/models/product.dart';
import '../../domain/models/product_category.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/product_mock_datasource.dart';

class ProductRepositoryImpl implements IProductRepository {
  final ProductMockDatasource _datasource;

  ProductRepositoryImpl({ProductMockDatasource? datasource})
      : _datasource = datasource ?? ProductMockDatasource();

  @override
  Future<List<Product>> getProducts() async {
    return _datasource.products;
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    return _datasource.products
        .where((p) => p.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final q = query.toLowerCase();
    return _datasource.products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    return _datasource.categories;
  }

  @override
  Future<Product> saveProduct(Product product) async {
    _datasource.saveProduct(product);
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _datasource.deleteProduct(id);
  }
}
