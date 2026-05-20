// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductOrder {

 String get id; List<CartItem> get items; double get total; PaymentMethod get paymentMethod; DateTime get createdAt; String get status;
/// Create a copy of ProductOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductOrderCopyWith<ProductOrder> get copyWith => _$ProductOrderCopyWithImpl<ProductOrder>(this as ProductOrder, _$identity);

  /// Serializes this ProductOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductOrder&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(items),total,paymentMethod,createdAt,status);

@override
String toString() {
  return 'ProductOrder(id: $id, items: $items, total: $total, paymentMethod: $paymentMethod, createdAt: $createdAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $ProductOrderCopyWith<$Res>  {
  factory $ProductOrderCopyWith(ProductOrder value, $Res Function(ProductOrder) _then) = _$ProductOrderCopyWithImpl;
@useResult
$Res call({
 String id, List<CartItem> items, double total, PaymentMethod paymentMethod, DateTime createdAt, String status
});




}
/// @nodoc
class _$ProductOrderCopyWithImpl<$Res>
    implements $ProductOrderCopyWith<$Res> {
  _$ProductOrderCopyWithImpl(this._self, this._then);

  final ProductOrder _self;
  final $Res Function(ProductOrder) _then;

/// Create a copy of ProductOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? total = null,Object? paymentMethod = null,Object? createdAt = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductOrder].
extension ProductOrderPatterns on ProductOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductOrder value)  $default,){
final _that = this;
switch (_that) {
case _ProductOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductOrder value)?  $default,){
final _that = this;
switch (_that) {
case _ProductOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<CartItem> items,  double total,  PaymentMethod paymentMethod,  DateTime createdAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductOrder() when $default != null:
return $default(_that.id,_that.items,_that.total,_that.paymentMethod,_that.createdAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<CartItem> items,  double total,  PaymentMethod paymentMethod,  DateTime createdAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _ProductOrder():
return $default(_that.id,_that.items,_that.total,_that.paymentMethod,_that.createdAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<CartItem> items,  double total,  PaymentMethod paymentMethod,  DateTime createdAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _ProductOrder() when $default != null:
return $default(_that.id,_that.items,_that.total,_that.paymentMethod,_that.createdAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductOrder implements ProductOrder {
  const _ProductOrder({required this.id, required final  List<CartItem> items, required this.total, required this.paymentMethod, required this.createdAt, this.status = 'PENDIENTE'}): _items = items;
  factory _ProductOrder.fromJson(Map<String, dynamic> json) => _$ProductOrderFromJson(json);

@override final  String id;
 final  List<CartItem> _items;
@override List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double total;
@override final  PaymentMethod paymentMethod;
@override final  DateTime createdAt;
@override@JsonKey() final  String status;

/// Create a copy of ProductOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductOrderCopyWith<_ProductOrder> get copyWith => __$ProductOrderCopyWithImpl<_ProductOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductOrder&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items),total,paymentMethod,createdAt,status);

@override
String toString() {
  return 'ProductOrder(id: $id, items: $items, total: $total, paymentMethod: $paymentMethod, createdAt: $createdAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ProductOrderCopyWith<$Res> implements $ProductOrderCopyWith<$Res> {
  factory _$ProductOrderCopyWith(_ProductOrder value, $Res Function(_ProductOrder) _then) = __$ProductOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, List<CartItem> items, double total, PaymentMethod paymentMethod, DateTime createdAt, String status
});




}
/// @nodoc
class __$ProductOrderCopyWithImpl<$Res>
    implements _$ProductOrderCopyWith<$Res> {
  __$ProductOrderCopyWithImpl(this._self, this._then);

  final _ProductOrder _self;
  final $Res Function(_ProductOrder) _then;

/// Create a copy of ProductOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? total = null,Object? paymentMethod = null,Object? createdAt = null,Object? status = null,}) {
  return _then(_ProductOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
