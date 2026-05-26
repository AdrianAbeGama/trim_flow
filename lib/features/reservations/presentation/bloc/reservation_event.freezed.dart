// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReservationEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReservationEvent()';
}


}

/// @nodoc
class $ReservationEventCopyWith<$Res>  {
$ReservationEventCopyWith(ReservationEvent _, $Res Function(ReservationEvent) __);
}


/// Adds pattern-matching-related methods to [ReservationEvent].
extension ReservationEventPatterns on ReservationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SelectCenter value)?  selectCenter,TResult Function( _ToggleService value)?  toggleService,TResult Function( _SelectProfessional value)?  selectProfessional,TResult Function( _SelectDateTime value)?  selectDateTime,TResult Function( _GoToPhase value)?  goToPhase,TResult Function( _ConfirmReservation value)?  confirmReservation,TResult Function( _ActivateDiscount value)?  activateDiscount,TResult Function( _DeactivateDiscount value)?  deactivateDiscount,TResult Function( _Reset value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectCenter() when selectCenter != null:
return selectCenter(_that);case _ToggleService() when toggleService != null:
return toggleService(_that);case _SelectProfessional() when selectProfessional != null:
return selectProfessional(_that);case _SelectDateTime() when selectDateTime != null:
return selectDateTime(_that);case _GoToPhase() when goToPhase != null:
return goToPhase(_that);case _ConfirmReservation() when confirmReservation != null:
return confirmReservation(_that);case _ActivateDiscount() when activateDiscount != null:
return activateDiscount(_that);case _DeactivateDiscount() when deactivateDiscount != null:
return deactivateDiscount(_that);case _Reset() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SelectCenter value)  selectCenter,required TResult Function( _ToggleService value)  toggleService,required TResult Function( _SelectProfessional value)  selectProfessional,required TResult Function( _SelectDateTime value)  selectDateTime,required TResult Function( _GoToPhase value)  goToPhase,required TResult Function( _ConfirmReservation value)  confirmReservation,required TResult Function( _ActivateDiscount value)  activateDiscount,required TResult Function( _DeactivateDiscount value)  deactivateDiscount,required TResult Function( _Reset value)  reset,}){
final _that = this;
switch (_that) {
case _SelectCenter():
return selectCenter(_that);case _ToggleService():
return toggleService(_that);case _SelectProfessional():
return selectProfessional(_that);case _SelectDateTime():
return selectDateTime(_that);case _GoToPhase():
return goToPhase(_that);case _ConfirmReservation():
return confirmReservation(_that);case _ActivateDiscount():
return activateDiscount(_that);case _DeactivateDiscount():
return deactivateDiscount(_that);case _Reset():
return reset(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SelectCenter value)?  selectCenter,TResult? Function( _ToggleService value)?  toggleService,TResult? Function( _SelectProfessional value)?  selectProfessional,TResult? Function( _SelectDateTime value)?  selectDateTime,TResult? Function( _GoToPhase value)?  goToPhase,TResult? Function( _ConfirmReservation value)?  confirmReservation,TResult? Function( _ActivateDiscount value)?  activateDiscount,TResult? Function( _DeactivateDiscount value)?  deactivateDiscount,TResult? Function( _Reset value)?  reset,}){
final _that = this;
switch (_that) {
case _SelectCenter() when selectCenter != null:
return selectCenter(_that);case _ToggleService() when toggleService != null:
return toggleService(_that);case _SelectProfessional() when selectProfessional != null:
return selectProfessional(_that);case _SelectDateTime() when selectDateTime != null:
return selectDateTime(_that);case _GoToPhase() when goToPhase != null:
return goToPhase(_that);case _ConfirmReservation() when confirmReservation != null:
return confirmReservation(_that);case _ActivateDiscount() when activateDiscount != null:
return activateDiscount(_that);case _DeactivateDiscount() when deactivateDiscount != null:
return deactivateDiscount(_that);case _Reset() when reset != null:
return reset(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BarberCenter center)?  selectCenter,TResult Function( Service service)?  toggleService,TResult Function( Professional? professional)?  selectProfessional,TResult Function( DateTime date,  String time)?  selectDateTime,TResult Function( int phase)?  goToPhase,TResult Function()?  confirmReservation,TResult Function()?  activateDiscount,TResult Function()?  deactivateDiscount,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectCenter() when selectCenter != null:
return selectCenter(_that.center);case _ToggleService() when toggleService != null:
return toggleService(_that.service);case _SelectProfessional() when selectProfessional != null:
return selectProfessional(_that.professional);case _SelectDateTime() when selectDateTime != null:
return selectDateTime(_that.date,_that.time);case _GoToPhase() when goToPhase != null:
return goToPhase(_that.phase);case _ConfirmReservation() when confirmReservation != null:
return confirmReservation();case _ActivateDiscount() when activateDiscount != null:
return activateDiscount();case _DeactivateDiscount() when deactivateDiscount != null:
return deactivateDiscount();case _Reset() when reset != null:
return reset();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BarberCenter center)  selectCenter,required TResult Function( Service service)  toggleService,required TResult Function( Professional? professional)  selectProfessional,required TResult Function( DateTime date,  String time)  selectDateTime,required TResult Function( int phase)  goToPhase,required TResult Function()  confirmReservation,required TResult Function()  activateDiscount,required TResult Function()  deactivateDiscount,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case _SelectCenter():
return selectCenter(_that.center);case _ToggleService():
return toggleService(_that.service);case _SelectProfessional():
return selectProfessional(_that.professional);case _SelectDateTime():
return selectDateTime(_that.date,_that.time);case _GoToPhase():
return goToPhase(_that.phase);case _ConfirmReservation():
return confirmReservation();case _ActivateDiscount():
return activateDiscount();case _DeactivateDiscount():
return deactivateDiscount();case _Reset():
return reset();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BarberCenter center)?  selectCenter,TResult? Function( Service service)?  toggleService,TResult? Function( Professional? professional)?  selectProfessional,TResult? Function( DateTime date,  String time)?  selectDateTime,TResult? Function( int phase)?  goToPhase,TResult? Function()?  confirmReservation,TResult? Function()?  activateDiscount,TResult? Function()?  deactivateDiscount,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case _SelectCenter() when selectCenter != null:
return selectCenter(_that.center);case _ToggleService() when toggleService != null:
return toggleService(_that.service);case _SelectProfessional() when selectProfessional != null:
return selectProfessional(_that.professional);case _SelectDateTime() when selectDateTime != null:
return selectDateTime(_that.date,_that.time);case _GoToPhase() when goToPhase != null:
return goToPhase(_that.phase);case _ConfirmReservation() when confirmReservation != null:
return confirmReservation();case _ActivateDiscount() when activateDiscount != null:
return activateDiscount();case _DeactivateDiscount() when deactivateDiscount != null:
return deactivateDiscount();case _Reset() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class _SelectCenter implements ReservationEvent {
  const _SelectCenter(this.center);
  

 final  BarberCenter center;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectCenterCopyWith<_SelectCenter> get copyWith => __$SelectCenterCopyWithImpl<_SelectCenter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectCenter&&(identical(other.center, center) || other.center == center));
}


