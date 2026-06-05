// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamMember {

 String get tenantId; String get id; String get fullName; int get yearsOfExperience; String? get specialty; String? get avatarUrl; String? get branchId;
/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<TeamMember> get copyWith => _$TeamMemberCopyWithImpl<TeamMember>(this as TeamMember, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMember&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.branchId, branchId) || other.branchId == branchId));
}


@override
int get hashCode => Object.hash(runtimeType,tenantId,id,fullName,yearsOfExperience,specialty,avatarUrl,branchId);

@override
String toString() {
  return 'TeamMember(tenantId: $tenantId, id: $id, fullName: $fullName, yearsOfExperience: $yearsOfExperience, specialty: $specialty, avatarUrl: $avatarUrl, branchId: $branchId)';
}


}

/// @nodoc
abstract mixin class $TeamMemberCopyWith<$Res>  {
  factory $TeamMemberCopyWith(TeamMember value, $Res Function(TeamMember) _then) = _$TeamMemberCopyWithImpl;
@useResult
$Res call({
 String tenantId, String id, String fullName, int yearsOfExperience, String? specialty, String? avatarUrl, String? branchId
});




}
/// @nodoc
class _$TeamMemberCopyWithImpl<$Res>
    implements $TeamMemberCopyWith<$Res> {
  _$TeamMemberCopyWithImpl(this._self, this._then);

  final TeamMember _self;
  final $Res Function(TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? id = null,Object? fullName = null,Object? yearsOfExperience = null,Object? specialty = freezed,Object? avatarUrl = freezed,Object? branchId = freezed,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMember].
extension TeamMemberPatterns on TeamMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMember value)  $default,){
final _that = this;
switch (_that) {
case _TeamMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMember value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  String id,  String fullName,  int yearsOfExperience,  String? specialty,  String? avatarUrl,  String? branchId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.tenantId,_that.id,_that.fullName,_that.yearsOfExperience,_that.specialty,_that.avatarUrl,_that.branchId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  String id,  String fullName,  int yearsOfExperience,  String? specialty,  String? avatarUrl,  String? branchId)  $default,) {final _that = this;
switch (_that) {
case _TeamMember():
return $default(_that.tenantId,_that.id,_that.fullName,_that.yearsOfExperience,_that.specialty,_that.avatarUrl,_that.branchId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  String id,  String fullName,  int yearsOfExperience,  String? specialty,  String? avatarUrl,  String? branchId)?  $default,) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.tenantId,_that.id,_that.fullName,_that.yearsOfExperience,_that.specialty,_that.avatarUrl,_that.branchId);case _:
  return null;

}
}

}

/// @nodoc


class _TeamMember extends TeamMember {
  const _TeamMember({required this.tenantId, required this.id, required this.fullName, this.yearsOfExperience = 0, this.specialty, this.avatarUrl, this.branchId}): super._();
  

@override final  String tenantId;
@override final  String id;
@override final  String fullName;
@override@JsonKey() final  int yearsOfExperience;
@override final  String? specialty;
@override final  String? avatarUrl;
@override final  String? branchId;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberCopyWith<_TeamMember> get copyWith => __$TeamMemberCopyWithImpl<_TeamMember>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMember&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.yearsOfExperience, yearsOfExperience) || other.yearsOfExperience == yearsOfExperience)&&(identical(other.specialty, specialty) || other.specialty == specialty)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.branchId, branchId) || other.branchId == branchId));
}


@override
int get hashCode => Object.hash(runtimeType,tenantId,id,fullName,yearsOfExperience,specialty,avatarUrl,branchId);

