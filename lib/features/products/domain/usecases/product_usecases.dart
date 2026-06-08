import '../../domain/models/product.dart';
import '../../domain/models/product_category.dart';
import '../../domain/repositories/i_product_repository.dart';

class GetProductsUseCase {
  final IProductRepository _repository;
  GetProductsUseCase(this._repository);

  Future<List<Product>> call() => _repository.getProducts();
}

class GetCategoriesUseCase {
  final IProductRepository _repository;
  GetCategoriesUseCase(this._repository);

  Future<List<ProductCategory>> call() => _repository.getCategories();
}

class SearchProductsUseCase {
  final IProductRepository _repository;
  SearchProductsUseCase(this._repository);

  Future<List<Product>> call(String query) =>
      _repository.searchProducts(query);
}

class FilterByCategoryUseCase {
  final IProductRepository _repository;
  FilterByCategoryUseCase(this._repository);

  Future<List<Product>> call(String categoryId) =>
      _repository.getProductsByCategory(categoryId);
}

class SaveProductUseCase {
  final IProductRepository _repository;
  SaveProductUseCase(this._repository);

  Future<Product> call(Product product) => _repository.saveProduct(product);
}

class DeleteProductUseCase {
  final IProductRepository _repository;
  DeleteProductUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteProduct(id);
}
