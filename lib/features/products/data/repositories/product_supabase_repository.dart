import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';

import '../../domain/models/product.dart';
import '../../domain/models/product_category.dart';
import '../../domain/repositories/i_product_repository.dart';

class ProductSupabaseRepository implements IProductRepository {
  final SupabaseClient _client;

  ProductSupabaseRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  String get _tenantId => getIt<TenantThemeBloc>().state.tenantId;

  @override
  Future<List<Product>> getProducts() async {
    final tenantId = _tenantId;
    if (tenantId.isEmpty || tenantId == kDefaultTenantId) return const [];

    final rows = await _client
        .from('products')
        .select(
            'id, name, description, price_pen, image_url, category_id, catalog_id, barcode')
        .eq('tenant_id', tenantId)
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('display_order');

    return (rows as List)
        .map((r) => _mapProduct(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final all = await getProducts();
    return all.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getProducts();
    final all = await getProducts();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    final tenantId = _tenantId;
    if (tenantId.isEmpty || tenantId == kDefaultTenantId) return const [];

    final rows = await _client
        .from('categories')
        .select('id, name, icon, catalog_id')
        .eq('tenant_id', tenantId)
        .eq('kind', 'product')
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('display_order');

    return (rows as List)
        .map((r) => _mapCategory(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> saveProduct(Product product) async =>
      throw UnimplementedError(
          'La app cliente no administra productos; usa el panel del negocio.');

  @override
  Future<void> deleteProduct(String id) async => throw UnimplementedError(
      'La app cliente no administra productos; usa el panel del negocio.');

  Product _mapProduct(Map<String, dynamic> r) {
    final priceRaw = r['price_pen'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse('${priceRaw ?? ''}') ?? 0;
    return Product(
      id: r['id'] as String,
      name: (r['name'] as String?) ?? '',
      description: (r['description'] as String?) ?? '',
      price: price,
      imageUrl: (r['image_url'] as String?) ?? '',
      categoryId: (r['category_id'] as String?) ?? '',
      barcode: (r['barcode'] as String?) ?? '',
      catalogId: r['catalog_id'] as String?,
    );
  }

  ProductCategory _mapCategory(Map<String, dynamic> r) => ProductCategory(
        id: r['id'] as String,
        name: (r['name'] as String?) ?? '',
        icon: (r['icon'] as String?) ?? 'all',
        catalogId: r['catalog_id'] as String?,
      );
}
