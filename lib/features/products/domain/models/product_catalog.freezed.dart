// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductCatalog {

 String get id; String get name; bool get isActive;
/// Create a copy of ProductCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCatalogCopyWith<ProductCatalog> get copyWith => _$ProductCatalogCopyWithImpl<ProductCatalog>(this as ProductCatalog, _$identity);

  /// Serializes this ProductCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductCatalog&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isActive);

@override
String toString() {
  return 'ProductCatalog(id: $id, name: $name, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $ProductCatalogCopyWith<$Res>  {
  factory $ProductCatalogCopyWith(ProductCatalog value, $Res Function(ProductCatalog) _then) = _$ProductCatalogCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isActive
});




}
/// @nodoc
class _$ProductCatalogCopyWithImpl<$Res>
    implements $ProductCatalogCopyWith<$Res> {
  _$ProductCatalogCopyWithImpl(this._self, this._then);

  final ProductCatalog _self;
  final $Res Function(ProductCatalog) _then;

/// Create a copy of ProductCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductCatalog].
extension ProductCatalogPatterns on ProductCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductCatalog value)  $default,){
final _that = this;
switch (_that) {
case _ProductCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _ProductCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductCatalog() when $default != null:
return $default(_that.id,_that.name,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _ProductCatalog():
return $default(_that.id,_that.name,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _ProductCatalog() when $default != null:
return $default(_that.id,_that.name,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductCatalog implements ProductCatalog {
  const _ProductCatalog({required this.id, required this.name, this.isActive = false});
  factory _ProductCatalog.fromJson(Map<String, dynamic> json) => _$ProductCatalogFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool isActive;

/// Create a copy of ProductCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCatalogCopyWith<_ProductCatalog> get copyWith => __$ProductCatalogCopyWithImpl<_ProductCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductCatalog&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isActive);

@override
String toString() {
  return 'ProductCatalog(id: $id, name: $name, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$ProductCatalogCopyWith<$Res> implements $ProductCatalogCopyWith<$Res> {
  factory _$ProductCatalogCopyWith(_ProductCatalog value, $Res Function(_ProductCatalog) _then) = __$ProductCatalogCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isActive
});




}
/// @nodoc
class __$ProductCatalogCopyWithImpl<$Res>
    implements _$ProductCatalogCopyWith<$Res> {
  __$ProductCatalogCopyWithImpl(this._self, this._then);

  final _ProductCatalog _self;
  final $Res Function(_ProductCatalog) _then;

/// Create a copy of ProductCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isActive = null,}) {
  return _then(_ProductCatalog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
