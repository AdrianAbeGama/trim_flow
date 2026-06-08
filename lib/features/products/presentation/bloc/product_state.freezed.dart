// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductState {

 bool get isLoading; List<Product> get products;// Lista filtrada
 List<Product> get allProducts;// Lista completa
 List<ProductCategory> get categories; List<InventoryItem> get inventoryItems; List<ProductCatalog> get catalogs; String? get selectedCategoryId; String get searchQuery; bool get isEditing; Set<String> get expandedProductIds; String? get error;
/// Create a copy of ProductState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductStateCopyWith<ProductState> get copyWith => _$ProductStateCopyWithImpl<ProductState>(this as ProductState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.products, products)&&const DeepCollectionEquality().equals(other.allProducts, allProducts)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.inventoryItems, inventoryItems)&&const DeepCollectionEquality().equals(other.catalogs, catalogs)&&(identical(other.selectedCategoryId, selectedCategoryId) || other.selectedCategoryId == selectedCategoryId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&const DeepCollectionEquality().equals(other.expandedProductIds, expandedProductIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(products),const DeepCollectionEquality().hash(allProducts),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(inventoryItems),const DeepCollectionEquality().hash(catalogs),selectedCategoryId,searchQuery,isEditing,const DeepCollectionEquality().hash(expandedProductIds),error);

@override
String toString() {
  return 'ProductState(isLoading: $isLoading, products: $products, allProducts: $allProducts, categories: $categories, inventoryItems: $inventoryItems, catalogs: $catalogs, selectedCategoryId: $selectedCategoryId, searchQuery: $searchQuery, isEditing: $isEditing, expandedProductIds: $expandedProductIds, error: $error)';
}


}

