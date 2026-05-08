// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'professional.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Professional {

 String get tenantId; String get id; String get name; List<String> get specialties; int get yearsOfExperience; bool get isAvailable; String? get statusLabel; String? get imageUrl;
/// Create a copy of Professional
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfessionalCopyWith<Professional> get copyWith => _$ProfessionalCopyWithImpl<Professional>(this as Professional, _$identity);

  /// Serializes this Professional to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Professional&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,name,const DeepCollectionEquality().hash(specialties),yearsOfExperience,isAvailable,statusLabel,imageUrl);

@override
String toString() {
  return 'Professional(tenantId: $tenantId, id: $id, name: $name, specialties: $specialties, yearsOfExperience: $yearsOfExperience, isAvailable: $isAvailable, statusLabel: $statusLabel, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ProfessionalCopyWith<$Res>  {
  factory $ProfessionalCopyWith(Professional value, $Res Function(Professional) _then) = _$ProfessionalCopyWithImpl;
@useResult
$Res call({
 String tenantId, String id, String name, List<String> specialties, int yearsOfExperience, bool isAvailable, String? statusLabel, String? imageUrl
});




}
/// @nodoc
class _$ProfessionalCopyWithImpl<$Res>
    implements $ProfessionalCopyWith<$Res> {
  _$ProfessionalCopyWithImpl(this._self, this._then);

  final Professional _self;
  final $Res Function(Professional) _then;

/// Create a copy of Professional
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? id = null,Object? name = null,Object? specialties = null,Object? yearsOfExperience = null,Object? isAvailable = null,Object? statusLabel = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Professional].
extension ProfessionalPatterns on Professional {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Professional value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Professional() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Professional value)  $default,){
final _that = this;
switch (_that) {
case _Professional():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Professional value)?  $default,){
final _that = this;
switch (_that) {
case _Professional() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  String id,  String name,  List<String> specialties,  int yearsOfExperience,  bool isAvailable,  String? statusLabel,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Professional() when $default != null:
return $default(_that.tenantId,_that.id,_that.name,_that.specialties,_that.yearsOfExperience,_that.isAvailable,_that.statusLabel,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  String id,  String name,  List<String> specialties,  int yearsOfExperience,  bool isAvailable,  String? statusLabel,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Professional():
return $default(_that.tenantId,_that.id,_that.name,_that.specialties,_that.yearsOfExperience,_that.isAvailable,_that.statusLabel,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  String id,  String name,  List<String> specialties,  int yearsOfExperience,  bool isAvailable,  String? statusLabel,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Professional() when $default != null:
return $default(_that.tenantId,_that.id,_that.name,_that.specialties,_that.yearsOfExperience,_that.isAvailable,_that.statusLabel,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Professional implements Professional {
  const _Professional({required this.tenantId, required this.id, required this.name, required final  List<String> specialties, required this.yearsOfExperience, this.isAvailable = true, this.statusLabel, this.imageUrl}): _specialties = specialties;
  factory _Professional.fromJson(Map<String, dynamic> json) => _$ProfessionalFromJson(json);

@override final  String tenantId;
@override final  String id;
@override final  String name;
 final  List<String> _specialties;
@override List<String> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override final  int yearsOfExperience;
@override@JsonKey() final  bool isAvailable;
@override final  String? statusLabel;
@override final  String? imageUrl;

/// Create a copy of Professional
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfessionalCopyWith<_Professional> get copyWith => __$ProfessionalCopyWithImpl<_Professional>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfessionalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Professional&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,name,const DeepCollectionEquality().hash(_specialties),yearsOfExperience,isAvailable,statusLabel,imageUrl);

@override
String toString() {
  return 'Professional(tenantId: $tenantId, id: $id, name: $name, specialties: $specialties, yearsOfExperience: $yearsOfExperience, isAvailable: $isAvailable, statusLabel: $statusLabel, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ProfessionalCopyWith<$Res> implements $ProfessionalCopyWith<$Res> {
  factory _$ProfessionalCopyWith(_Professional value, $Res Function(_Professional) _then) = __$ProfessionalCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, String id, String name, List<String> specialties, int yearsOfExperience, bool isAvailable, String? statusLabel, String? imageUrl
});




}
/// @nodoc
class __$ProfessionalCopyWithImpl<$Res>
    implements _$ProfessionalCopyWith<$Res> {
  __$ProfessionalCopyWithImpl(this._self, this._then);

  final _Professional _self;
  final $Res Function(_Professional) _then;

/// Create a copy of Professional
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? id = null,Object? name = null,Object? specialties = null,Object? yearsOfExperience = null,Object? isAvailable = null,Object? statusLabel = freezed,Object? imageUrl = freezed,}) {
  return _then(_Professional(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,statusLabel: freezed == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
