// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent()';
}


}

/// @nodoc
class $ProfileEventCopyWith<$Res>  {
$ProfileEventCopyWith(ProfileEvent _, $Res Function(ProfileEvent) __);
}


/// Adds pattern-matching-related methods to [ProfileEvent].
extension ProfileEventPatterns on ProfileEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadProfileEvent value)?  load,TResult Function( SaveProfileData value)?  save,TResult Function( ClaimReward value)?  claimReward,TResult Function( RequestNotificationPermissionEvent value)?  requestNotificationPermission,TResult Function( TestNotificationEvent value)?  testNotification,TResult Function( ToggleNotificationsEvent value)?  toggleNotifications,TResult Function( ToggleEditMode value)?  toggleEditMode,TResult Function( AddScheduledReservation value)?  addScheduledReservation,TResult Function( ClearBadge value)?  clearBadge,TResult Function( ResetFidelityCount value)?  resetFidelityCount,TResult Function( CancelAppointment value)?  cancelAppointment,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadProfileEvent() when load != null:
return load(_that);case SaveProfileData() when save != null:
return save(_that);case ClaimReward() when claimReward != null:
return claimReward(_that);case RequestNotificationPermissionEvent() when requestNotificationPermission != null:
return requestNotificationPermission(_that);case TestNotificationEvent() when testNotification != null:
return testNotification(_that);case ToggleNotificationsEvent() when toggleNotifications != null:
return toggleNotifications(_that);case ToggleEditMode() when toggleEditMode != null:
return toggleEditMode(_that);case AddScheduledReservation() when addScheduledReservation != null:
return addScheduledReservation(_that);case ClearBadge() when clearBadge != null:
return clearBadge(_that);case ResetFidelityCount() when resetFidelityCount != null:
return resetFidelityCount(_that);case CancelAppointment() when cancelAppointment != null:
return cancelAppointment(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadProfileEvent value)  load,required TResult Function( SaveProfileData value)  save,required TResult Function( ClaimReward value)  claimReward,required TResult Function( RequestNotificationPermissionEvent value)  requestNotificationPermission,required TResult Function( TestNotificationEvent value)  testNotification,required TResult Function( ToggleNotificationsEvent value)  toggleNotifications,required TResult Function( ToggleEditMode value)  toggleEditMode,required TResult Function( AddScheduledReservation value)  addScheduledReservation,required TResult Function( ClearBadge value)  clearBadge,required TResult Function( ResetFidelityCount value)  resetFidelityCount,required TResult Function( CancelAppointment value)  cancelAppointment,}){
final _that = this;
switch (_that) {
case LoadProfileEvent():
return load(_that);case SaveProfileData():
return save(_that);case ClaimReward():
return claimReward(_that);case RequestNotificationPermissionEvent():
return requestNotificationPermission(_that);case TestNotificationEvent():
return testNotification(_that);case ToggleNotificationsEvent():
return toggleNotifications(_that);case ToggleEditMode():
return toggleEditMode(_that);case AddScheduledReservation():
return addScheduledReservation(_that);case ClearBadge():
return clearBadge(_that);case ResetFidelityCount():
return resetFidelityCount(_that);case CancelAppointment():
return cancelAppointment(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadProfileEvent value)?  load,TResult? Function( SaveProfileData value)?  save,TResult? Function( ClaimReward value)?  claimReward,TResult? Function( RequestNotificationPermissionEvent value)?  requestNotificationPermission,TResult? Function( TestNotificationEvent value)?  testNotification,TResult? Function( ToggleNotificationsEvent value)?  toggleNotifications,TResult? Function( ToggleEditMode value)?  toggleEditMode,TResult? Function( AddScheduledReservation value)?  addScheduledReservation,TResult? Function( ClearBadge value)?  clearBadge,TResult? Function( ResetFidelityCount value)?  resetFidelityCount,TResult? Function( CancelAppointment value)?  cancelAppointment,}){
final _that = this;
switch (_that) {
case LoadProfileEvent() when load != null:
return load(_that);case SaveProfileData() when save != null:
return save(_that);case ClaimReward() when claimReward != null:
return claimReward(_that);case RequestNotificationPermissionEvent() when requestNotificationPermission != null:
return requestNotificationPermission(_that);case TestNotificationEvent() when testNotification != null:
return testNotification(_that);case ToggleNotificationsEvent() when toggleNotifications != null:
return toggleNotifications(_that);case ToggleEditMode() when toggleEditMode != null:
return toggleEditMode(_that);case AddScheduledReservation() when addScheduledReservation != null:
return addScheduledReservation(_that);case ClearBadge() when clearBadge != null:
return clearBadge(_that);case ResetFidelityCount() when resetFidelityCount != null:
return resetFidelityCount(_that);case CancelAppointment() when cancelAppointment != null:
return cancelAppointment(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( String firstName,  String lastName,  String phone,  String birthDate)?  save,TResult Function()?  claimReward,TResult Function()?  requestNotificationPermission,TResult Function()?  testNotification,TResult Function( bool enabled)?  toggleNotifications,TResult Function()?  toggleEditMode,TResult Function( Reservation reservation)?  addScheduledReservation,TResult Function()?  clearBadge,TResult Function()?  resetFidelityCount,TResult Function( String reservationId,  String reason)?  cancelAppointment,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadProfileEvent() when load != null:
return load();case SaveProfileData() when save != null:
return save(_that.firstName,_that.lastName,_that.phone,_that.birthDate);case ClaimReward() when claimReward != null:
return claimReward();case RequestNotificationPermissionEvent() when requestNotificationPermission != null:
return requestNotificationPermission();case TestNotificationEvent() when testNotification != null:
return testNotification();case ToggleNotificationsEvent() when toggleNotifications != null:
return toggleNotifications(_that.enabled);case ToggleEditMode() when toggleEditMode != null:
return toggleEditMode();case AddScheduledReservation() when addScheduledReservation != null:
return addScheduledReservation(_that.reservation);case ClearBadge() when clearBadge != null:
return clearBadge();case ResetFidelityCount() when resetFidelityCount != null:
return resetFidelityCount();case CancelAppointment() when cancelAppointment != null:
return cancelAppointment(_that.reservationId,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( String firstName,  String lastName,  String phone,  String birthDate)  save,required TResult Function()  claimReward,required TResult Function()  requestNotificationPermission,required TResult Function()  testNotification,required TResult Function( bool enabled)  toggleNotifications,required TResult Function()  toggleEditMode,required TResult Function( Reservation reservation)  addScheduledReservation,required TResult Function()  clearBadge,required TResult Function()  resetFidelityCount,required TResult Function( String reservationId,  String reason)  cancelAppointment,}) {final _that = this;
switch (_that) {
case LoadProfileEvent():
return load();case SaveProfileData():
return save(_that.firstName,_that.lastName,_that.phone,_that.birthDate);case ClaimReward():
return claimReward();case RequestNotificationPermissionEvent():
return requestNotificationPermission();case TestNotificationEvent():
return testNotification();case ToggleNotificationsEvent():
return toggleNotifications(_that.enabled);case ToggleEditMode():
return toggleEditMode();case AddScheduledReservation():
return addScheduledReservation(_that.reservation);case ClearBadge():
return clearBadge();case ResetFidelityCount():
return resetFidelityCount();case CancelAppointment():
return cancelAppointment(_that.reservationId,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( String firstName,  String lastName,  String phone,  String birthDate)?  save,TResult? Function()?  claimReward,TResult? Function()?  requestNotificationPermission,TResult? Function()?  testNotification,TResult? Function( bool enabled)?  toggleNotifications,TResult? Function()?  toggleEditMode,TResult? Function( Reservation reservation)?  addScheduledReservation,TResult? Function()?  clearBadge,TResult? Function()?  resetFidelityCount,TResult? Function( String reservationId,  String reason)?  cancelAppointment,}) {final _that = this;
switch (_that) {
case LoadProfileEvent() when load != null:
return load();case SaveProfileData() when save != null:
return save(_that.firstName,_that.lastName,_that.phone,_that.birthDate);case ClaimReward() when claimReward != null:
return claimReward();case RequestNotificationPermissionEvent() when requestNotificationPermission != null:
return requestNotificationPermission();case TestNotificationEvent() when testNotification != null:
return testNotification();case ToggleNotificationsEvent() when toggleNotifications != null:
return toggleNotifications(_that.enabled);case ToggleEditMode() when toggleEditMode != null:
return toggleEditMode();case AddScheduledReservation() when addScheduledReservation != null:
return addScheduledReservation(_that.reservation);case ClearBadge() when clearBadge != null:
return clearBadge();case ResetFidelityCount() when resetFidelityCount != null:
return resetFidelityCount();case CancelAppointment() when cancelAppointment != null:
return cancelAppointment(_that.reservationId,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class LoadProfileEvent implements ProfileEvent {
  const LoadProfileEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadProfileEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.load()';
}


}




/// @nodoc


class SaveProfileData implements ProfileEvent {
  const SaveProfileData({required this.firstName, required this.lastName, required this.phone, required this.birthDate});
  

 final  String firstName;
 final  String lastName;
 final  String phone;
 final  String birthDate;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveProfileDataCopyWith<SaveProfileData> get copyWith => _$SaveProfileDataCopyWithImpl<SaveProfileData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveProfileData&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate));
}


@override
int get hashCode => Object.hash(runtimeType,firstName,lastName,phone,birthDate);

@override
String toString() {
  return 'ProfileEvent.save(firstName: $firstName, lastName: $lastName, phone: $phone, birthDate: $birthDate)';
}


}

/// @nodoc
abstract mixin class $SaveProfileDataCopyWith<$Res> implements $ProfileEventCopyWith<$Res> {
  factory $SaveProfileDataCopyWith(SaveProfileData value, $Res Function(SaveProfileData) _then) = _$SaveProfileDataCopyWithImpl;
@useResult
$Res call({
 String firstName, String lastName, String phone, String birthDate
});




}
/// @nodoc
class _$SaveProfileDataCopyWithImpl<$Res>
    implements $SaveProfileDataCopyWith<$Res> {
  _$SaveProfileDataCopyWithImpl(this._self, this._then);

  final SaveProfileData _self;
  final $Res Function(SaveProfileData) _then;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? firstName = null,Object? lastName = null,Object? phone = null,Object? birthDate = null,}) {
  return _then(SaveProfileData(
firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ClaimReward implements ProfileEvent {
  const ClaimReward();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClaimReward);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.claimReward()';
}


}




/// @nodoc


class RequestNotificationPermissionEvent implements ProfileEvent {
  const RequestNotificationPermissionEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestNotificationPermissionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.requestNotificationPermission()';
}


}




/// @nodoc


class TestNotificationEvent implements ProfileEvent {
  const TestNotificationEvent();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestNotificationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.testNotification()';
}


}




