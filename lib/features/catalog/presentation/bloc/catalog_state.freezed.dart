// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CatalogState {

 CatalogStatus get status; List<BarberCenter> get centers; List<Service> get services; List<TeamMember> get team;
/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogStateCopyWith<CatalogState> get copyWith => _$CatalogStateCopyWithImpl<CatalogState>(this as CatalogState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.centers, centers)&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.team, team));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(centers),const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(team));

@override
String toString() {
  return 'CatalogState(status: $status, centers: $centers, services: $services, team: $team)';
}


}

/// @nodoc
abstract mixin class $CatalogStateCopyWith<$Res>  {
  factory $CatalogStateCopyWith(CatalogState value, $Res Function(CatalogState) _then) = _$CatalogStateCopyWithImpl;
@useResult
$Res call({
 CatalogStatus status, List<BarberCenter> centers, List<Service> services, List<TeamMember> team
});




}
/// @nodoc
class _$CatalogStateCopyWithImpl<$Res>
    implements $CatalogStateCopyWith<$Res> {
  _$CatalogStateCopyWithImpl(this._self, this._then);

  final CatalogState _self;
  final $Res Function(CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? centers = null,Object? services = null,Object? team = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CatalogStatus,centers: null == centers ? _self.centers : centers // ignore: cast_nullable_to_non_nullable
as List<BarberCenter>,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<Service>,team: null == team ? _self.team : team // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogState].
extension CatalogStatePatterns on CatalogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogState value)  $default,){
final _that = this;
switch (_that) {
case _CatalogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogState value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CatalogStatus status,  List<BarberCenter> centers,  List<Service> services,  List<TeamMember> team)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.status,_that.centers,_that.services,_that.team);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CatalogStatus status,  List<BarberCenter> centers,  List<Service> services,  List<TeamMember> team)  $default,) {final _that = this;
switch (_that) {
case _CatalogState():
return $default(_that.status,_that.centers,_that.services,_that.team);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CatalogStatus status,  List<BarberCenter> centers,  List<Service> services,  List<TeamMember> team)?  $default,) {final _that = this;
switch (_that) {
case _CatalogState() when $default != null:
return $default(_that.status,_that.centers,_that.services,_that.team);case _:
  return null;

}
}

}

/// @nodoc


class _CatalogState implements CatalogState {
  const _CatalogState({this.status = CatalogStatus.initial, final  List<BarberCenter> centers = const <BarberCenter>[], final  List<Service> services = const <Service>[], final  List<TeamMember> team = const <TeamMember>[]}): _centers = centers,_services = services,_team = team;
  

@override@JsonKey() final  CatalogStatus status;
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


/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogStateCopyWith<_CatalogState> get copyWith => __$CatalogStateCopyWithImpl<_CatalogState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._centers, _centers)&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._team, _team));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_centers),const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_team));

@override
String toString() {
  return 'CatalogState(status: $status, centers: $centers, services: $services, team: $team)';
}


}

/// @nodoc
abstract mixin class _$CatalogStateCopyWith<$Res> implements $CatalogStateCopyWith<$Res> {
  factory _$CatalogStateCopyWith(_CatalogState value, $Res Function(_CatalogState) _then) = __$CatalogStateCopyWithImpl;
@override @useResult
$Res call({
 CatalogStatus status, List<BarberCenter> centers, List<Service> services, List<TeamMember> team
});




}
/// @nodoc
class __$CatalogStateCopyWithImpl<$Res>
    implements _$CatalogStateCopyWith<$Res> {
  __$CatalogStateCopyWithImpl(this._self, this._then);

  final _CatalogState _self;
  final $Res Function(_CatalogState) _then;

/// Create a copy of CatalogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? centers = null,Object? services = null,Object? team = null,}) {
  return _then(_CatalogState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CatalogStatus,centers: null == centers ? _self._centers : centers // ignore: cast_nullable_to_non_nullable
as List<BarberCenter>,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<Service>,team: null == team ? _self._team : team // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,
  ));
}


}

// dart format on
