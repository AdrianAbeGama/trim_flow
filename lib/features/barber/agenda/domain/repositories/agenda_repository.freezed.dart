// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agenda_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalkInRequest {

 String get tenantId; String get branchId; String get barberId; String get serviceId; DateTime get startTime; String get customerName; String get customerPhone;
/// Create a copy of WalkInRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalkInRequestCopyWith<WalkInRequest> get copyWith => _$WalkInRequestCopyWithImpl<WalkInRequest>(this as WalkInRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalkInRequest&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone));
}


@override
int get hashCode => Object.hash(runtimeType,tenantId,branchId,barberId,serviceId,startTime,customerName,customerPhone);

@override
String toString() {
  return 'WalkInRequest(tenantId: $tenantId, branchId: $branchId, barberId: $barberId, serviceId: $serviceId, startTime: $startTime, customerName: $customerName, customerPhone: $customerPhone)';
}


}

/// @nodoc
abstract mixin class $WalkInRequestCopyWith<$Res>  {
  factory $WalkInRequestCopyWith(WalkInRequest value, $Res Function(WalkInRequest) _then) = _$WalkInRequestCopyWithImpl;
@useResult
$Res call({
 String tenantId, String branchId, String barberId, String serviceId, DateTime startTime, String customerName, String customerPhone
});




}
/// @nodoc
class _$WalkInRequestCopyWithImpl<$Res>
    implements $WalkInRequestCopyWith<$Res> {
  _$WalkInRequestCopyWithImpl(this._self, this._then);

  final WalkInRequest _self;
  final $Res Function(WalkInRequest) _then;

/// Create a copy of WalkInRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? branchId = null,Object? barberId = null,Object? serviceId = null,Object? startTime = null,Object? customerName = null,Object? customerPhone = null,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,barberId: null == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WalkInRequest].
extension WalkInRequestPatterns on WalkInRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalkInRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalkInRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalkInRequest value)  $default,){
final _that = this;
switch (_that) {
case _WalkInRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalkInRequest value)?  $default,){
final _that = this;
switch (_that) {
case _WalkInRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  String branchId,  String barberId,  String serviceId,  DateTime startTime,  String customerName,  String customerPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalkInRequest() when $default != null:
return $default(_that.tenantId,_that.branchId,_that.barberId,_that.serviceId,_that.startTime,_that.customerName,_that.customerPhone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  String branchId,  String barberId,  String serviceId,  DateTime startTime,  String customerName,  String customerPhone)  $default,) {final _that = this;
switch (_that) {
case _WalkInRequest():
return $default(_that.tenantId,_that.branchId,_that.barberId,_that.serviceId,_that.startTime,_that.customerName,_that.customerPhone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  String branchId,  String barberId,  String serviceId,  DateTime startTime,  String customerName,  String customerPhone)?  $default,) {final _that = this;
switch (_that) {
case _WalkInRequest() when $default != null:
return $default(_that.tenantId,_that.branchId,_that.barberId,_that.serviceId,_that.startTime,_that.customerName,_that.customerPhone);case _:
  return null;

}
}

}

/// @nodoc


class _WalkInRequest implements WalkInRequest {
  const _WalkInRequest({required this.tenantId, required this.branchId, required this.barberId, required this.serviceId, required this.startTime, required this.customerName, required this.customerPhone});
  

@override final  String tenantId;
@override final  String branchId;
@override final  String barberId;
@override final  String serviceId;
@override final  DateTime startTime;
@override final  String customerName;
@override final  String customerPhone;

/// Create a copy of WalkInRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalkInRequestCopyWith<_WalkInRequest> get copyWith => __$WalkInRequestCopyWithImpl<_WalkInRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalkInRequest&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone));
}


@override
int get hashCode => Object.hash(runtimeType,tenantId,branchId,barberId,serviceId,startTime,customerName,customerPhone);

@override
String toString() {
  return 'WalkInRequest(tenantId: $tenantId, branchId: $branchId, barberId: $barberId, serviceId: $serviceId, startTime: $startTime, customerName: $customerName, customerPhone: $customerPhone)';
}


}

