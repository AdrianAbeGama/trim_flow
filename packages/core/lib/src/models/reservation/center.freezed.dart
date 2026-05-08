// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'center.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BarberCenter {

 String get tenantId; String get id; String get name; String get location; String? get imageUrl;
/// Create a copy of BarberCenter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarberCenterCopyWith<BarberCenter> get copyWith => _$BarberCenterCopyWithImpl<BarberCenter>(this as BarberCenter, _$identity);

  /// Serializes this BarberCenter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BarberCenter&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,name,location,imageUrl);

@override
String toString() {
  return 'BarberCenter(tenantId: $tenantId, id: $id, name: $name, location: $location, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $BarberCenterCopyWith<$Res>  {
  factory $BarberCenterCopyWith(BarberCenter value, $Res Function(BarberCenter) _then) = _$BarberCenterCopyWithImpl;
@useResult
$Res call({
 String tenantId, String id, String name, String location, String? imageUrl
});




}
/// @nodoc
class _$BarberCenterCopyWithImpl<$Res>
    implements $BarberCenterCopyWith<$Res> {
  _$BarberCenterCopyWithImpl(this._self, this._then);

  final BarberCenter _self;
  final $Res Function(BarberCenter) _then;

/// Create a copy of BarberCenter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? id = null,Object? name = null,Object? location = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BarberCenter].
extension BarberCenterPatterns on BarberCenter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BarberCenter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BarberCenter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BarberCenter value)  $default,){
final _that = this;
switch (_that) {
case _BarberCenter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BarberCenter value)?  $default,){
final _that = this;
switch (_that) {
case _BarberCenter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  String id,  String name,  String location,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BarberCenter() when $default != null:
return $default(_that.tenantId,_that.id,_that.name,_that.location,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  String id,  String name,  String location,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _BarberCenter():
return $default(_that.tenantId,_that.id,_that.name,_that.location,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  String id,  String name,  String location,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _BarberCenter() when $default != null:
return $default(_that.tenantId,_that.id,_that.name,_that.location,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BarberCenter implements BarberCenter {
  const _BarberCenter({required this.tenantId, required this.id, required this.name, required this.location, this.imageUrl});
  factory _BarberCenter.fromJson(Map<String, dynamic> json) => _$BarberCenterFromJson(json);

@override final  String tenantId;
@override final  String id;
@override final  String name;
@override final  String location;
@override final  String? imageUrl;

/// Create a copy of BarberCenter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BarberCenterCopyWith<_BarberCenter> get copyWith => __$BarberCenterCopyWithImpl<_BarberCenter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BarberCenterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BarberCenter&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,name,location,imageUrl);

@override
String toString() {
  return 'BarberCenter(tenantId: $tenantId, id: $id, name: $name, location: $location, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$BarberCenterCopyWith<$Res> implements $BarberCenterCopyWith<$Res> {
  factory _$BarberCenterCopyWith(_BarberCenter value, $Res Function(_BarberCenter) _then) = __$BarberCenterCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, String id, String name, String location, String? imageUrl
});




}
/// @nodoc
class __$BarberCenterCopyWithImpl<$Res>
    implements _$BarberCenterCopyWith<$Res> {
  __$BarberCenterCopyWithImpl(this._self, this._then);

  final _BarberCenter _self;
  final $Res Function(_BarberCenter) _then;

/// Create a copy of BarberCenter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? id = null,Object? name = null,Object? location = null,Object? imageUrl = freezed,}) {
  return _then(_BarberCenter(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