/// @nodoc


class ToggleNotificationsEvent implements ProfileEvent {
  const ToggleNotificationsEvent({required this.enabled});
  

 final  bool enabled;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToggleNotificationsEventCopyWith<ToggleNotificationsEvent> get copyWith => _$ToggleNotificationsEventCopyWithImpl<ToggleNotificationsEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleNotificationsEvent&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,enabled);

@override
String toString() {
  return 'ProfileEvent.toggleNotifications(enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $ToggleNotificationsEventCopyWith<$Res> implements $ProfileEventCopyWith<$Res> {
  factory $ToggleNotificationsEventCopyWith(ToggleNotificationsEvent value, $Res Function(ToggleNotificationsEvent) _then) = _$ToggleNotificationsEventCopyWithImpl;
@useResult
$Res call({
 bool enabled
});




}
/// @nodoc
class _$ToggleNotificationsEventCopyWithImpl<$Res>
    implements $ToggleNotificationsEventCopyWith<$Res> {
  _$ToggleNotificationsEventCopyWithImpl(this._self, this._then);

  final ToggleNotificationsEvent _self;
  final $Res Function(ToggleNotificationsEvent) _then;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? enabled = null,}) {
  return _then(ToggleNotificationsEvent(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class ToggleEditMode implements ProfileEvent {
  const ToggleEditMode();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleEditMode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.toggleEditMode()';
}


}




/// @nodoc


class AddScheduledReservation implements ProfileEvent {
  const AddScheduledReservation(this.reservation);
  

 final  Reservation reservation;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddScheduledReservationCopyWith<AddScheduledReservation> get copyWith => _$AddScheduledReservationCopyWithImpl<AddScheduledReservation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddScheduledReservation&&(identical(other.reservation, reservation) || other.reservation == reservation));
}


@override
int get hashCode => Object.hash(runtimeType,reservation);

@override
String toString() {
  return 'ProfileEvent.addScheduledReservation(reservation: $reservation)';
}


}