/// @nodoc
abstract mixin class _$WalkInRequestCopyWith<$Res> implements $WalkInRequestCopyWith<$Res> {
  factory _$WalkInRequestCopyWith(_WalkInRequest value, $Res Function(_WalkInRequest) _then) = __$WalkInRequestCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, String branchId, String barberId, String serviceId, DateTime startTime, String customerName, String customerPhone
});




}
/// @nodoc
class __$WalkInRequestCopyWithImpl<$Res>
    implements _$WalkInRequestCopyWith<$Res> {
  __$WalkInRequestCopyWithImpl(this._self, this._then);

  final _WalkInRequest _self;
  final $Res Function(_WalkInRequest) _then;

/// Create a copy of WalkInRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? branchId = null,Object? barberId = null,Object? serviceId = null,Object? startTime = null,Object? customerName = null,Object? customerPhone = null,}) {
  return _then(_WalkInRequest(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String,barberId: null == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: null == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AgendaLookupRefs {

 String? get defaultBranchId; String? get defaultServiceId;
/// Create a copy of AgendaLookupRefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaLookupRefsCopyWith<AgendaLookupRefs> get copyWith => _$AgendaLookupRefsCopyWithImpl<AgendaLookupRefs>(this as AgendaLookupRefs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaLookupRefs&&(identical(other.defaultBranchId, defaultBranchId) || other.defaultBranchId == defaultBranchId)&&(identical(other.defaultServiceId, defaultServiceId) || other.defaultServiceId == defaultServiceId));
}


@override
int get hashCode => Object.hash(runtimeType,defaultBranchId,defaultServiceId);

@override
String toString() {
  return 'AgendaLookupRefs(defaultBranchId: $defaultBranchId, defaultServiceId: $defaultServiceId)';
}


}

/// @nodoc
abstract mixin class $AgendaLookupRefsCopyWith<$Res>  {
  factory $AgendaLookupRefsCopyWith(AgendaLookupRefs value, $Res Function(AgendaLookupRefs) _then) = _$AgendaLookupRefsCopyWithImpl;
@useResult
$Res call({
 String? defaultBranchId, String? defaultServiceId
});




}
/// @nodoc
class _$AgendaLookupRefsCopyWithImpl<$Res>
    implements $AgendaLookupRefsCopyWith<$Res> {
  _$AgendaLookupRefsCopyWithImpl(this._self, this._then);

  final AgendaLookupRefs _self;
  final $Res Function(AgendaLookupRefs) _then;

/// Create a copy of AgendaLookupRefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultBranchId = freezed,Object? defaultServiceId = freezed,}) {
  return _then(_self.copyWith(
defaultBranchId: freezed == defaultBranchId ? _self.defaultBranchId : defaultBranchId // ignore: cast_nullable_to_non_nullable
as String?,defaultServiceId: freezed == defaultServiceId ? _self.defaultServiceId : defaultServiceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AgendaLookupRefs].
extension AgendaLookupRefsPatterns on AgendaLookupRefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgendaLookupRefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgendaLookupRefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgendaLookupRefs value)  $default,){
final _that = this;
switch (_that) {
case _AgendaLookupRefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgendaLookupRefs value)?  $default,){
final _that = this;
switch (_that) {
case _AgendaLookupRefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? defaultBranchId,  String? defaultServiceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgendaLookupRefs() when $default != null:
return $default(_that.defaultBranchId,_that.defaultServiceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? defaultBranchId,  String? defaultServiceId)  $default,) {final _that = this;
switch (_that) {
case _AgendaLookupRefs():
return $default(_that.defaultBranchId,_that.defaultServiceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? defaultBranchId,  String? defaultServiceId)?  $default,) {final _that = this;
switch (_that) {
case _AgendaLookupRefs() when $default != null:
return $default(_that.defaultBranchId,_that.defaultServiceId);case _:
  return null;

}
}

}

/// @nodoc


class _AgendaLookupRefs implements AgendaLookupRefs {
  const _AgendaLookupRefs({this.defaultBranchId, this.defaultServiceId});
  

@override final  String? defaultBranchId;
@override final  String? defaultServiceId;

/// Create a copy of AgendaLookupRefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgendaLookupRefsCopyWith<_AgendaLookupRefs> get copyWith => __$AgendaLookupRefsCopyWithImpl<_AgendaLookupRefs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgendaLookupRefs&&(identical(other.defaultBranchId, defaultBranchId) || other.defaultBranchId == defaultBranchId)&&(identical(other.defaultServiceId, defaultServiceId) || other.defaultServiceId == defaultServiceId));
}


@override
int get hashCode => Object.hash(runtimeType,defaultBranchId,defaultServiceId);

@override
String toString() {
  return 'AgendaLookupRefs(defaultBranchId: $defaultBranchId, defaultServiceId: $defaultServiceId)';
}


}

/// @nodoc
abstract mixin class _$AgendaLookupRefsCopyWith<$Res> implements $AgendaLookupRefsCopyWith<$Res> {
  factory _$AgendaLookupRefsCopyWith(_AgendaLookupRefs value, $Res Function(_AgendaLookupRefs) _then) = __$AgendaLookupRefsCopyWithImpl;
@override @useResult
$Res call({
 String? defaultBranchId, String? defaultServiceId
});




}
/// @nodoc
class __$AgendaLookupRefsCopyWithImpl<$Res>
    implements _$AgendaLookupRefsCopyWith<$Res> {
  __$AgendaLookupRefsCopyWithImpl(this._self, this._then);

  final _AgendaLookupRefs _self;
  final $Res Function(_AgendaLookupRefs) _then;

/// Create a copy of AgendaLookupRefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultBranchId = freezed,Object? defaultServiceId = freezed,}) {
  return _then(_AgendaLookupRefs(
defaultBranchId: freezed == defaultBranchId ? _self.defaultBranchId : defaultBranchId // ignore: cast_nullable_to_non_nullable
as String?,defaultServiceId: freezed == defaultServiceId ? _self.defaultServiceId : defaultServiceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
