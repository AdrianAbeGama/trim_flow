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

 ReservationStatus get status; int get currentPhase; Reservation get reservation; bool get professionalSelected; bool get isDiscountActive; List<DateTime> get availableSlots; SlotsStatus get slotsStatus; DateTime? get selectedSlotUtc; String? get effectiveBarberId; String? get idempotencyKey; String? get errorMessage; List<CustomerCoupon> get availableCoupons; CustomerCoupon? get selectedCoupon; double get couponDiscount; double? get finalPrice;
/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationStateCopyWith<ReservationState> get copyWith => _$ReservationStateCopyWithImpl<ReservationState>(this as ReservationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.reservation, reservation) || other.reservation == reservation)&&(identical(other.professionalSelected, professionalSelected) || other.professionalSelected == professionalSelected)&&(identical(other.isDiscountActive, isDiscountActive) || other.isDiscountActive == isDiscountActive)&&const DeepCollectionEquality().equals(other.availableSlots, availableSlots)&&(identical(other.slotsStatus, slotsStatus) || other.slotsStatus == slotsStatus)&&(identical(other.selectedSlotUtc, selectedSlotUtc) || other.selectedSlotUtc == selectedSlotUtc)&&(identical(other.effectiveBarberId, effectiveBarberId) || other.effectiveBarberId == effectiveBarberId)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.availableCoupons, availableCoupons)&&(identical(other.selectedCoupon, selectedCoupon) || other.selectedCoupon == selectedCoupon)&&(identical(other.couponDiscount, couponDiscount) || other.couponDiscount == couponDiscount)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentPhase,reservation,professionalSelected,isDiscountActive,const DeepCollectionEquality().hash(availableSlots),slotsStatus,selectedSlotUtc,effectiveBarberId,idempotencyKey,errorMessage,const DeepCollectionEquality().hash(availableCoupons),selectedCoupon,couponDiscount,finalPrice);

@override
String toString() {
  return 'ReservationState(status: $status, currentPhase: $currentPhase, reservation: $reservation, professionalSelected: $professionalSelected, isDiscountActive: $isDiscountActive, availableSlots: $availableSlots, slotsStatus: $slotsStatus, selectedSlotUtc: $selectedSlotUtc, effectiveBarberId: $effectiveBarberId, idempotencyKey: $idempotencyKey, errorMessage: $errorMessage, availableCoupons: $availableCoupons, selectedCoupon: $selectedCoupon, couponDiscount: $couponDiscount, finalPrice: $finalPrice)';
}


}

