import '../models/product.dart';
import '../models/product_category.dart';

abstract class IProductRepository {
  /// Retorna todos los productos del catálogo.
  Future<List<Product>> getProducts();

  /// Retorna todos los productos filtrados por categoría.
  Future<List<Product>> getProductsByCategory(String categoryId);

  /// Retorna productos cuyo nombre o descripción coincida con [query].
  Future<List<Product>> searchProducts(String query);

  /// Retorna todas las categorías disponibles.
  Future<List<ProductCategory>> getCategories();

  /// Añade o actualiza un producto (solo barbero).
  Future<Product> saveProduct(Product product);

  /// Elimina un producto por su [id] (solo barbero).
  Future<void> deleteProduct(String id);
}