/// @nodoc
abstract mixin class $ProductStateCopyWith<$Res>  {
  factory $ProductStateCopyWith(ProductState value, $Res Function(ProductState) _then) = _$ProductStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<Product> products, List<Product> allProducts, List<ProductCategory> categories, List<InventoryItem> inventoryItems, List<ProductCatalog> catalogs, String? selectedCategoryId, String searchQuery, bool isEditing, Set<String> expandedProductIds, String? error
});




}
/// @nodoc
class _$ProductStateCopyWithImpl<$Res>
    implements $ProductStateCopyWith<$Res> {
  _$ProductStateCopyWithImpl(this._self, this._then);

  final ProductState _self;
  final $Res Function(ProductState) _then;

/// Create a copy of ProductState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? products = null,Object? allProducts = null,Object? categories = null,Object? inventoryItems = null,Object? catalogs = null,Object? selectedCategoryId = freezed,Object? searchQuery = null,Object? isEditing = null,Object? expandedProductIds = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,allProducts: null == allProducts ? _self.allProducts : allProducts // ignore: cast_nullable_to_non_nullable
as List<Product>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<ProductCategory>,inventoryItems: null == inventoryItems ? _self.inventoryItems : inventoryItems // ignore: cast_nullable_to_non_nullable
as List<InventoryItem>,catalogs: null == catalogs ? _self.catalogs : catalogs // ignore: cast_nullable_to_non_nullable
as List<ProductCatalog>,selectedCategoryId: freezed == selectedCategoryId ? _self.selectedCategoryId : selectedCategoryId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,expandedProductIds: null == expandedProductIds ? _self.expandedProductIds : expandedProductIds // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductState].
extension ProductStatePatterns on ProductState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( ProductStateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProductStateData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( ProductStateData value)  $default,){
final _that = this;
switch (_that) {
case ProductStateData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( ProductStateData value)?  $default,){
final _that = this;
switch (_that) {
case ProductStateData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<Product> products,  List<Product> allProducts,  List<ProductCategory> categories,  List<InventoryItem> inventoryItems,  List<ProductCatalog> catalogs,  String? selectedCategoryId,  String searchQuery,  bool isEditing,  Set<String> expandedProductIds,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProductStateData() when $default != null:
return $default(_that.isLoading,_that.products,_that.allProducts,_that.categories,_that.inventoryItems,_that.catalogs,_that.selectedCategoryId,_that.searchQuery,_that.isEditing,_that.expandedProductIds,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<Product> products,  List<Product> allProducts,  List<ProductCategory> categories,  List<InventoryItem> inventoryItems,  List<ProductCatalog> catalogs,  String? selectedCategoryId,  String searchQuery,  bool isEditing,  Set<String> expandedProductIds,  String? error)  $default,) {final _that = this;
switch (_that) {
case ProductStateData():
return $default(_that.isLoading,_that.products,_that.allProducts,_that.categories,_that.inventoryItems,_that.catalogs,_that.selectedCategoryId,_that.searchQuery,_that.isEditing,_that.expandedProductIds,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<Product> products,  List<Product> allProducts,  List<ProductCategory> categories,  List<InventoryItem> inventoryItems,  List<ProductCatalog> catalogs,  String? selectedCategoryId,  String searchQuery,  bool isEditing,  Set<String> expandedProductIds,  String? error)?  $default,) {final _that = this;
switch (_that) {
case ProductStateData() when $default != null:
return $default(_that.isLoading,_that.products,_that.allProducts,_that.categories,_that.inventoryItems,_that.catalogs,_that.selectedCategoryId,_that.searchQuery,_that.isEditing,_that.expandedProductIds,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ProductStateData implements ProductState {
  const ProductStateData({this.isLoading = false, final  List<Product> products = const <Product>[], final  List<Product> allProducts = const <Product>[], final  List<ProductCategory> categories = const <ProductCategory>[], final  List<InventoryItem> inventoryItems = const <InventoryItem>[], final  List<ProductCatalog> catalogs = const <ProductCatalog>[], this.selectedCategoryId, this.searchQuery = '', this.isEditing = false, final  Set<String> expandedProductIds = const <String>{}, this.error}): _products = products,_allProducts = allProducts,_categories = categories,_inventoryItems = inventoryItems,_catalogs = catalogs,_expandedProductIds = expandedProductIds;
  

@override@JsonKey() final  bool isLoading;
 final  List<Product> _products;
@override@JsonKey() List<Product> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

// Lista filtrada
 final  List<Product> _allProducts;
// Lista filtrada
@override@JsonKey() List<Product> get allProducts {
  if (_allProducts is EqualUnmodifiableListView) return _allProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allProducts);
}

// Lista completa
 final  List<ProductCategory> _categories;
// Lista completa
@override@JsonKey() List<ProductCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<InventoryItem> _inventoryItems;
@override@JsonKey() List<InventoryItem> get inventoryItems {
  if (_inventoryItems is EqualUnmodifiableListView) return _inventoryItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inventoryItems);
}

 final  List<ProductCatalog> _catalogs;
@override@JsonKey() List<ProductCatalog> get catalogs {
  if (_catalogs is EqualUnmodifiableListView) return _catalogs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_catalogs);
}

@override final  String? selectedCategoryId;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  bool isEditing;
 final  Set<String> _expandedProductIds;
@override@JsonKey() Set<String> get expandedProductIds {
  if (_expandedProductIds is EqualUnmodifiableSetView) return _expandedProductIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_expandedProductIds);
}

@override final  String? error;

/// Create a copy of ProductState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductStateDataCopyWith<ProductStateData> get copyWith => _$ProductStateDataCopyWithImpl<ProductStateData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductStateData&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._products, _products)&&const DeepCollectionEquality().equals(other._allProducts, _allProducts)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._inventoryItems, _inventoryItems)&&const DeepCollectionEquality().equals(other._catalogs, _catalogs)&&(identical(other.selectedCategoryId, selectedCategoryId) || other.selectedCategoryId == selectedCategoryId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&const DeepCollectionEquality().equals(other._expandedProductIds, _expandedProductIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_allProducts),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_inventoryItems),const DeepCollectionEquality().hash(_catalogs),selectedCategoryId,searchQuery,isEditing,const DeepCollectionEquality().hash(_expandedProductIds),error);

@override
String toString() {
  return 'ProductState(isLoading: $isLoading, products: $products, allProducts: $allProducts, categories: $categories, inventoryItems: $inventoryItems, catalogs: $catalogs, selectedCategoryId: $selectedCategoryId, searchQuery: $searchQuery, isEditing: $isEditing, expandedProductIds: $expandedProductIds, error: $error)';
}


}

/// @nodoc
abstract mixin class $ProductStateDataCopyWith<$Res> implements $ProductStateCopyWith<$Res> {
  factory $ProductStateDataCopyWith(ProductStateData value, $Res Function(ProductStateData) _then) = _$ProductStateDataCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<Product> products, List<Product> allProducts, List<ProductCategory> categories, List<InventoryItem> inventoryItems, List<ProductCatalog> catalogs, String? selectedCategoryId, String searchQuery, bool isEditing, Set<String> expandedProductIds, String? error
});




}
/// @nodoc
class _$ProductStateDataCopyWithImpl<$Res>
    implements $ProductStateDataCopyWith<$Res> {
  _$ProductStateDataCopyWithImpl(this._self, this._then);

  final ProductStateData _self;
  final $Res Function(ProductStateData) _then;

/// Create a copy of ProductState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? products = null,Object? allProducts = null,Object? categories = null,Object? inventoryItems = null,Object? catalogs = null,Object? selectedCategoryId = freezed,Object? searchQuery = null,Object? isEditing = null,Object? expandedProductIds = null,Object? error = freezed,}) {
  return _then(ProductStateData(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,allProducts: null == allProducts ? _self._allProducts : allProducts // ignore: cast_nullable_to_non_nullable
as List<Product>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<ProductCategory>,inventoryItems: null == inventoryItems ? _self._inventoryItems : inventoryItems // ignore: cast_nullable_to_non_nullable
as List<InventoryItem>,catalogs: null == catalogs ? _self._catalogs : catalogs // ignore: cast_nullable_to_non_nullable
as List<ProductCatalog>,selectedCategoryId: freezed == selectedCategoryId ? _self.selectedCategoryId : selectedCategoryId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,expandedProductIds: null == expandedProductIds ? _self._expandedProductIds : expandedProductIds // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