/// @nodoc
abstract mixin class $ReservationStateCopyWith<$Res>  {
  factory $ReservationStateCopyWith(ReservationState value, $Res Function(ReservationState) _then) = _$ReservationStateCopyWithImpl;
@useResult
$Res call({
 ReservationStatus status, int currentPhase, Reservation reservation, bool professionalSelected, bool isDiscountActive, List<DateTime> availableSlots, SlotsStatus slotsStatus, DateTime? selectedSlotUtc, String? effectiveBarberId, String? idempotencyKey, String? errorMessage, List<CustomerCoupon> availableCoupons, CustomerCoupon? selectedCoupon, double couponDiscount, double? finalPrice
});


$ReservationCopyWith<$Res> get reservation;$CustomerCouponCopyWith<$Res>? get selectedCoupon;

}
/// @nodoc
class _$ReservationStateCopyWithImpl<$Res>
    implements $ReservationStateCopyWith<$Res> {
  _$ReservationStateCopyWithImpl(this._self, this._then);

  final ReservationState _self;
  final $Res Function(ReservationState) _then;

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? currentPhase = null,Object? reservation = null,Object? professionalSelected = null,Object? isDiscountActive = null,Object? availableSlots = null,Object? slotsStatus = null,Object? selectedSlotUtc = freezed,Object? effectiveBarberId = freezed,Object? idempotencyKey = freezed,Object? errorMessage = freezed,Object? availableCoupons = null,Object? selectedCoupon = freezed,Object? couponDiscount = null,Object? finalPrice = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as int,reservation: null == reservation ? _self.reservation : reservation // ignore: cast_nullable_to_non_nullable
as Reservation,professionalSelected: null == professionalSelected ? _self.professionalSelected : professionalSelected // ignore: cast_nullable_to_non_nullable
as bool,isDiscountActive: null == isDiscountActive ? _self.isDiscountActive : isDiscountActive // ignore: cast_nullable_to_non_nullable
as bool,availableSlots: null == availableSlots ? _self.availableSlots : availableSlots // ignore: cast_nullable_to_non_nullable
as List<DateTime>,slotsStatus: null == slotsStatus ? _self.slotsStatus : slotsStatus // ignore: cast_nullable_to_non_nullable
as SlotsStatus,selectedSlotUtc: freezed == selectedSlotUtc ? _self.selectedSlotUtc : selectedSlotUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,effectiveBarberId: freezed == effectiveBarberId ? _self.effectiveBarberId : effectiveBarberId // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,availableCoupons: null == availableCoupons ? _self.availableCoupons : availableCoupons // ignore: cast_nullable_to_non_nullable
as List<CustomerCoupon>,selectedCoupon: freezed == selectedCoupon ? _self.selectedCoupon : selectedCoupon // ignore: cast_nullable_to_non_nullable
as CustomerCoupon?,couponDiscount: null == couponDiscount ? _self.couponDiscount : couponDiscount // ignore: cast_nullable_to_non_nullable
as double,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,
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
}/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCouponCopyWith<$Res>? get selectedCoupon {
    if (_self.selectedCoupon == null) {
    return null;
  }

  return $CustomerCouponCopyWith<$Res>(_self.selectedCoupon!, (value) {
    return _then(_self.copyWith(selectedCoupon: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReservationStatus status,  int currentPhase,  Reservation reservation,  bool professionalSelected,  bool isDiscountActive,  List<DateTime> availableSlots,  SlotsStatus slotsStatus,  DateTime? selectedSlotUtc,  String? effectiveBarberId,  String? idempotencyKey,  String? errorMessage,  List<CustomerCoupon> availableCoupons,  CustomerCoupon? selectedCoupon,  double couponDiscount,  double? finalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationState() when $default != null:
return $default(_that.status,_that.currentPhase,_that.reservation,_that.professionalSelected,_that.isDiscountActive,_that.availableSlots,_that.slotsStatus,_that.selectedSlotUtc,_that.effectiveBarberId,_that.idempotencyKey,_that.errorMessage,_that.availableCoupons,_that.selectedCoupon,_that.couponDiscount,_that.finalPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReservationStatus status,  int currentPhase,  Reservation reservation,  bool professionalSelected,  bool isDiscountActive,  List<DateTime> availableSlots,  SlotsStatus slotsStatus,  DateTime? selectedSlotUtc,  String? effectiveBarberId,  String? idempotencyKey,  String? errorMessage,  List<CustomerCoupon> availableCoupons,  CustomerCoupon? selectedCoupon,  double couponDiscount,  double? finalPrice)  $default,) {final _that = this;
switch (_that) {
case _ReservationState():
return $default(_that.status,_that.currentPhase,_that.reservation,_that.professionalSelected,_that.isDiscountActive,_that.availableSlots,_that.slotsStatus,_that.selectedSlotUtc,_that.effectiveBarberId,_that.idempotencyKey,_that.errorMessage,_that.availableCoupons,_that.selectedCoupon,_that.couponDiscount,_that.finalPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReservationStatus status,  int currentPhase,  Reservation reservation,  bool professionalSelected,  bool isDiscountActive,  List<DateTime> availableSlots,  SlotsStatus slotsStatus,  DateTime? selectedSlotUtc,  String? effectiveBarberId,  String? idempotencyKey,  String? errorMessage,  List<CustomerCoupon> availableCoupons,  CustomerCoupon? selectedCoupon,  double couponDiscount,  double? finalPrice)?  $default,) {final _that = this;
switch (_that) {
case _ReservationState() when $default != null:
return $default(_that.status,_that.currentPhase,_that.reservation,_that.professionalSelected,_that.isDiscountActive,_that.availableSlots,_that.slotsStatus,_that.selectedSlotUtc,_that.effectiveBarberId,_that.idempotencyKey,_that.errorMessage,_that.availableCoupons,_that.selectedCoupon,_that.couponDiscount,_that.finalPrice);case _:
  return null;

}
}

}

/// @nodoc


class _ReservationState implements ReservationState {
  const _ReservationState({this.status = ReservationStatus.initial, this.currentPhase = 1, this.reservation = const Reservation(tenantId: ''), this.professionalSelected = false, this.isDiscountActive = false, final  List<DateTime> availableSlots = const <DateTime>[], this.slotsStatus = SlotsStatus.initial, this.selectedSlotUtc, this.effectiveBarberId, this.idempotencyKey, this.errorMessage, final  List<CustomerCoupon> availableCoupons = const <CustomerCoupon>[], this.selectedCoupon, this.couponDiscount = 0, this.finalPrice}): _availableSlots = availableSlots,_availableCoupons = availableCoupons;
  

@override@JsonKey() final  ReservationStatus status;
@override@JsonKey() final  int currentPhase;
@override@JsonKey() final  Reservation reservation;
@override@JsonKey() final  bool professionalSelected;
@override@JsonKey() final  bool isDiscountActive;
 final  List<DateTime> _availableSlots;
@override@JsonKey() List<DateTime> get availableSlots {
  if (_availableSlots is EqualUnmodifiableListView) return _availableSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableSlots);
}

@override@JsonKey() final  SlotsStatus slotsStatus;
@override final  DateTime? selectedSlotUtc;
@override final  String? effectiveBarberId;
@override final  String? idempotencyKey;
@override final  String? errorMessage;
 final  List<CustomerCoupon> _availableCoupons;
@override@JsonKey() List<CustomerCoupon> get availableCoupons {
  if (_availableCoupons is EqualUnmodifiableListView) return _availableCoupons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableCoupons);
}

@override final  CustomerCoupon? selectedCoupon;
@override@JsonKey() final  double couponDiscount;
@override final  double? finalPrice;

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationStateCopyWith<_ReservationState> get copyWith => __$ReservationStateCopyWithImpl<_ReservationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentPhase, currentPhase) || other.currentPhase == currentPhase)&&(identical(other.reservation, reservation) || other.reservation == reservation)&&(identical(other.professionalSelected, professionalSelected) || other.professionalSelected == professionalSelected)&&(identical(other.isDiscountActive, isDiscountActive) || other.isDiscountActive == isDiscountActive)&&const DeepCollectionEquality().equals(other._availableSlots, _availableSlots)&&(identical(other.slotsStatus, slotsStatus) || other.slotsStatus == slotsStatus)&&(identical(other.selectedSlotUtc, selectedSlotUtc) || other.selectedSlotUtc == selectedSlotUtc)&&(identical(other.effectiveBarberId, effectiveBarberId) || other.effectiveBarberId == effectiveBarberId)&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._availableCoupons, _availableCoupons)&&(identical(other.selectedCoupon, selectedCoupon) || other.selectedCoupon == selectedCoupon)&&(identical(other.couponDiscount, couponDiscount) || other.couponDiscount == couponDiscount)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentPhase,reservation,professionalSelected,isDiscountActive,const DeepCollectionEquality().hash(_availableSlots),slotsStatus,selectedSlotUtc,effectiveBarberId,idempotencyKey,errorMessage,const DeepCollectionEquality().hash(_availableCoupons),selectedCoupon,couponDiscount,finalPrice);

