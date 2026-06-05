// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agenda_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AgendaEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent()';
}


}

/// @nodoc
class $AgendaEventCopyWith<$Res>  {
$AgendaEventCopyWith(AgendaEvent _, $Res Function(AgendaEvent) __);
}


/// Adds pattern-matching-related methods to [AgendaEvent].
extension AgendaEventPatterns on AgendaEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AgendaStarted value)?  started,TResult Function( AgendaRefreshRequested value)?  refreshRequested,TResult Function( AgendaDaySelected value)?  daySelected,TResult Function( AgendaViewModeChanged value)?  viewModeChanged,TResult Function( AgendaRealtimeTicked value)?  realtimeTicked,TResult Function( AgendaWalkInRequested value)?  walkInRequested,TResult Function( AgendaResolveRefsRequested value)?  resolveRefsRequested,TResult Function( AgendaStatusChanged value)?  statusChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AgendaStarted() when started != null:
return started(_that);case AgendaRefreshRequested() when refreshRequested != null:
return refreshRequested(_that);case AgendaDaySelected() when daySelected != null:
return daySelected(_that);case AgendaViewModeChanged() when viewModeChanged != null:
return viewModeChanged(_that);case AgendaRealtimeTicked() when realtimeTicked != null:
return realtimeTicked(_that);case AgendaWalkInRequested() when walkInRequested != null:
return walkInRequested(_that);case AgendaResolveRefsRequested() when resolveRefsRequested != null:
return resolveRefsRequested(_that);case AgendaStatusChanged() when statusChanged != null:
return statusChanged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AgendaStarted value)  started,required TResult Function( AgendaRefreshRequested value)  refreshRequested,required TResult Function( AgendaDaySelected value)  daySelected,required TResult Function( AgendaViewModeChanged value)  viewModeChanged,required TResult Function( AgendaRealtimeTicked value)  realtimeTicked,required TResult Function( AgendaWalkInRequested value)  walkInRequested,required TResult Function( AgendaResolveRefsRequested value)  resolveRefsRequested,required TResult Function( AgendaStatusChanged value)  statusChanged,}){
final _that = this;
switch (_that) {
case AgendaStarted():
return started(_that);case AgendaRefreshRequested():
return refreshRequested(_that);case AgendaDaySelected():
return daySelected(_that);case AgendaViewModeChanged():
return viewModeChanged(_that);case AgendaRealtimeTicked():
return realtimeTicked(_that);case AgendaWalkInRequested():
return walkInRequested(_that);case AgendaResolveRefsRequested():
return resolveRefsRequested(_that);case AgendaStatusChanged():
return statusChanged(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AgendaStarted value)?  started,TResult? Function( AgendaRefreshRequested value)?  refreshRequested,TResult? Function( AgendaDaySelected value)?  daySelected,TResult? Function( AgendaViewModeChanged value)?  viewModeChanged,TResult? Function( AgendaRealtimeTicked value)?  realtimeTicked,TResult? Function( AgendaWalkInRequested value)?  walkInRequested,TResult? Function( AgendaResolveRefsRequested value)?  resolveRefsRequested,TResult? Function( AgendaStatusChanged value)?  statusChanged,}){
final _that = this;
switch (_that) {
case AgendaStarted() when started != null:
return started(_that);case AgendaRefreshRequested() when refreshRequested != null:
return refreshRequested(_that);case AgendaDaySelected() when daySelected != null:
return daySelected(_that);case AgendaViewModeChanged() when viewModeChanged != null:
return viewModeChanged(_that);case AgendaRealtimeTicked() when realtimeTicked != null:
return realtimeTicked(_that);case AgendaWalkInRequested() when walkInRequested != null:
return walkInRequested(_that);case AgendaResolveRefsRequested() when resolveRefsRequested != null:
return resolveRefsRequested(_that);case AgendaStatusChanged() when statusChanged != null:
return statusChanged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  refreshRequested,TResult Function( DateTime day)?  daySelected,TResult Function( AgendaViewMode mode)?  viewModeChanged,TResult Function()?  realtimeTicked,TResult Function( WalkInRequest request)?  walkInRequested,TResult Function()?  resolveRefsRequested,TResult Function( String appointmentId,  AgendaStatus newStatus,  String? reason)?  statusChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AgendaStarted() when started != null:
return started();case AgendaRefreshRequested() when refreshRequested != null:
return refreshRequested();case AgendaDaySelected() when daySelected != null:
return daySelected(_that.day);case AgendaViewModeChanged() when viewModeChanged != null:
return viewModeChanged(_that.mode);case AgendaRealtimeTicked() when realtimeTicked != null:
return realtimeTicked();case AgendaWalkInRequested() when walkInRequested != null:
return walkInRequested(_that.request);case AgendaResolveRefsRequested() when resolveRefsRequested != null:
return resolveRefsRequested();case AgendaStatusChanged() when statusChanged != null:
return statusChanged(_that.appointmentId,_that.newStatus,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  refreshRequested,required TResult Function( DateTime day)  daySelected,required TResult Function( AgendaViewMode mode)  viewModeChanged,required TResult Function()  realtimeTicked,required TResult Function( WalkInRequest request)  walkInRequested,required TResult Function()  resolveRefsRequested,required TResult Function( String appointmentId,  AgendaStatus newStatus,  String? reason)  statusChanged,}) {final _that = this;
switch (_that) {
case AgendaStarted():
return started();case AgendaRefreshRequested():
return refreshRequested();case AgendaDaySelected():
return daySelected(_that.day);case AgendaViewModeChanged():
return viewModeChanged(_that.mode);case AgendaRealtimeTicked():
return realtimeTicked();case AgendaWalkInRequested():
return walkInRequested(_that.request);case AgendaResolveRefsRequested():
return resolveRefsRequested();case AgendaStatusChanged():
return statusChanged(_that.appointmentId,_that.newStatus,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  refreshRequested,TResult? Function( DateTime day)?  daySelected,TResult? Function( AgendaViewMode mode)?  viewModeChanged,TResult? Function()?  realtimeTicked,TResult? Function( WalkInRequest request)?  walkInRequested,TResult? Function()?  resolveRefsRequested,TResult? Function( String appointmentId,  AgendaStatus newStatus,  String? reason)?  statusChanged,}) {final _that = this;
switch (_that) {
case AgendaStarted() when started != null:
return started();case AgendaRefreshRequested() when refreshRequested != null:
return refreshRequested();case AgendaDaySelected() when daySelected != null:
return daySelected(_that.day);case AgendaViewModeChanged() when viewModeChanged != null:
return viewModeChanged(_that.mode);case AgendaRealtimeTicked() when realtimeTicked != null:
return realtimeTicked();case AgendaWalkInRequested() when walkInRequested != null:
return walkInRequested(_that.request);case AgendaResolveRefsRequested() when resolveRefsRequested != null:
return resolveRefsRequested();case AgendaStatusChanged() when statusChanged != null:
return statusChanged(_that.appointmentId,_that.newStatus,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class AgendaStarted implements AgendaEvent {
  const AgendaStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.started()';
}


}




/// @nodoc


class AgendaRefreshRequested implements AgendaEvent {
  const AgendaRefreshRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaRefreshRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.refreshRequested()';
}


}




/// @nodoc


class AgendaDaySelected implements AgendaEvent {
  const AgendaDaySelected(this.day);
  

 final  DateTime day;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaDaySelectedCopyWith<AgendaDaySelected> get copyWith => _$AgendaDaySelectedCopyWithImpl<AgendaDaySelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaDaySelected&&(identical(other.day, day) || other.day == day));
}


@override
int get hashCode => Object.hash(runtimeType,day);

@override
String toString() {
  return 'AgendaEvent.daySelected(day: $day)';
}


}

/// @nodoc
abstract mixin class $AgendaDaySelectedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory $AgendaDaySelectedCopyWith(AgendaDaySelected value, $Res Function(AgendaDaySelected) _then) = _$AgendaDaySelectedCopyWithImpl;
@useResult
$Res call({
 DateTime day
});




}
/// @nodoc
class _$AgendaDaySelectedCopyWithImpl<$Res>
    implements $AgendaDaySelectedCopyWith<$Res> {
  _$AgendaDaySelectedCopyWithImpl(this._self, this._then);

  final AgendaDaySelected _self;
  final $Res Function(AgendaDaySelected) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? day = null,}) {
  return _then(AgendaDaySelected(
null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class AgendaViewModeChanged implements AgendaEvent {
  const AgendaViewModeChanged(this.mode);
  

 final  AgendaViewMode mode;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaViewModeChangedCopyWith<AgendaViewModeChanged> get copyWith => _$AgendaViewModeChangedCopyWithImpl<AgendaViewModeChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaViewModeChanged&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'AgendaEvent.viewModeChanged(mode: $mode)';
}


}

/// @nodoc
abstract mixin class $AgendaViewModeChangedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory $AgendaViewModeChangedCopyWith(AgendaViewModeChanged value, $Res Function(AgendaViewModeChanged) _then) = _$AgendaViewModeChangedCopyWithImpl;
@useResult
$Res call({
 AgendaViewMode mode
});




}
/// @nodoc
class _$AgendaViewModeChangedCopyWithImpl<$Res>
    implements $AgendaViewModeChangedCopyWith<$Res> {
  _$AgendaViewModeChangedCopyWithImpl(this._self, this._then);

  final AgendaViewModeChanged _self;
  final $Res Function(AgendaViewModeChanged) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(AgendaViewModeChanged(
null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AgendaViewMode,
  ));
}


}

