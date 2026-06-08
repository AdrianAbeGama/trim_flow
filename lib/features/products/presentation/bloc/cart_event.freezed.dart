// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CartEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CartEvent()';
}


}

/// @nodoc
class $CartEventCopyWith<$Res>  {
$CartEventCopyWith(CartEvent _, $Res Function(CartEvent) __);
}


/// Adds pattern-matching-related methods to [CartEvent].
extension CartEventPatterns on CartEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _AddItem value)?  addItem,TResult Function( _RemoveItem value)?  removeItem,TResult Function( _UpdateQuantity value)?  updateQuantity,TResult Function( _Clear value)?  clear,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _AddItem() when addItem != null:
return addItem(_that);case _RemoveItem() when removeItem != null:
return removeItem(_that);case _UpdateQuantity() when updateQuantity != null:
return updateQuantity(_that);case _Clear() when clear != null:
return clear(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _AddItem value)  addItem,required TResult Function( _RemoveItem value)  removeItem,required TResult Function( _UpdateQuantity value)  updateQuantity,required TResult Function( _Clear value)  clear,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _AddItem():
return addItem(_that);case _RemoveItem():
return removeItem(_that);case _UpdateQuantity():
return updateQuantity(_that);case _Clear():
return clear(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _AddItem value)?  addItem,TResult? Function( _RemoveItem value)?  removeItem,TResult? Function( _UpdateQuantity value)?  updateQuantity,TResult? Function( _Clear value)?  clear,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _AddItem() when addItem != null:
return addItem(_that);case _RemoveItem() when removeItem != null:
return removeItem(_that);case _UpdateQuantity() when updateQuantity != null:
return updateQuantity(_that);case _Clear() when clear != null:
return clear(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( Product product)?  addItem,TResult Function( String productId)?  removeItem,TResult Function( String productId,  int delta)?  updateQuantity,TResult Function()?  clear,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _AddItem() when addItem != null:
return addItem(_that.product);case _RemoveItem() when removeItem != null:
return removeItem(_that.productId);case _UpdateQuantity() when updateQuantity != null:
return updateQuantity(_that.productId,_that.delta);case _Clear() when clear != null:
return clear();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( Product product)  addItem,required TResult Function( String productId)  removeItem,required TResult Function( String productId,  int delta)  updateQuantity,required TResult Function()  clear,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _AddItem():
return addItem(_that.product);case _RemoveItem():
return removeItem(_that.productId);case _UpdateQuantity():
return updateQuantity(_that.productId,_that.delta);case _Clear():
return clear();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( Product product)?  addItem,TResult? Function( String productId)?  removeItem,TResult? Function( String productId,  int delta)?  updateQuantity,TResult? Function()?  clear,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _AddItem() when addItem != null:
return addItem(_that.product);case _RemoveItem() when removeItem != null:
return removeItem(_that.productId);case _UpdateQuantity() when updateQuantity != null:
return updateQuantity(_that.productId,_that.delta);case _Clear() when clear != null:
return clear();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements CartEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CartEvent.started()';
}


}




/// @nodoc


class _AddItem implements CartEvent {
  const _AddItem(this.product);
  

 final  Product product;

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddItemCopyWith<_AddItem> get copyWith => __$AddItemCopyWithImpl<_AddItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddItem&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,product);

@override
String toString() {
  return 'CartEvent.addItem(product: $product)';
}


}

/// @nodoc
abstract mixin class _$AddItemCopyWith<$Res> implements $CartEventCopyWith<$Res> {
  factory _$AddItemCopyWith(_AddItem value, $Res Function(_AddItem) _then) = __$AddItemCopyWithImpl;
@useResult
$Res call({
 Product product
});


$ProductCopyWith<$Res> get product;

}
/// @nodoc
class __$AddItemCopyWithImpl<$Res>
    implements _$AddItemCopyWith<$Res> {
  __$AddItemCopyWithImpl(this._self, this._then);

  final _AddItem _self;
  final $Res Function(_AddItem) _then;

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,}) {
  return _then(_AddItem(
null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,
  ));
}

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}

/// @nodoc


class _RemoveItem implements CartEvent {
  const _RemoveItem(this.productId);
  

 final  String productId;

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoveItemCopyWith<_RemoveItem> get copyWith => __$RemoveItemCopyWithImpl<_RemoveItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoveItem&&(identical(other.productId, productId) || other.productId == productId));
}


@override
int get hashCode => Object.hash(runtimeType,productId);

@override
String toString() {
  return 'CartEvent.removeItem(productId: $productId)';
}


}

/// @nodoc
abstract mixin class _$RemoveItemCopyWith<$Res> implements $CartEventCopyWith<$Res> {
  factory _$RemoveItemCopyWith(_RemoveItem value, $Res Function(_RemoveItem) _then) = __$RemoveItemCopyWithImpl;
@useResult
$Res call({
 String productId
});




}
/// @nodoc
class __$RemoveItemCopyWithImpl<$Res>
    implements _$RemoveItemCopyWith<$Res> {
  __$RemoveItemCopyWithImpl(this._self, this._then);

  final _RemoveItem _self;
  final $Res Function(_RemoveItem) _then;

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? productId = null,}) {
  return _then(_RemoveItem(
null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UpdateQuantity implements CartEvent {
  const _UpdateQuantity(this.productId, this.delta);
  

 final  String productId;
 final  int delta;

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateQuantityCopyWith<_UpdateQuantity> get copyWith => __$UpdateQuantityCopyWithImpl<_UpdateQuantity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateQuantity&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.delta, delta) || other.delta == delta));
}


@override
int get hashCode => Object.hash(runtimeType,productId,delta);

@override
String toString() {
  return 'CartEvent.updateQuantity(productId: $productId, delta: $delta)';
}


}

/// @nodoc
abstract mixin class _$UpdateQuantityCopyWith<$Res> implements $CartEventCopyWith<$Res> {
  factory _$UpdateQuantityCopyWith(_UpdateQuantity value, $Res Function(_UpdateQuantity) _then) = __$UpdateQuantityCopyWithImpl;
@useResult
$Res call({
 String productId, int delta
});




}
/// @nodoc
class __$UpdateQuantityCopyWithImpl<$Res>
    implements _$UpdateQuantityCopyWith<$Res> {
  __$UpdateQuantityCopyWithImpl(this._self, this._then);

  final _UpdateQuantity _self;
  final $Res Function(_UpdateQuantity) _then;

/// Create a copy of CartEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? delta = null,}) {
  return _then(_UpdateQuantity(
null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Clear implements CartEvent {
  const _Clear();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Clear);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CartEvent.clear()';
}


}




// dart format on