@override
String toString() {
  return 'ReservationState(status: $status, currentPhase: $currentPhase, reservation: $reservation, professionalSelected: $professionalSelected, isDiscountActive: $isDiscountActive, availableSlots: $availableSlots, slotsStatus: $slotsStatus, selectedSlotUtc: $selectedSlotUtc, effectiveBarberId: $effectiveBarberId, idempotencyKey: $idempotencyKey, errorMessage: $errorMessage, availableCoupons: $availableCoupons, selectedCoupon: $selectedCoupon, couponDiscount: $couponDiscount, finalPrice: $finalPrice)';
}


}

/// @nodoc
abstract mixin class _$ReservationStateCopyWith<$Res> implements $ReservationStateCopyWith<$Res> {
  factory _$ReservationStateCopyWith(_ReservationState value, $Res Function(_ReservationState) _then) = __$ReservationStateCopyWithImpl;
@override @useResult
$Res call({
 ReservationStatus status, int currentPhase, Reservation reservation, bool professionalSelected, bool isDiscountActive, List<DateTime> availableSlots, SlotsStatus slotsStatus, DateTime? selectedSlotUtc, String? effectiveBarberId, String? idempotencyKey, String? errorMessage, List<CustomerCoupon> availableCoupons, CustomerCoupon? selectedCoupon, double couponDiscount, double? finalPrice
});


@override $ReservationCopyWith<$Res> get reservation;@override $CustomerCouponCopyWith<$Res>? get selectedCoupon;

}
/// @nodoc
class __$ReservationStateCopyWithImpl<$Res>
    implements _$ReservationStateCopyWith<$Res> {
  __$ReservationStateCopyWithImpl(this._self, this._then);

  final _ReservationState _self;
  final $Res Function(_ReservationState) _then;

/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? currentPhase = null,Object? reservation = null,Object? professionalSelected = null,Object? isDiscountActive = null,Object? availableSlots = null,Object? slotsStatus = null,Object? selectedSlotUtc = freezed,Object? effectiveBarberId = freezed,Object? idempotencyKey = freezed,Object? errorMessage = freezed,Object? availableCoupons = null,Object? selectedCoupon = freezed,Object? couponDiscount = null,Object? finalPrice = freezed,}) {
  return _then(_ReservationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReservationStatus,currentPhase: null == currentPhase ? _self.currentPhase : currentPhase // ignore: cast_nullable_to_non_nullable
as int,reservation: null == reservation ? _self.reservation : reservation // ignore: cast_nullable_to_non_nullable
as Reservation,professionalSelected: null == professionalSelected ? _self.professionalSelected : professionalSelected // ignore: cast_nullable_to_non_nullable
as bool,isDiscountActive: null == isDiscountActive ? _self.isDiscountActive : isDiscountActive // ignore: cast_nullable_to_non_nullable
as bool,availableSlots: null == availableSlots ? _self._availableSlots : availableSlots // ignore: cast_nullable_to_non_nullable
as List<DateTime>,slotsStatus: null == slotsStatus ? _self.slotsStatus : slotsStatus // ignore: cast_nullable_to_non_nullable
as SlotsStatus,selectedSlotUtc: freezed == selectedSlotUtc ? _self.selectedSlotUtc : selectedSlotUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,effectiveBarberId: freezed == effectiveBarberId ? _self.effectiveBarberId : effectiveBarberId // ignore: cast_nullable_to_non_nullable
as String?,idempotencyKey: freezed == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,availableCoupons: null == availableCoupons ? _self._availableCoupons : availableCoupons // ignore: cast_nullable_to_non_nullable
as List<CustomerCoupon>,selectedCoupon: freezed == selectedCoupon ? _self.selectedCoupon : selectedCoupon // ignore: cast_nullable_to_non_nullable
as CustomerCoupon?,couponDiscount: null == couponDiscount ? _self.couponDiscount : couponDiscount // ignore: cast_nullable_to_non_nullable
as double,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,
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
}/// Create a copy of ReservationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerCouponCopyWith<$Res>? get selectedCoupon {
    if (_self.selectedCoupon == null) {
    return null;
  }

  return $CustomerCouponCopyWith<$Res>(_self.selectedCoupon!, (value) {
    return _then(_self.copyWith(selectedCoupon: value));
  });
}
}

// dart format on
