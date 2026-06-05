// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerCoupon {

 String get id; String get code; String get name; String get discountType; double get discountValue; DateTime get validUntil; DateTime? get redeemedAt; bool get promoActive;
/// Create a copy of CustomerCoupon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerCouponCopyWith<CustomerCoupon> get copyWith => _$CustomerCouponCopyWithImpl<CustomerCoupon>(this as CustomerCoupon, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerCoupon&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.promoActive, promoActive) || other.promoActive == promoActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,code,name,discountType,discountValue,validUntil,redeemedAt,promoActive);

@override
String toString() {
  return 'CustomerCoupon(id: $id, code: $code, name: $name, discountType: $discountType, discountValue: $discountValue, validUntil: $validUntil, redeemedAt: $redeemedAt, promoActive: $promoActive)';
}


}

/// @nodoc
abstract mixin class $CustomerCouponCopyWith<$Res>  {
  factory $CustomerCouponCopyWith(CustomerCoupon value, $Res Function(CustomerCoupon) _then) = _$CustomerCouponCopyWithImpl;
@useResult
$Res call({
 String id, String code, String name, String discountType, double discountValue, DateTime validUntil, DateTime? redeemedAt, bool promoActive
});




}
/// @nodoc
class _$CustomerCouponCopyWithImpl<$Res>
    implements $CustomerCouponCopyWith<$Res> {
  _$CustomerCouponCopyWithImpl(this._self, this._then);

  final CustomerCoupon _self;
  final $Res Function(CustomerCoupon) _then;

/// Create a copy of CustomerCoupon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? discountType = null,Object? discountValue = null,Object? validUntil = null,Object? redeemedAt = freezed,Object? promoActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as double,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,redeemedAt: freezed == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,promoActive: null == promoActive ? _self.promoActive : promoActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerCoupon].
extension CustomerCouponPatterns on CustomerCoupon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerCoupon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerCoupon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerCoupon value)  $default,){
final _that = this;
switch (_that) {
case _CustomerCoupon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerCoupon value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerCoupon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String discountType,  double discountValue,  DateTime validUntil,  DateTime? redeemedAt,  bool promoActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerCoupon() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.discountType,_that.discountValue,_that.validUntil,_that.redeemedAt,_that.promoActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String discountType,  double discountValue,  DateTime validUntil,  DateTime? redeemedAt,  bool promoActive)  $default,) {final _that = this;
switch (_that) {
case _CustomerCoupon():
return $default(_that.id,_that.code,_that.name,_that.discountType,_that.discountValue,_that.validUntil,_that.redeemedAt,_that.promoActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String name,  String discountType,  double discountValue,  DateTime validUntil,  DateTime? redeemedAt,  bool promoActive)?  $default,) {final _that = this;
switch (_that) {
case _CustomerCoupon() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.discountType,_that.discountValue,_that.validUntil,_that.redeemedAt,_that.promoActive);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerCoupon extends CustomerCoupon {
  const _CustomerCoupon({required this.id, required this.code, required this.name, required this.discountType, required this.discountValue, required this.validUntil, this.redeemedAt, this.promoActive = true}): super._();
  

@override final  String id;
@override final  String code;
@override final  String name;
@override final  String discountType;
@override final  double discountValue;
@override final  DateTime validUntil;
@override final  DateTime? redeemedAt;
@override@JsonKey() final  bool promoActive;

/// Create a copy of CustomerCoupon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerCouponCopyWith<_CustomerCoupon> get copyWith => __$CustomerCouponCopyWithImpl<_CustomerCoupon>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerCoupon&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.promoActive, promoActive) || other.promoActive == promoActive));
}


@override
int get hashCode => Object.hash(runtimeType,id,code,name,discountType,discountValue,validUntil,redeemedAt,promoActive);

@override
String toString() {
  return 'CustomerCoupon(id: $id, code: $code, name: $name, discountType: $discountType, discountValue: $discountValue, validUntil: $validUntil, redeemedAt: $redeemedAt, promoActive: $promoActive)';
}


}

/// @nodoc
abstract mixin class _$CustomerCouponCopyWith<$Res> implements $CustomerCouponCopyWith<$Res> {
  factory _$CustomerCouponCopyWith(_CustomerCoupon value, $Res Function(_CustomerCoupon) _then) = __$CustomerCouponCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String name, String discountType, double discountValue, DateTime validUntil, DateTime? redeemedAt, bool promoActive
});




}
/// @nodoc
class __$CustomerCouponCopyWithImpl<$Res>
    implements _$CustomerCouponCopyWith<$Res> {
  __$CustomerCouponCopyWithImpl(this._self, this._then);

  final _CustomerCoupon _self;
  final $Res Function(_CustomerCoupon) _then;

/// Create a copy of CustomerCoupon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? discountType = null,Object? discountValue = null,Object? validUntil = null,Object? redeemedAt = freezed,Object? promoActive = null,}) {
  return _then(_CustomerCoupon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as double,validUntil: null == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime,redeemedAt: freezed == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,promoActive: null == promoActive ? _self.promoActive : promoActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