@override
String toString() {
  return 'TeamMember(tenantId: $tenantId, id: $id, fullName: $fullName, yearsOfExperience: $yearsOfExperience, specialty: $specialty, avatarUrl: $avatarUrl, branchId: $branchId)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberCopyWith<$Res> implements $TeamMemberCopyWith<$Res> {
  factory _$TeamMemberCopyWith(_TeamMember value, $Res Function(_TeamMember) _then) = __$TeamMemberCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, String id, String fullName, int yearsOfExperience, String? specialty, String? avatarUrl, String? branchId
});




}
/// @nodoc
class __$TeamMemberCopyWithImpl<$Res>
    implements _$TeamMemberCopyWith<$Res> {
  __$TeamMemberCopyWithImpl(this._self, this._then);

  final _TeamMember _self;
  final $Res Function(_TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? id = null,Object? fullName = null,Object? yearsOfExperience = null,Object? specialty = freezed,Object? avatarUrl = freezed,Object? branchId = freezed,}) {
  return _then(_TeamMember(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,yearsOfExperience: null == yearsOfExperience ? _self.yearsOfExperience : yearsOfExperience // ignore: cast_nullable_to_non_nullable
as int,specialty: freezed == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TenantCatalog {

 List<BarberCenter> get centers; List<Service> get services; List<TeamMember> get team;
/// Create a copy of TenantCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantCatalogCopyWith<TenantCatalog> get copyWith => _$TenantCatalogCopyWithImpl<TenantCatalog>(this as TenantCatalog, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantCatalog&&const DeepCollectionEquality().equals(other.centers, centers)&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.team, team));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(centers),const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(team));

@override
String toString() {
  return 'TenantCatalog(centers: $centers, services: $services, team: $team)';
}


}

/// @nodoc
abstract mixin class $TenantCatalogCopyWith<$Res>  {
  factory $TenantCatalogCopyWith(TenantCatalog value, $Res Function(TenantCatalog) _then) = _$TenantCatalogCopyWithImpl;
@useResult
$Res call({
 List<BarberCenter> centers, List<Service> services, List<TeamMember> team
});




}
/// @nodoc
class _$TenantCatalogCopyWithImpl<$Res>
    implements $TenantCatalogCopyWith<$Res> {
  _$TenantCatalogCopyWithImpl(this._self, this._then);

  final TenantCatalog _self;
  final $Res Function(TenantCatalog) _then;

/// Create a copy of TenantCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? centers = null,Object? services = null,Object? team = null,}) {
  return _then(_self.copyWith(
centers: null == centers ? _self.centers : centers // ignore: cast_nullable_to_non_nullable
as List<BarberCenter>,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<Service>,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantCatalog].
extension TenantCatalogPatterns on TenantCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantCatalog value)  $default,){
final _that = this;
switch (_that) {
case _TenantCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _TenantCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BarberCenter> centers,  List<Service> services,  List<TeamMember> team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantCatalog() when $default != null:
return $default(_that.centers,_that.services,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BarberCenter> centers,  List<Service> services,  List<TeamMember> team)  $default,) {final _that = this;
switch (_that) {
case _TenantCatalog():
return $default(_that.centers,_that.services,_that.team);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BarberCenter> centers,  List<Service> services,  List<TeamMember> team)?  $default,) {final _that = this;
switch (_that) {
case _TenantCatalog() when $default != null:
return $default(_that.centers,_that.services,_that.team);case _:
  return null;

}
}

}

/// @nodoc


class _TenantCatalog implements TenantCatalog {
  const _TenantCatalog({final  List<BarberCenter> centers = const <BarberCenter>[], final  List<Service> services = const <Service>[], final  List<TeamMember> team = const <TeamMember>[]}): _centers = centers,_services = services,_team = team;
  

 final  List<BarberCenter> _centers;
@override@JsonKey() List<BarberCenter> get centers {
  if (_centers is EqualUnmodifiableListView) return _centers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_centers);
}

 final  List<Service> _services;
@override@JsonKey() List<Service> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<TeamMember> _team;
@override@JsonKey() List<TeamMember> get team {
  if (_team is EqualUnmodifiableListView) return _team;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_team);
}


/// Create a copy of TenantCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantCatalogCopyWith<_TenantCatalog> get copyWith => __$TenantCatalogCopyWithImpl<_TenantCatalog>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantCatalog&&const DeepCollectionEquality().equals(other._centers, _centers)&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._team, _team));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_centers),const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_team));

@override
String toString() {
  return 'TenantCatalog(centers: $centers, services: $services, team: $team)';
}


}

/// @nodoc
abstract mixin class _$TenantCatalogCopyWith<$Res> implements $TenantCatalogCopyWith<$Res> {
  factory _$TenantCatalogCopyWith(_TenantCatalog value, $Res Function(_TenantCatalog) _then) = __$TenantCatalogCopyWithImpl;
@override @useResult
$Res call({
 List<BarberCenter> centers, List<Service> services, List<TeamMember> team
});




}
/// @nodoc
class __$TenantCatalogCopyWithImpl<$Res>
    implements _$TenantCatalogCopyWith<$Res> {
  __$TenantCatalogCopyWithImpl(this._self, this._then);

  final _TenantCatalog _self;
  final $Res Function(_TenantCatalog) _then;

/// Create a copy of TenantCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? centers = null,Object? services = null,Object? team = null,}) {
  return _then(_TenantCatalog(
centers: null == centers ? _self._centers : centers // ignore: cast_nullable_to_non_nullable
as List<BarberCenter>,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<Service>,team: null == team ? _self._team : team // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,
  ));
}


}

// dart format on
