import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';
import 'package:trim_flow/features/products/domain/models/product_catalog.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';
import 'package:trim_flow/features/products/domain/usecases/product_usecases.dart';
import 'package:trim_flow/features/products/data/datasources/product_mock_datasource.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase _getProducts;
  final GetCategoriesUseCase _getCategories;
  final SaveProductUseCase _saveProduct;
  final DeleteProductUseCase _deleteProduct;

  ProductBloc({
    required GetProductsUseCase getProducts,
    required GetCategoriesUseCase getCategories,
    required SearchProductsUseCase searchProducts,
    required FilterByCategoryUseCase filterByCategory,
    required SaveProductUseCase saveProduct,
    required DeleteProductUseCase deleteProduct,
  })  : _getProducts = getProducts,
        _getCategories = getCategories,
        _saveProduct = saveProduct,
        _deleteProduct = deleteProduct,
        super(const ProductState()) {
    on<ProductEvent>((event, emit) async {
      await event.when(
        started: () => _onStarted(emit),
        searchChanged: (query) => _onSearchChanged(query, emit),
        categorySelected: (categoryId) => _onCategorySelected(categoryId, emit),
        addProduct: (product) => _onAddProduct(product, emit),
        deleteProduct: (productId) => _onDeleteProduct(productId, emit),
        toggleFavorite: (productId) => _onToggleFavorite(productId, emit),
        toggleEditMode: () => _onToggleEditMode(emit),
        toggleExpansion: (productId) => _onToggleExpansion(productId, emit),
        
        // Inventario
        addInventoryItem: (item) => _onAddInventoryItem(item, emit),
        updateInventoryItem: (item) => _onUpdateInventoryItem(item, emit),
        deleteInventoryItem: (id) => _onDeleteInventoryItem(id, emit),

        // Catálogos y Categorías
        addCatalog: (catalog) => _onAddCatalog(catalog, emit),
        deleteCatalog: (id) => _onDeleteCatalog(id, emit),
        toggleCatalogActive: (id) => _onToggleCatalogActive(id, emit),
        addCategory: (category) => _onAddCategory(category, emit),
        deleteCategory: (id) => _onDeleteCategory(id, emit),
      );
    });
  }

  Future<void> _onStarted(Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _getProducts(),
        _getCategories(),
      ]);
      final products = results[0] as List<Product>;
      final categories = results[1] as List<ProductCategory>;
      const allCategory =
          ProductCategory(id: 'todos', name: 'TODOS', icon: 'all');

      emit(state.copyWith(
        isLoading: false,
        allProducts: products,
        products: products,
        categories: [allCategory, ...categories],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSearchChanged(String query, Emitter<ProductState> emit) async {
    emit(state.copyWith(searchQuery: query, selectedCategoryId: null));
    if (query.isEmpty) {
      emit(state.copyWith(products: state.allProducts));
      return;
    }
    final results = state.allProducts.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) ||
      p.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
    emit(state.copyWith(products: results));
  }

  Future<void> _onCategorySelected(String? categoryId, Emitter<ProductState> emit) async {
    if (categoryId == null || categoryId == 'todos' || state.selectedCategoryId == categoryId) {
      emit(state.copyWith(selectedCategoryId: null, products: state.allProducts));
      return;
    }
    final filtered = state.allProducts.where((p) => p.categoryId == categoryId).toList();
    emit(state.copyWith(selectedCategoryId: categoryId, products: filtered));
  }

  Future<void> _onAddProduct(Product product, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    final saved = await _saveProduct(product);
    final updatedAll = [...state.allProducts];
    final idx = updatedAll.indexWhere((p) => p.id == saved.id);
    if (idx >= 0) {
      updatedAll[idx] = saved;
    } else {
      updatedAll.add(saved);
    }
    _syncFilteredAndEmit(updatedAll.toList(), emit);
  }

  Future<void> _onDeleteProduct(String productId, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _deleteProduct(productId);
    final updatedAll = state.allProducts.where((p) => p.id != productId).toList();
    _syncFilteredAndEmit(updatedAll, emit);
  }

  Future<void> _onToggleFavorite(String productId, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    final updatedAll = state.allProducts.map((p) {
      if (p.id == productId) return p.copyWith(isFavorite: !p.isFavorite);
      return p;
    }).toList();
    _syncFilteredAndEmit(updatedAll, emit);
  }

  Future<void> _onToggleEditMode(Emitter<ProductState> emit) async {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  Future<void> _onToggleExpansion(String productId, Emitter<ProductState> emit) async {
    final updated = Set<String>.from(state.expandedProductIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    emit(state.copyWith(expandedProductIds: updated));
  }

  // Métodos de Inventario con persistencia real
  Future<void> _onAddInventoryItem(InventoryItem item, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    final updated = [...state.inventoryItems];
    final idx = updated.indexWhere((i) => i.id.toString() == item.id.toString() || i.name.trim().toLowerCase() == item.name.trim().toLowerCase());
    if (idx >= 0) {
      final mergedItem = updated[idx].copyWith(quantity: updated[idx].quantity + item.quantity);
      updated[idx] = mergedItem;
      ProductMockDatasource().saveInventoryItem(mergedItem);
    } else {
      updated.add(item);
      ProductMockDatasource().saveInventoryItem(item);
    }
    emit(state.copyWith(isLoading: false, inventoryItems: updated.toList()));
  }

  Future<void> _onUpdateInventoryItem(InventoryItem item, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    ProductMockDatasource().saveInventoryItem(item);
    final updated = state.inventoryItems.map((i) => i.id == item.id ? item : i).toList();
    emit(state.copyWith(isLoading: false, inventoryItems: updated));
  }

  Future<void> _onDeleteInventoryItem(String id, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    ProductMockDatasource().deleteInventoryItem(id);
    final updated = state.inventoryItems.where((i) => i.id != id).toList();
    emit(state.copyWith(isLoading: false, inventoryItems: updated));
  }

  // Catálogos y Categorías con persistencia real
  Future<void> _onAddCatalog(ProductCatalog catalog, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    final datasource = ProductMockDatasource();
    final List<ProductCatalog> updated = [...state.catalogs];
    
    if (catalog.isActive) {
      for (int i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(isActive: false);
        datasource.saveCatalog(updated[i]);
      }
    }
    
    final idx = updated.indexWhere((c) => c.id == catalog.id);
    if (idx >= 0) {
      updated[idx] = catalog;
    } else {
      updated.add(catalog);
    }
    
    datasource.saveCatalog(catalog);
    emit(state.copyWith(isLoading: false, catalogs: updated.toList()));
  }

  Future<void> _onDeleteCatalog(String id, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    ProductMockDatasource().deleteCatalog(id);
    final datasource = ProductMockDatasource();
    final cats = [...state.categories];
    for (var cat in cats.where((c) => c.catalogId == id).toList()) {
      datasource.deleteCategory(cat.id);
    }
    final updatedCats = state.categories.where((c) => c.catalogId != id).toList();
    final updated = state.catalogs.where((c) => c.id != id).toList();
    emit(state.copyWith(isLoading: false, catalogs: updated, categories: updatedCats));
  }

  Future<void> _onToggleCatalogActive(String id, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    final datasource = ProductMockDatasource();
    final updated = state.catalogs.map((c) {
      final updatedCatalog = (c.id == id) ? c.copyWith(isActive: !c.isActive) : c.copyWith(isActive: false);
      datasource.saveCatalog(updatedCatalog);
      return updatedCatalog;
    }).toList();
    emit(state.copyWith(isLoading: false, catalogs: updated));
  }

  Future<void> _onAddCategory(ProductCategory category, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    ProductMockDatasource().saveCategory(category);
    final updated = [...state.categories];
    final idx = updated.indexWhere((c) => c.id == category.id);
    if (idx >= 0) {
      updated[idx] = category;
    } else {
      updated.add(category);
    }
    emit(state.copyWith(isLoading: false, categories: updated.toList()));
  }

  Future<void> _onDeleteCategory(String id, Emitter<ProductState> emit) async {
    emit(state.copyWith(isLoading: true));
    ProductMockDatasource().deleteCategory(id);
    final updated = state.categories.where((c) => c.id != id).toList();
    emit(state.copyWith(isLoading: false, categories: updated));
  }

  // Helpers
  void _syncFilteredAndEmit(List<Product> all, Emitter<ProductState> emit) {
    List<Product> filtered = all;
    if (state.selectedCategoryId != null && state.selectedCategoryId != 'todos') {
      filtered = all.where((p) => p.categoryId == state.selectedCategoryId).toList();
    }
    emit(state.copyWith(isLoading: false, allProducts: all, products: filtered));
  }
}