@override
int get hashCode => Object.hash(runtimeType,center);

@override
String toString() {
  return 'ReservationEvent.selectCenter(center: $center)';
}


}

/// @nodoc
abstract mixin class _$SelectCenterCopyWith<$Res> implements $ReservationEventCopyWith<$Res> {
  factory _$SelectCenterCopyWith(_SelectCenter value, $Res Function(_SelectCenter) _then) = __$SelectCenterCopyWithImpl;
@useResult
$Res call({
 BarberCenter center
});


$BarberCenterCopyWith<$Res> get center;

}
/// @nodoc
class __$SelectCenterCopyWithImpl<$Res>
    implements _$SelectCenterCopyWith<$Res> {
  __$SelectCenterCopyWithImpl(this._self, this._then);

  final _SelectCenter _self;
  final $Res Function(_SelectCenter) _then;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? center = null,}) {
  return _then(_SelectCenter(
null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as BarberCenter,
  ));
}

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BarberCenterCopyWith<$Res> get center {
  
  return $BarberCenterCopyWith<$Res>(_self.center, (value) {
    return _then(_self.copyWith(center: value));
  });
}
}

/// @nodoc


class _ToggleService implements ReservationEvent {
  const _ToggleService(this.service);
  

 final  Service service;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleServiceCopyWith<_ToggleService> get copyWith => __$ToggleServiceCopyWithImpl<_ToggleService>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleService&&(identical(other.service, service) || other.service == service));
}


@override
int get hashCode => Object.hash(runtimeType,service);

@override
String toString() {
  return 'ReservationEvent.toggleService(service: $service)';
}


}

/// @nodoc
abstract mixin class _$ToggleServiceCopyWith<$Res> implements $ReservationEventCopyWith<$Res> {
  factory _$ToggleServiceCopyWith(_ToggleService value, $Res Function(_ToggleService) _then) = __$ToggleServiceCopyWithImpl;
@useResult
$Res call({
 Service service
});


$ServiceCopyWith<$Res> get service;

}
/// @nodoc
class __$ToggleServiceCopyWithImpl<$Res>
    implements _$ToggleServiceCopyWith<$Res> {
  __$ToggleServiceCopyWithImpl(this._self, this._then);

  final _ToggleService _self;
  final $Res Function(_ToggleService) _then;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? service = null,}) {
  return _then(_ToggleService(
null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as Service,
  ));
}

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ServiceCopyWith<$Res> get service {
  
  return $ServiceCopyWith<$Res>(_self.service, (value) {
    return _then(_self.copyWith(service: value));
  });
}
}

