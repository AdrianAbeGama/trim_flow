// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orders_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrdersEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OrdersEvent()';
}


}

/// @nodoc
class $OrdersEventCopyWith<$Res>  {
$OrdersEventCopyWith(OrdersEvent _, $Res Function(OrdersEvent) __);
}


/// Adds pattern-matching-related methods to [OrdersEvent].
extension OrdersEventPatterns on OrdersEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OrdersStarted value)?  started,TResult Function( OrdersPlaceOrder value)?  placeOrder,TResult Function( OrdersCancelOrder value)?  cancelOrder,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OrdersStarted() when started != null:
return started(_that);case OrdersPlaceOrder() when placeOrder != null:
return placeOrder(_that);case OrdersCancelOrder() when cancelOrder != null:
return cancelOrder(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OrdersStarted value)  started,required TResult Function( OrdersPlaceOrder value)  placeOrder,required TResult Function( OrdersCancelOrder value)  cancelOrder,}){
final _that = this;
switch (_that) {
case OrdersStarted():
return started(_that);case OrdersPlaceOrder():
return placeOrder(_that);case OrdersCancelOrder():
return cancelOrder(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OrdersStarted value)?  started,TResult? Function( OrdersPlaceOrder value)?  placeOrder,TResult? Function( OrdersCancelOrder value)?  cancelOrder,}){
final _that = this;
switch (_that) {
case OrdersStarted() when started != null:
return started(_that);case OrdersPlaceOrder() when placeOrder != null:
return placeOrder(_that);case OrdersCancelOrder() when cancelOrder != null:
return cancelOrder(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( List<CartItem> items,  double total,  PaymentMethod paymentMethod)?  placeOrder,TResult Function( String orderId,  String reason)?  cancelOrder,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OrdersStarted() when started != null:
return started();case OrdersPlaceOrder() when placeOrder != null:
return placeOrder(_that.items,_that.total,_that.paymentMethod);case OrdersCancelOrder() when cancelOrder != null:
return cancelOrder(_that.orderId,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( List<CartItem> items,  double total,  PaymentMethod paymentMethod)  placeOrder,required TResult Function( String orderId,  String reason)  cancelOrder,}) {final _that = this;
switch (_that) {
case OrdersStarted():
return started();case OrdersPlaceOrder():
return placeOrder(_that.items,_that.total,_that.paymentMethod);case OrdersCancelOrder():
return cancelOrder(_that.orderId,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( List<CartItem> items,  double total,  PaymentMethod paymentMethod)?  placeOrder,TResult? Function( String orderId,  String reason)?  cancelOrder,}) {final _that = this;
switch (_that) {
case OrdersStarted() when started != null:
return started();case OrdersPlaceOrder() when placeOrder != null:
return placeOrder(_that.items,_that.total,_that.paymentMethod);case OrdersCancelOrder() when cancelOrder != null:
return cancelOrder(_that.orderId,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class OrdersStarted implements OrdersEvent {
  const OrdersStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OrdersEvent.started()';
}


}




/// @nodoc


class OrdersPlaceOrder implements OrdersEvent {
  const OrdersPlaceOrder({required final  List<CartItem> items, required this.total, required this.paymentMethod}): _items = items;
  

 final  List<CartItem> _items;
 List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  double total;
 final  PaymentMethod paymentMethod;

/// Create a copy of OrdersEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersPlaceOrderCopyWith<OrdersPlaceOrder> get copyWith => _$OrdersPlaceOrderCopyWithImpl<OrdersPlaceOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersPlaceOrder&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,paymentMethod);

@override
String toString() {
  return 'OrdersEvent.placeOrder(items: $items, total: $total, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class $OrdersPlaceOrderCopyWith<$Res> implements $OrdersEventCopyWith<$Res> {
  factory $OrdersPlaceOrderCopyWith(OrdersPlaceOrder value, $Res Function(OrdersPlaceOrder) _then) = _$OrdersPlaceOrderCopyWithImpl;
@useResult
$Res call({
 List<CartItem> items, double total, PaymentMethod paymentMethod
});




}
/// @nodoc
class _$OrdersPlaceOrderCopyWithImpl<$Res>
    implements $OrdersPlaceOrderCopyWith<$Res> {
  _$OrdersPlaceOrderCopyWithImpl(this._self, this._then);

  final OrdersPlaceOrder _self;
  final $Res Function(OrdersPlaceOrder) _then;

/// Create a copy of OrdersEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? paymentMethod = null,}) {
  return _then(OrdersPlaceOrder(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,
  ));
}


}

/// @nodoc


class OrdersCancelOrder implements OrdersEvent {
  const OrdersCancelOrder({required this.orderId, required this.reason});
  

 final  String orderId;
 final  String reason;

/// Create a copy of OrdersEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrdersCancelOrderCopyWith<OrdersCancelOrder> get copyWith => _$OrdersCancelOrderCopyWithImpl<OrdersCancelOrder>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrdersCancelOrder&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,orderId,reason);

@override
String toString() {
  return 'OrdersEvent.cancelOrder(orderId: $orderId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $OrdersCancelOrderCopyWith<$Res> implements $OrdersEventCopyWith<$Res> {
  factory $OrdersCancelOrderCopyWith(OrdersCancelOrder value, $Res Function(OrdersCancelOrder) _then) = _$OrdersCancelOrderCopyWithImpl;
@useResult
$Res call({
 String orderId, String reason
});




}
/// @nodoc
class _$OrdersCancelOrderCopyWithImpl<$Res>
    implements $OrdersCancelOrderCopyWith<$Res> {
  _$OrdersCancelOrderCopyWithImpl(this._self, this._then);

  final OrdersCancelOrder _self;
  final $Res Function(OrdersCancelOrder) _then;

/// Create a copy of OrdersEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? reason = null,}) {
  return _then(OrdersCancelOrder(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
