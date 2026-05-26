// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReservationState {

 ReservationStatus get status; int get currentPhase; Reservation get reservation; bool get professionalSelected; bool get isDiscountActive; String? get errorMessage;
/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationStateCopyWith<ReservationState> get copyWith => _$ReservationStateCopyWithImpl<ReservationState>(this as ReservationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.reservation, reservation) || other.reservation == reservation)&&(identical(other.professionalSelected, professionalSelected) || other.professionalSelected == professionalSelected)&&(identical(other.isDiscountActive, isDiscountActive) || other.isDiscountActive == isDiscountActive)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentPhase,reservation,professionalSelected,isDiscountActive,errorMessage);

@override
String toString() {
  return 'ReservationState(status: $status, currentPhase: $currentPhase, reservation: $reservation, professionalSelected: $professionalSelected, isDiscountActive: $isDiscountActive, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ReservationStateCopyWith<$Res>  {
  factory $ReservationStateCopyWith(ReservationState value, $Res Function(ReservationState) _then) = _$ReservationStateCopyWithImpl;
@useResult
$Res call({
 ReservationStatus status, int currentPhase, Reservation reservation, bool professionalSelected, bool isDiscountActive, String? errorMessage
});


$ReservationCopyWith<$Res> get reservation;

}
/// @nodoc
class _$ReservationStateCopyWithImpl<$Res>
    implements $ReservationStateCopyWith<$Res> {
  _$ReservationStateCopyWithImpl(this._self, this._then);

  final ReservationState _self;
  final $Res Function(ReservationState) _then;

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? currentPhase = null,Object? reservation = null,Object? professionalSelected = null,Object? isDiscountActive = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as int,reservation: null == reservation ? _self.reservation : reservation // ignore: cast_nullable_to_non_nullable
as Reservation,professionalSelected: null == professionalSelected ? _self.professionalSelected : professionalSelected // ignore: cast_nullable_to_non_nullable
as bool,isDiscountActive: null == isDiscountActive ? _self.isDiscountActive : isDiscountActive // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReservationCopyWith<$Res> get reservation {
  
  return $ReservationCopyWith<$Res>(_self.reservation, (value) {
    return _then(_self.copyWith(reservation: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReservationState].
extension ReservationStatePatterns on ReservationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReservationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReservationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReservationState value)  $default,){
final _that = this;
switch (_that) {
case _ReservationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReservationState value)?  $default,){
final _that = this;
switch (_that) {
case _ReservationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReservationStatus status,  int currentPhase,  Reservation reservation,  bool professionalSelected,  bool isDiscountActive,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationState() when $default != null:
return $default(_that.status,_that.currentPhase,_that.reservation,_that.professionalSelected,_that.isDiscountActive,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReservationStatus status,  int currentPhase,  Reservation reservation,  bool professionalSelected,  bool isDiscountActive,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ReservationState():
return $default(_that.status,_that.currentPhase,_that.reservation,_that.professionalSelected,_that.isDiscountActive,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReservationStatus status,  int currentPhase,  Reservation reservation,  bool professionalSelected,  bool isDiscountActive,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ReservationState() when $default != null:
return $default(_that.status,_that.currentPhase,_that.reservation,_that.professionalSelected,_that.isDiscountActive,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ReservationState implements ReservationState {
  const _ReservationState({this.status = ReservationStatus.initial, this.currentPhase = 1, this.reservation = const Reservation(tenantId: ''), this.professionalSelected = false, this.isDiscountActive = false, this.errorMessage});
  

@override@JsonKey() final  ReservationStatus status;
@override@JsonKey() final  int currentPhase;
@override@JsonKey() final  Reservation reservation;
@override@JsonKey() final  bool professionalSelected;
@override@JsonKey() final  bool isDiscountActive;
@override final  String? errorMessage;

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationStateCopyWith<_ReservationState> get copyWith => __$ReservationStateCopyWithImpl<_ReservationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.reservation, reservation) || other.reservation == reservation)&&(identical(other.professionalSelected, professionalSelected) || other.professionalSelected == professionalSelected)&&(identical(other.isDiscountActive, isDiscountActive) || other.isDiscountActive == isDiscountActive)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentPhase,reservation,professionalSelected,isDiscountActive,errorMessage);

@override
String toString() {
  return 'ReservationState(status: $status, currentPhase: $currentPhase, reservation: $reservation, professionalSelected: $professionalSelected, isDiscountActive: $isDiscountActive, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ReservationStateCopyWith<$Res> implements $ReservationStateCopyWith<$Res> {
  factory _$ReservationStateCopyWith(_ReservationState value, $Res Function(_ReservationState) _then) = __$ReservationStateCopyWithImpl;
@override @useResult
$Res call({
 ReservationStatus status, int currentPhase, Reservation reservation, bool professionalSelected, bool isDiscountActive, String? errorMessage
});


@override $ReservationCopyWith<$Res> get reservation;

}
/// @nodoc
class __$ReservationStateCopyWithImpl<$Res>
    implements _$ReservationStateCopyWith<$Res> {
  __$ReservationStateCopyWithImpl(this._self, this._then);

  final _ReservationState _self;
  final $Res Function(_ReservationState) _then;

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? currentPhase = null,Object? reservation = null,Object? professionalSelected = null,Object? isDiscountActive = null,Object? errorMessage = freezed,}) {
  return _then(_ReservationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as int,reservation: null == reservation ? _self.reservation : reservation // ignore: cast_nullable_to_non_nullable
as Reservation,professionalSelected: null == professionalSelected ? _self.professionalSelected : professionalSelected // ignore: cast_nullable_to_non_nullable
as bool,isDiscountActive: null == isDiscountActive ? _self.isDiscountActive : isDiscountActive // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReservationCopyWith<$Res> get reservation {
  
  return $ReservationCopyWith<$Res>(_self.reservation, (value) {
    return _then(_self.copyWith(reservation: value));
  });
}
}

// dart format on