/// @nodoc


class _SelectProfessional implements ReservationEvent {
  const _SelectProfessional(this.professional);
  

 final  Professional? professional;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectProfessionalCopyWith<_SelectProfessional> get copyWith => __$SelectProfessionalCopyWithImpl<_SelectProfessional>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectProfessional&&(identical(other.professional, professional) || other.professional == professional));
}


@override
int get hashCode => Object.hash(runtimeType,professional);

@override
String toString() {
  return 'ReservationEvent.selectProfessional(professional: $professional)';
}


}

/// @nodoc
abstract mixin class _$SelectProfessionalCopyWith<$Res> implements $ReservationEventCopyWith<$Res> {
  factory _$SelectProfessionalCopyWith(_SelectProfessional value, $Res Function(_SelectProfessional) _then) = __$SelectProfessionalCopyWithImpl;
@useResult
$Res call({
 Professional? professional
});


$ProfessionalCopyWith<$Res>? get professional;

}
/// @nodoc
class __$SelectProfessionalCopyWithImpl<$Res>
    implements _$SelectProfessionalCopyWith<$Res> {
  __$SelectProfessionalCopyWithImpl(this._self, this._then);

  final _SelectProfessional _self;
  final $Res Function(_SelectProfessional) _then;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? professional = freezed,}) {
  return _then(_SelectProfessional(
freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as Professional?,
  ));
}

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfessionalCopyWith<$Res>? get professional {
    if (_self.professional == null) {
    return null;
  }

  return $ProfessionalCopyWith<$Res>(_self.professional!, (value) {
    return _then(_self.copyWith(professional: value));
  });
}
}

/// @nodoc


class _SelectDateTime implements ReservationEvent {
  const _SelectDateTime(this.date, this.time);
  

 final  DateTime date;
 final  String time;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectDateTimeCopyWith<_SelectDateTime> get copyWith => __$SelectDateTimeCopyWithImpl<_SelectDateTime>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectDateTime&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time));
}


@override
int get hashCode => Object.hash(runtimeType,date,time);

@override
String toString() {
  return 'ReservationEvent.selectDateTime(date: $date, time: $time)';
}


}

/// @nodoc
abstract mixin class _$SelectDateTimeCopyWith<$Res> implements $ReservationEventCopyWith<$Res> {
  factory _$SelectDateTimeCopyWith(_SelectDateTime value, $Res Function(_SelectDateTime) _then) = __$SelectDateTimeCopyWithImpl;
@useResult
$Res call({
 DateTime date, String time
});




}
/// @nodoc
class __$SelectDateTimeCopyWithImpl<$Res>
    implements _$SelectDateTimeCopyWith<$Res> {
  __$SelectDateTimeCopyWithImpl(this._self, this._then);

  final _SelectDateTime _self;
  final $Res Function(_SelectDateTime) _then;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? date = null,Object? time = null,}) {
  return _then(_SelectDateTime(
null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _GoToPhase implements ReservationEvent {
  const _GoToPhase(this.phase);
  

 final  int phase;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoToPhaseCopyWith<_GoToPhase> get copyWith => __$GoToPhaseCopyWithImpl<_GoToPhase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoToPhase&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode => Object.hash(runtimeType,phase);

@override
String toString() {
  return 'ReservationEvent.goToPhase(phase: $phase)';
}


}

/// @nodoc
abstract mixin class _$GoToPhaseCopyWith<$Res> implements $ReservationEventCopyWith<$Res> {
  factory _$GoToPhaseCopyWith(_GoToPhase value, $Res Function(_GoToPhase) _then) = __$GoToPhaseCopyWithImpl;
@useResult
$Res call({
 int phase
});




}
/// @nodoc
class __$GoToPhaseCopyWithImpl<$Res>
    implements _$GoToPhaseCopyWith<$Res> {
  __$GoToPhaseCopyWithImpl(this._self, this._then);

  final _GoToPhase _self;
  final $Res Function(_GoToPhase) _then;

/// Create a copy of ReservationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,}) {
  return _then(_GoToPhase(
null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ConfirmReservation implements ReservationEvent {
  const _ConfirmReservation();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfirmReservation);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReservationEvent.confirmReservation()';
}


}




/// @nodoc


class _ActivateDiscount implements ReservationEvent {
  const _ActivateDiscount();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivateDiscount);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReservationEvent.activateDiscount()';
}


}




/// @nodoc


class _DeactivateDiscount implements ReservationEvent {
  const _DeactivateDiscount();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeactivateDiscount);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReservationEvent.deactivateDiscount()';
}


}




/// @nodoc


class _Reset implements ReservationEvent {
  const _Reset();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReservationEvent.reset()';
}


}




// dart format on
