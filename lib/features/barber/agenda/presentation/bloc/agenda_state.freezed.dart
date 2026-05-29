// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agenda_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgendaUiState {

 AgendaStatusUi get status; AgendaViewMode get viewMode; DateTime get selectedDay; List<AgendaAppointment> get appointments; AgendaLookupRefs? get lookupRefs; String? get errorMessage; bool get isBusy;
/// Create a copy of AgendaUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaUiStateCopyWith<AgendaUiState> get copyWith => _$AgendaUiStateCopyWithImpl<AgendaUiState>(this as AgendaUiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaUiState&&(identical(other.status, status) || other.status == status)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&const DeepCollectionEquality().equals(other.appointments, appointments)&&(identical(other.lookupRefs, lookupRefs) || other.lookupRefs == lookupRefs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy));
}


@override
int get hashCode => Object.hash(runtimeType,status,viewMode,selectedDay,const DeepCollectionEquality().hash(appointments),lookupRefs,errorMessage,isBusy);

@override
String toString() {
  return 'AgendaUiState(status: $status, viewMode: $viewMode, selectedDay: $selectedDay, appointments: $appointments, lookupRefs: $lookupRefs, errorMessage: $errorMessage, isBusy: $isBusy)';
}


}

/// @nodoc
abstract mixin class $AgendaUiStateCopyWith<$Res>  {
  factory $AgendaUiStateCopyWith(AgendaUiState value, $Res Function(AgendaUiState) _then) = _$AgendaUiStateCopyWithImpl;
@useResult
$Res call({
 AgendaStatusUi status, AgendaViewMode viewMode, DateTime selectedDay, List<AgendaAppointment> appointments, AgendaLookupRefs? lookupRefs, String? errorMessage, bool isBusy
});


$AgendaLookupRefsCopyWith<$Res>? get lookupRefs;

}
/// @nodoc
class _$AgendaUiStateCopyWithImpl<$Res>
    implements $AgendaUiStateCopyWith<$Res> {
  _$AgendaUiStateCopyWithImpl(this._self, this._then);

  final AgendaUiState _self;
  final $Res Function(AgendaUiState) _then;

/// Create a copy of AgendaUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? viewMode = null,Object? selectedDay = null,Object? appointments = null,Object? lookupRefs = freezed,Object? errorMessage = freezed,Object? isBusy = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AgendaStatusUi,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as AgendaViewMode,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime,appointments: null == appointments ? _self.appointments : appointments // ignore: cast_nullable_to_non_nullable
as List<AgendaAppointment>,lookupRefs: freezed == lookupRefs ? _self.lookupRefs : lookupRefs // ignore: cast_nullable_to_non_nullable
as AgendaLookupRefs?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AgendaUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgendaLookupRefsCopyWith<$Res>? get lookupRefs {
    if (_self.lookupRefs == null) {
    return null;
  }

  return $AgendaLookupRefsCopyWith<$Res>(_self.lookupRefs!, (value) {
    return _then(_self.copyWith(lookupRefs: value));
  });
}
}