/// @nodoc


class AgendaRealtimeTicked implements AgendaEvent {
  const AgendaRealtimeTicked();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaRealtimeTicked);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.realtimeTicked()';
}


}




/// @nodoc


class AgendaWalkInRequested implements AgendaEvent {
  const AgendaWalkInRequested(this.request);
  

 final  WalkInRequest request;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaWalkInRequestedCopyWith<AgendaWalkInRequested> get copyWith => _$AgendaWalkInRequestedCopyWithImpl<AgendaWalkInRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaWalkInRequested&&(identical(other.request, request) || other.request == request));
}


@override
int get hashCode => Object.hash(runtimeType,request);

@override
String toString() {
  return 'AgendaEvent.walkInRequested(request: $request)';
}


}

/// @nodoc
abstract mixin class $AgendaWalkInRequestedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory $AgendaWalkInRequestedCopyWith(AgendaWalkInRequested value, $Res Function(AgendaWalkInRequested) _then) = _$AgendaWalkInRequestedCopyWithImpl;
@useResult
$Res call({
 WalkInRequest request
});


$WalkInRequestCopyWith<$Res> get request;

}
/// @nodoc
class _$AgendaWalkInRequestedCopyWithImpl<$Res>
    implements $AgendaWalkInRequestedCopyWith<$Res> {
  _$AgendaWalkInRequestedCopyWithImpl(this._self, this._then);

  final AgendaWalkInRequested _self;
  final $Res Function(AgendaWalkInRequested) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? request = null,}) {
  return _then(AgendaWalkInRequested(
null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as WalkInRequest,
  ));
}

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalkInRequestCopyWith<$Res> get request {
  
  return $WalkInRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

/// @nodoc


class AgendaResolveRefsRequested implements AgendaEvent {
  const AgendaResolveRefsRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaResolveRefsRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AgendaEvent.resolveRefsRequested()';
}


}




