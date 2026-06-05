// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orders_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrdersState {

 List<ProductOrder> get orders; ProductOrder? get lastPlaced;
/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersStateCopyWith<OrdersState> get copyWith => _$OrdersStateCopyWithImpl<OrdersState>(this as OrdersState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersState&&const DeepCollectionEquality().equals(other.orders, orders)&&(identical(other.lastPlaced, lastPlaced) || other.lastPlaced == lastPlaced));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(orders),lastPlaced);

@override
String toString() {
  return 'OrdersState(orders: $orders, lastPlaced: $lastPlaced)';
}


}

/// @nodoc
abstract mixin class $OrdersStateCopyWith<$Res>  {
  factory $OrdersStateCopyWith(OrdersState value, $Res Function(OrdersState) _then) = _$OrdersStateCopyWithImpl;
@useResult
$Res call({
 List<ProductOrder> orders, ProductOrder? lastPlaced
});


$ProductOrderCopyWith<$Res>? get lastPlaced;

}
/// @nodoc
class _$OrdersStateCopyWithImpl<$Res>
    implements $OrdersStateCopyWith<$Res> {
  _$OrdersStateCopyWithImpl(this._self, this._then);

  final OrdersState _self;
  final $Res Function(OrdersState) _then;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orders = null,Object? lastPlaced = freezed,}) {
  return _then(_self.copyWith(
orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<ProductOrder>,lastPlaced: freezed == lastPlaced ? _self.lastPlaced : lastPlaced // ignore: cast_nullable_to_non_nullable
as ProductOrder?,
  ));
}
/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductOrderCopyWith<$Res>? get lastPlaced {
    if (_self.lastPlaced == null) {
    return null;
  }

  return $ProductOrderCopyWith<$Res>(_self.lastPlaced!, (value) {
    return _then(_self.copyWith(lastPlaced: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrdersState].
extension OrdersStatePatterns on OrdersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrdersState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrdersState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrdersState value)  $default,){
final _that = this;
switch (_that) {
case _OrdersState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrdersState value)?  $default,){
final _that = this;
switch (_that) {
case _OrdersState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProductOrder> orders,  ProductOrder? lastPlaced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrdersState() when $default != null:
return $default(_that.orders,_that.lastPlaced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProductOrder> orders,  ProductOrder? lastPlaced)  $default,) {final _that = this;
switch (_that) {
case _OrdersState():
return $default(_that.orders,_that.lastPlaced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProductOrder> orders,  ProductOrder? lastPlaced)?  $default,) {final _that = this;
switch (_that) {
case _OrdersState() when $default != null:
return $default(_that.orders,_that.lastPlaced);case _:
  return null;

}
}

}

/// @nodoc


class _OrdersState implements OrdersState {
  const _OrdersState({final  List<ProductOrder> orders = const <ProductOrder>[], this.lastPlaced}): _orders = orders;
  

 final  List<ProductOrder> _orders;
@override@JsonKey() List<ProductOrder> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

@override final  ProductOrder? lastPlaced;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrdersStateCopyWith<_OrdersState> get copyWith => __$OrdersStateCopyWithImpl<_OrdersState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrdersState&&const DeepCollectionEquality().equals(other._orders, _orders)&&(identical(other.lastPlaced, lastPlaced) || other.lastPlaced == lastPlaced));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_orders),lastPlaced);

@override
String toString() {
  return 'OrdersState(orders: $orders, lastPlaced: $lastPlaced)';
}


}

/// @nodoc
abstract mixin class _$OrdersStateCopyWith<$Res> implements $OrdersStateCopyWith<$Res> {
  factory _$OrdersStateCopyWith(_OrdersState value, $Res Function(_OrdersState) _then) = __$OrdersStateCopyWithImpl;
@override @useResult
$Res call({
 List<ProductOrder> orders, ProductOrder? lastPlaced
});


@override $ProductOrderCopyWith<$Res>? get lastPlaced;

}
/// @nodoc
class __$OrdersStateCopyWithImpl<$Res>
    implements _$OrdersStateCopyWith<$Res> {
  __$OrdersStateCopyWithImpl(this._self, this._then);

  final _OrdersState _self;
  final $Res Function(_OrdersState) _then;

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orders = null,Object? lastPlaced = freezed,}) {
  return _then(_OrdersState(
orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<ProductOrder>,lastPlaced: freezed == lastPlaced ? _self.lastPlaced : lastPlaced // ignore: cast_nullable_to_non_nullable
as ProductOrder?,
  ));
}

/// Create a copy of OrdersState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductOrderCopyWith<$Res>? get lastPlaced {
    if (_self.lastPlaced == null) {
    return null;
  }

  return $ProductOrderCopyWith<$Res>(_self.lastPlaced!, (value) {
    return _then(_self.copyWith(lastPlaced: value));
  });
}
}

// dart format on
