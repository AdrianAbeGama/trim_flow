// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get name; String get description; double get price; String get imageUrl; String get categoryId; String get barcode; bool get isFavorite; int get stock; int get crossAxisCellCount; int get mainAxisCellCount; String? get inventoryItemId;// Vínculo con inventario
 String? get catalogId;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.crossAxisCellCount, crossAxisCellCount) || other.crossAxisCellCount == crossAxisCellCount)&&(identical(other.mainAxisCellCount, mainAxisCellCount) || other.mainAxisCellCount == mainAxisCellCount)&&(identical(other.inventoryItemId, inventoryItemId) || other.inventoryItemId == inventoryItemId)&&(identical(other.catalogId, catalogId) || other.catalogId == catalogId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,imageUrl,categoryId,barcode,isFavorite,stock,crossAxisCellCount,mainAxisCellCount,inventoryItemId,catalogId);

@override
String toString() {
  return 'Product(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl, categoryId: $categoryId, barcode: $barcode, isFavorite: $isFavorite, stock: $stock, crossAxisCellCount: $crossAxisCellCount, mainAxisCellCount: $mainAxisCellCount, inventoryItemId: $inventoryItemId, catalogId: $catalogId)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, double price, String imageUrl, String categoryId, String barcode, bool isFavorite, int stock, int crossAxisCellCount, int mainAxisCellCount, String? inventoryItemId, String? catalogId
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? price = null,Object? imageUrl = null,Object? categoryId = null,Object? barcode = null,Object? isFavorite = null,Object? stock = null,Object? crossAxisCellCount = null,Object? mainAxisCellCount = null,Object? inventoryItemId = freezed,Object? catalogId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,crossAxisCellCount: null == crossAxisCellCount ? _self.crossAxisCellCount : crossAxisCellCount // ignore: cast_nullable_to_non_nullable
as int,mainAxisCellCount: null == mainAxisCellCount ? _self.mainAxisCellCount : mainAxisCellCount // ignore: cast_nullable_to_non_nullable
as int,inventoryItemId: freezed == inventoryItemId ? _self.inventoryItemId : inventoryItemId // ignore: cast_nullable_to_non_nullable
as String?,catalogId: freezed == catalogId ? _self.catalogId : catalogId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double price,  String imageUrl,  String categoryId,  String barcode,  bool isFavorite,  int stock,  int crossAxisCellCount,  int mainAxisCellCount,  String? inventoryItemId,  String? catalogId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.imageUrl,_that.categoryId,_that.barcode,_that.isFavorite,_that.stock,_that.crossAxisCellCount,_that.mainAxisCellCount,_that.inventoryItemId,_that.catalogId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double price,  String imageUrl,  String categoryId,  String barcode,  bool isFavorite,  int stock,  int crossAxisCellCount,  int mainAxisCellCount,  String? inventoryItemId,  String? catalogId)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.description,_that.price,_that.imageUrl,_that.categoryId,_that.barcode,_that.isFavorite,_that.stock,_that.crossAxisCellCount,_that.mainAxisCellCount,_that.inventoryItemId,_that.catalogId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  double price,  String imageUrl,  String categoryId,  String barcode,  bool isFavorite,  int stock,  int crossAxisCellCount,  int mainAxisCellCount,  String? inventoryItemId,  String? catalogId)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.imageUrl,_that.categoryId,_that.barcode,_that.isFavorite,_that.stock,_that.crossAxisCellCount,_that.mainAxisCellCount,_that.inventoryItemId,_that.catalogId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.name, required this.description, required this.price, required this.imageUrl, required this.categoryId, required this.barcode, this.isFavorite = false, this.stock = 0, this.crossAxisCellCount = 1, this.mainAxisCellCount = 1, this.inventoryItemId, this.catalogId});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  double price;
@override final  String imageUrl;
@override final  String categoryId;
@override final  String barcode;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  int stock;
@override@JsonKey() final  int crossAxisCellCount;
@override@JsonKey() final  int mainAxisCellCount;
@override final  String? inventoryItemId;
// Vínculo con inventario
@override final  String? catalogId;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.crossAxisCellCount, crossAxisCellCount) || other.crossAxisCellCount == crossAxisCellCount)&&(identical(other.mainAxisCellCount, mainAxisCellCount) || other.mainAxisCellCount == mainAxisCellCount)&&(identical(other.inventoryItemId, inventoryItemId) || other.inventoryItemId == inventoryItemId)&&(identical(other.catalogId, catalogId) || other.catalogId == catalogId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,imageUrl,categoryId,barcode,isFavorite,stock,crossAxisCellCount,mainAxisCellCount,inventoryItemId,catalogId);

@override
String toString() {
  return 'Product(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl, categoryId: $categoryId, barcode: $barcode, isFavorite: $isFavorite, stock: $stock, crossAxisCellCount: $crossAxisCellCount, mainAxisCellCount: $mainAxisCellCount, inventoryItemId: $inventoryItemId, catalogId: $catalogId)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, double price, String imageUrl, String categoryId, String barcode, bool isFavorite, int stock, int crossAxisCellCount, int mainAxisCellCount, String? inventoryItemId, String? catalogId
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? price = null,Object? imageUrl = null,Object? categoryId = null,Object? barcode = null,Object? isFavorite = null,Object? stock = null,Object? crossAxisCellCount = null,Object? mainAxisCellCount = null,Object? inventoryItemId = freezed,Object? catalogId = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,crossAxisCellCount: null == crossAxisCellCount ? _self.crossAxisCellCount : crossAxisCellCount // ignore: cast_nullable_to_non_nullable
as int,mainAxisCellCount: null == mainAxisCellCount ? _self.mainAxisCellCount : mainAxisCellCount // ignore: cast_nullable_to_non_nullable
as int,inventoryItemId: freezed == inventoryItemId ? _self.inventoryItemId : inventoryItemId // ignore: cast_nullable_to_non_nullable
as String?,catalogId: freezed == catalogId ? _self.catalogId : catalogId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