/// @nodoc
abstract mixin class $AddScheduledReservationCopyWith<$Res> implements $ProfileEventCopyWith<$Res> {
  factory $AddScheduledReservationCopyWith(AddScheduledReservation value, $Res Function(AddScheduledReservation) _then) = _$AddScheduledReservationCopyWithImpl;
@useResult
$Res call({
 Reservation reservation
});


$ReservationCopyWith<$Res> get reservation;

}
/// @nodoc
class _$AddScheduledReservationCopyWithImpl<$Res>
    implements $AddScheduledReservationCopyWith<$Res> {
  _$AddScheduledReservationCopyWithImpl(this._self, this._then);

  final AddScheduledReservation _self;
  final $Res Function(AddScheduledReservation) _then;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reservation = null,}) {
  return _then(AddScheduledReservation(
null == reservation ? _self.reservation : reservation // ignore: cast_nullable_to_non_nullable
as Reservation,
  ));
}

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReservationCopyWith<$Res> get reservation {
  
  return $ReservationCopyWith<$Res>(_self.reservation, (value) {
    return _then(_self.copyWith(reservation: value));
  });
}
}

/// @nodoc


class ClearBadge implements ProfileEvent {
  const ClearBadge();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearBadge);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.clearBadge()';
}


}




/// @nodoc