/// Adds pattern-matching-related methods to [AgendaUiState].
extension AgendaUiStatePatterns on AgendaUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AgendaUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AgendaUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AgendaUiState value)  $default,){
final _that = this;
switch (_that) {
case _AgendaUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AgendaUiState value)?  $default,){
final _that = this;
switch (_that) {
case _AgendaUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AgendaStatusUi status,  AgendaViewMode viewMode,  DateTime selectedDay,  List<AgendaAppointment> appointments,  AgendaLookupRefs? lookupRefs,  String? errorMessage,  bool isBusy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AgendaUiState() when $default != null:
return $default(_that.status,_that.viewMode,_that.selectedDay,_that.appointments,_that.lookupRefs,_that.errorMessage,_that.isBusy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AgendaStatusUi status,  AgendaViewMode viewMode,  DateTime selectedDay,  List<AgendaAppointment> appointments,  AgendaLookupRefs? lookupRefs,  String? errorMessage,  bool isBusy)  $default,) {final _that = this;
switch (_that) {
case _AgendaUiState():
return $default(_that.status,_that.viewMode,_that.selectedDay,_that.appointments,_that.lookupRefs,_that.errorMessage,_that.isBusy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AgendaStatusUi status,  AgendaViewMode viewMode,  DateTime selectedDay,  List<AgendaAppointment> appointments,  AgendaLookupRefs? lookupRefs,  String? errorMessage,  bool isBusy)?  $default,) {final _that = this;
switch (_that) {
case _AgendaUiState() when $default != null:
return $default(_that.status,_that.viewMode,_that.selectedDay,_that.appointments,_that.lookupRefs,_that.errorMessage,_that.isBusy);case _:
  return null;

}
}

}

/// @nodoc


class _AgendaUiState implements AgendaUiState {
  const _AgendaUiState({this.status = AgendaStatusUi.initial, this.viewMode = AgendaViewMode.list, required this.selectedDay, final  List<AgendaAppointment> appointments = const <AgendaAppointment>[], this.lookupRefs, this.errorMessage, this.isBusy = false}): _appointments = appointments;
  

@override@JsonKey() final  AgendaStatusUi status;
@override@JsonKey() final  AgendaViewMode viewMode;
@override final  DateTime selectedDay;
 final  List<AgendaAppointment> _appointments;
@override@JsonKey() List<AgendaAppointment> get appointments {
  if (_appointments is EqualUnmodifiableListView) return _appointments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_appointments);
}

@override final  AgendaLookupRefs? lookupRefs;
@override final  String? errorMessage;
@override@JsonKey() final  bool isBusy;

/// Create a copy of AgendaUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgendaUiStateCopyWith<_AgendaUiState> get copyWith => __$AgendaUiStateCopyWithImpl<_AgendaUiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AgendaUiState&&(identical(other.status, status) || other.status == status)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&const DeepCollectionEquality().equals(other._appointments, _appointments)&&(identical(other.lookupRefs, lookupRefs) || other.lookupRefs == lookupRefs)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy));
}


@override
int get hashCode => Object.hash(runtimeType,status,viewMode,selectedDay,const DeepCollectionEquality().hash(_appointments),lookupRefs,errorMessage,isBusy);

@override
String toString() {
  return 'AgendaUiState(status: $status, viewMode: $viewMode, selectedDay: $selectedDay, appointments: $appointments, lookupRefs: $lookupRefs, errorMessage: $errorMessage, isBusy: $isBusy)';
}


}

/// @nodoc
abstract mixin class _$AgendaUiStateCopyWith<$Res> implements $AgendaUiStateCopyWith<$Res> {
  factory _$AgendaUiStateCopyWith(_AgendaUiState value, $Res Function(_AgendaUiState) _then) = __$AgendaUiStateCopyWithImpl;
@override @useResult
$Res call({
 AgendaStatusUi status, AgendaViewMode viewMode, DateTime selectedDay, List<AgendaAppointment> appointments, AgendaLookupRefs? lookupRefs, String? errorMessage, bool isBusy
});


@override $AgendaLookupRefsCopyWith<$Res>? get lookupRefs;

}
/// @nodoc
class __$AgendaUiStateCopyWithImpl<$Res>
    implements _$AgendaUiStateCopyWith<$Res> {
  __$AgendaUiStateCopyWithImpl(this._self, this._then);

  final _AgendaUiState _self;
  final $Res Function(_AgendaUiState) _then;

/// Create a copy of AgendaUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? viewMode = null,Object? selectedDay = null,Object? appointments = null,Object? lookupRefs = freezed,Object? errorMessage = freezed,Object? isBusy = null,}) {
  return _then(_AgendaUiState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AgendaStatusUi,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as AgendaViewMode,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime,appointments: null == appointments ? _self._appointments : appointments // ignore: cast_nullable_to_non_nullable
as List<AgendaAppointment>,lookupRefs: freezed == lookupRefs ? _self.lookupRefs : lookupRefs // ignore: cast_nullable_to_non_nullable
as AgendaLookupRefs?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AgendaUiState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AgendaLookupRefsCopyWith<$Res>? get lookupRefs {
    if (_self.lookupRefs == null) {
    return null;
  }

  return $AgendaLookupRefsCopyWith<$Res>(_self.lookupRefs!, (value) {
    return _then(_self.copyWith(lookupRefs: value));
  });
}
}

// dart format on