/// @nodoc


class AgendaStatusChanged implements AgendaEvent {
  const AgendaStatusChanged(this.appointmentId, this.newStatus, {this.reason});
  

 final  String appointmentId;
 final  AgendaStatus newStatus;
 final  String? reason;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgendaStatusChangedCopyWith<AgendaStatusChanged> get copyWith => _$AgendaStatusChangedCopyWithImpl<AgendaStatusChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgendaStatusChanged&&(identical(other.appointmentId, appointmentId) || other.appointmentId == appointmentId)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,appointmentId,newStatus,reason);

@override
String toString() {
  return 'AgendaEvent.statusChanged(appointmentId: $appointmentId, newStatus: $newStatus, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AgendaStatusChangedCopyWith<$Res> implements $AgendaEventCopyWith<$Res> {
  factory $AgendaStatusChangedCopyWith(AgendaStatusChanged value, $Res Function(AgendaStatusChanged) _then) = _$AgendaStatusChangedCopyWithImpl;
@useResult
$Res call({
 String appointmentId, AgendaStatus newStatus, String? reason
});




}
/// @nodoc
class _$AgendaStatusChangedCopyWithImpl<$Res>
    implements $AgendaStatusChangedCopyWith<$Res> {
  _$AgendaStatusChangedCopyWithImpl(this._self, this._then);

  final AgendaStatusChanged _self;
  final $Res Function(AgendaStatusChanged) _then;

/// Create a copy of AgendaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? appointmentId = null,Object? newStatus = null,Object? reason = freezed,}) {
  return _then(AgendaStatusChanged(
null == appointmentId ? _self.appointmentId : appointmentId // ignore: cast_nullable_to_non_nullable
as String,null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as AgendaStatus,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