class ResetFidelityCount implements ProfileEvent {
  const ResetFidelityCount();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetFidelityCount);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileEvent.resetFidelityCount()';
}


}




/// @nodoc


class CancelAppointment implements ProfileEvent {
  const CancelAppointment({required this.reservationId, required this.reason});
  

 final  String reservationId;
 final  String reason;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelAppointmentCopyWith<CancelAppointment> get copyWith => _$CancelAppointmentCopyWithImpl<CancelAppointment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CancelAppointment&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reservationId,reason);

@override
String toString() {
  return 'ProfileEvent.cancelAppointment(reservationId: $reservationId, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $CancelAppointmentCopyWith<$Res> implements $ProfileEventCopyWith<$Res> {
  factory $CancelAppointmentCopyWith(CancelAppointment value, $Res Function(CancelAppointment) _then) = _$CancelAppointmentCopyWithImpl;
@useResult
$Res call({
 String reservationId, String reason
});




}
/// @nodoc
class _$CancelAppointmentCopyWithImpl<$Res>
    implements $CancelAppointmentCopyWith<$Res> {
  _$CancelAppointmentCopyWithImpl(this._self, this._then);

  final CancelAppointment _self;
  final $Res Function(CancelAppointment) _then;

/// Create a copy of ProfileEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reservationId = null,Object? reason = null,}) {
  return _then(CancelAppointment(
reservationId: null == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
