// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {

 ProfileStatus get status; UserProfile? get user; bool get isEditing; int get completedCuts; bool get isRewardAvailable; bool get isBenefitActive; List<Reservation> get scheduledAppointments; List<PastAppointment> get appointmentHistory; bool get recentHasMore; List<CustomerCoupon> get coupons; int get notificationIndex; bool get hasPendingBadge; String? get clientCode; String? get lastVisit; String? get branchName;
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStateCopyWith<ProfileState> get copyWith => _$ProfileStateCopyWithImpl<ProfileState>(this as ProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.completedCuts, completedCuts) || other.completedCuts == completedCuts)&&(identical(other.isRewardAvailable, isRewardAvailable) || other.isRewardAvailable == isRewardAvailable)&&(identical(other.isBenefitActive, isBenefitActive) || other.isBenefitActive == isBenefitActive)&&const DeepCollectionEquality().equals(other.scheduledAppointments, scheduledAppointments)&&const DeepCollectionEquality().equals(other.appointmentHistory, appointmentHistory)&&(identical(other.recentHasMore, recentHasMore) || other.recentHasMore == recentHasMore)&&const DeepCollectionEquality().equals(other.coupons, coupons)&&(identical(other.notificationIndex, notificationIndex) || other.notificationIndex == notificationIndex)&&(identical(other.hasPendingBadge, hasPendingBadge) || other.hasPendingBadge == hasPendingBadge)&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.lastVisit, lastVisit) || other.lastVisit == lastVisit)&&(identical(other.branchName, branchName) || other.branchName == branchName));
}


@override
int get hashCode => Object.hash(runtimeType,status,user,isEditing,completedCuts,isRewardAvailable,isBenefitActive,const DeepCollectionEquality().hash(scheduledAppointments),const DeepCollectionEquality().hash(appointmentHistory),recentHasMore,const DeepCollectionEquality().hash(coupons),notificationIndex,hasPendingBadge,clientCode,lastVisit,branchName);

@override
String toString() {
  return 'ProfileState(status: $status, user: $user, isEditing: $isEditing, completedCuts: $completedCuts, isRewardAvailable: $isRewardAvailable, isBenefitActive: $isBenefitActive, scheduledAppointments: $scheduledAppointments, appointmentHistory: $appointmentHistory, recentHasMore: $recentHasMore, coupons: $coupons, notificationIndex: $notificationIndex, hasPendingBadge: $hasPendingBadge, clientCode: $clientCode, lastVisit: $lastVisit, branchName: $branchName)';
}


}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res>  {
  factory $ProfileStateCopyWith(ProfileState value, $Res Function(ProfileState) _then) = _$ProfileStateCopyWithImpl;
@useResult
$Res call({
 ProfileStatus status, UserProfile? user, bool isEditing, int completedCuts, bool isRewardAvailable, bool isBenefitActive, List<Reservation> scheduledAppointments, List<PastAppointment> appointmentHistory, bool recentHasMore, List<CustomerCoupon> coupons, int notificationIndex, bool hasPendingBadge, String? clientCode, String? lastVisit, String? branchName
});


$UserProfileCopyWith<$Res>? get user;

}
/// @nodoc
class _$ProfileStateCopyWithImpl<$Res>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? user = freezed,Object? isEditing = null,Object? completedCuts = null,Object? isRewardAvailable = null,Object? isBenefitActive = null,Object? scheduledAppointments = null,Object? appointmentHistory = null,Object? recentHasMore = null,Object? coupons = null,Object? notificationIndex = null,Object? hasPendingBadge = null,Object? clientCode = freezed,Object? lastVisit = freezed,Object? branchName = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,completedCuts: null == completedCuts ? _self.completedCuts : completedCuts // ignore: cast_nullable_to_non_nullable
as int,isRewardAvailable: null == isRewardAvailable ? _self.isRewardAvailable : isRewardAvailable // ignore: cast_nullable_to_non_nullable
as bool,isBenefitActive: null == isBenefitActive ? _self.isBenefitActive : isBenefitActive // ignore: cast_nullable_to_non_nullable
as bool,scheduledAppointments: null == scheduledAppointments ? _self.scheduledAppointments : scheduledAppointments // ignore: cast_nullable_to_non_nullable
as List<Reservation>,appointmentHistory: null == appointmentHistory ? _self.appointmentHistory : appointmentHistory // ignore: cast_nullable_to_non_nullable
as List<PastAppointment>,recentHasMore: null == recentHasMore ? _self.recentHasMore : recentHasMore // ignore: cast_nullable_to_non_nullable
as bool,coupons: null == coupons ? _self.coupons : coupons // ignore: cast_nullable_to_non_nullable
as List<CustomerCoupon>,notificationIndex: null == notificationIndex ? _self.notificationIndex : notificationIndex // ignore: cast_nullable_to_non_nullable
as int,hasPendingBadge: null == hasPendingBadge ? _self.hasPendingBadge : hasPendingBadge // ignore: cast_nullable_to_non_nullable
as bool,clientCode: freezed == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String?,lastVisit: freezed == lastVisit ? _self.lastVisit : lastVisit // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProfileStatus status,  UserProfile? user,  bool isEditing,  int completedCuts,  bool isRewardAvailable,  bool isBenefitActive,  List<Reservation> scheduledAppointments,  List<PastAppointment> appointmentHistory,  bool recentHasMore,  List<CustomerCoupon> coupons,  int notificationIndex,  bool hasPendingBadge,  String? clientCode,  String? lastVisit,  String? branchName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.status,_that.user,_that.isEditing,_that.completedCuts,_that.isRewardAvailable,_that.isBenefitActive,_that.scheduledAppointments,_that.appointmentHistory,_that.recentHasMore,_that.coupons,_that.notificationIndex,_that.hasPendingBadge,_that.clientCode,_that.lastVisit,_that.branchName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProfileStatus status,  UserProfile? user,  bool isEditing,  int completedCuts,  bool isRewardAvailable,  bool isBenefitActive,  List<Reservation> scheduledAppointments,  List<PastAppointment> appointmentHistory,  bool recentHasMore,  List<CustomerCoupon> coupons,  int notificationIndex,  bool hasPendingBadge,  String? clientCode,  String? lastVisit,  String? branchName)  $default,) {final _that = this;
switch (_that) {
case _ProfileState():
return $default(_that.status,_that.user,_that.isEditing,_that.completedCuts,_that.isRewardAvailable,_that.isBenefitActive,_that.scheduledAppointments,_that.appointmentHistory,_that.recentHasMore,_that.coupons,_that.notificationIndex,_that.hasPendingBadge,_that.clientCode,_that.lastVisit,_that.branchName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProfileStatus status,  UserProfile? user,  bool isEditing,  int completedCuts,  bool isRewardAvailable,  bool isBenefitActive,  List<Reservation> scheduledAppointments,  List<PastAppointment> appointmentHistory,  bool recentHasMore,  List<CustomerCoupon> coupons,  int notificationIndex,  bool hasPendingBadge,  String? clientCode,  String? lastVisit,  String? branchName)?  $default,) {final _that = this;
switch (_that) {
case _ProfileState() when $default != null:
return $default(_that.status,_that.user,_that.isEditing,_that.completedCuts,_that.isRewardAvailable,_that.isBenefitActive,_that.scheduledAppointments,_that.appointmentHistory,_that.recentHasMore,_that.coupons,_that.notificationIndex,_that.hasPendingBadge,_that.clientCode,_that.lastVisit,_that.branchName);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileState implements ProfileState {
  const _ProfileState({this.status = ProfileStatus.initial, this.user, this.isEditing = false, this.completedCuts = 0, this.isRewardAvailable = false, this.isBenefitActive = false, final  List<Reservation> scheduledAppointments = const [], final  List<PastAppointment> appointmentHistory = const [], this.recentHasMore = false, final  List<CustomerCoupon> coupons = const <CustomerCoupon>[], this.notificationIndex = 0, this.hasPendingBadge = false, this.clientCode, this.lastVisit, this.branchName}): _scheduledAppointments = scheduledAppointments,_appointmentHistory = appointmentHistory,_coupons = coupons;
  

@override@JsonKey() final  ProfileStatus status;
@override final  UserProfile? user;
@override@JsonKey() final  bool isEditing;
@override@JsonKey() final  int completedCuts;
@override@JsonKey() final  bool isRewardAvailable;
@override@JsonKey() final  bool isBenefitActive;
 final  List<Reservation> _scheduledAppointments;
@override@JsonKey() List<Reservation> get scheduledAppointments {
  if (_scheduledAppointments is EqualUnmodifiableListView) return _scheduledAppointments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduledAppointments);
}

 final  List<PastAppointment> _appointmentHistory;
@override@JsonKey() List<PastAppointment> get appointmentHistory {
  if (_appointmentHistory is EqualUnmodifiableListView) return _appointmentHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_appointmentHistory);
}

@override@JsonKey() final  bool recentHasMore;
 final  List<CustomerCoupon> _coupons;
@override@JsonKey() List<CustomerCoupon> get coupons {
  if (_coupons is EqualUnmodifiableListView) return _coupons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coupons);
}

@override@JsonKey() final  int notificationIndex;
@override@JsonKey() final  bool hasPendingBadge;
@override final  String? clientCode;
@override final  String? lastVisit;
@override final  String? branchName;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStateCopyWith<_ProfileState> get copyWith => __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.completedCuts, completedCuts) || other.completedCuts == completedCuts)&&(identical(other.isRewardAvailable, isRewardAvailable) || other.isRewardAvailable == isRewardAvailable)&&(identical(other.isBenefitActive, isBenefitActive) || other.isBenefitActive == isBenefitActive)&&const DeepCollectionEquality().equals(other._scheduledAppointments, _scheduledAppointments)&&const DeepCollectionEquality().equals(other._appointmentHistory, _appointmentHistory)&&(identical(other.recentHasMore, recentHasMore) || other.recentHasMore == recentHasMore)&&const DeepCollectionEquality().equals(other._coupons, _coupons)&&(identical(other.notificationIndex, notificationIndex) || other.notificationIndex == notificationIndex)&&(identical(other.hasPendingBadge, hasPendingBadge) || other.hasPendingBadge == hasPendingBadge)&&(identical(other.clientCode, clientCode) || other.clientCode == clientCode)&&(identical(other.lastVisit, lastVisit) || other.lastVisit == lastVisit)&&(identical(other.branchName, branchName) || other.branchName == branchName));
}


@override
int get hashCode => Object.hash(runtimeType,status,user,isEditing,completedCuts,isRewardAvailable,isBenefitActive,const DeepCollectionEquality().hash(_scheduledAppointments),const DeepCollectionEquality().hash(_appointmentHistory),recentHasMore,const DeepCollectionEquality().hash(_coupons),notificationIndex,hasPendingBadge,clientCode,lastVisit,branchName);

@override
String toString() {
  return 'ProfileState(status: $status, user: $user, isEditing: $isEditing, completedCuts: $completedCuts, isRewardAvailable: $isRewardAvailable, isBenefitActive: $isBenefitActive, scheduledAppointments: $scheduledAppointments, appointmentHistory: $appointmentHistory, recentHasMore: $recentHasMore, coupons: $coupons, notificationIndex: $notificationIndex, hasPendingBadge: $hasPendingBadge, clientCode: $clientCode, lastVisit: $lastVisit, branchName: $branchName)';
}


}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(_ProfileState value, $Res Function(_ProfileState) _then) = __$ProfileStateCopyWithImpl;
@override @useResult
$Res call({
 ProfileStatus status, UserProfile? user, bool isEditing, int completedCuts, bool isRewardAvailable, bool isBenefitActive, List<Reservation> scheduledAppointments, List<PastAppointment> appointmentHistory, bool recentHasMore, List<CustomerCoupon> coupons, int notificationIndex, bool hasPendingBadge, String? clientCode, String? lastVisit, String? branchName
});


@override $UserProfileCopyWith<$Res>? get user;

}
/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? user = freezed,Object? isEditing = null,Object? completedCuts = null,Object? isRewardAvailable = null,Object? isBenefitActive = null,Object? scheduledAppointments = null,Object? appointmentHistory = null,Object? recentHasMore = null,Object? coupons = null,Object? notificationIndex = null,Object? hasPendingBadge = null,Object? clientCode = freezed,Object? lastVisit = freezed,Object? branchName = freezed,}) {
  return _then(_ProfileState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ProfileStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile?,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,completedCuts: null == completedCuts ? _self.completedCuts : completedCuts // ignore: cast_nullable_to_non_nullable
as int,isRewardAvailable: null == isRewardAvailable ? _self.isRewardAvailable : isRewardAvailable // ignore: cast_nullable_to_non_nullable
as bool,isBenefitActive: null == isBenefitActive ? _self.isBenefitActive : isBenefitActive // ignore: cast_nullable_to_non_nullable
as bool,scheduledAppointments: null == scheduledAppointments ? _self._scheduledAppointments : scheduledAppointments // ignore: cast_nullable_to_non_nullable
as List<Reservation>,appointmentHistory: null == appointmentHistory ? _self._appointmentHistory : appointmentHistory // ignore: cast_nullable_to_non_nullable
as List<PastAppointment>,recentHasMore: null == recentHasMore ? _self.recentHasMore : recentHasMore // ignore: cast_nullable_to_non_nullable
as bool,coupons: null == coupons ? _self._coupons : coupons // ignore: cast_nullable_to_non_nullable
as List<CustomerCoupon>,notificationIndex: null == notificationIndex ? _self.notificationIndex : notificationIndex // ignore: cast_nullable_to_non_nullable
as int,hasPendingBadge: null == hasPendingBadge ? _self.hasPendingBadge : hasPendingBadge // ignore: cast_nullable_to_non_nullable
as bool,clientCode: freezed == clientCode ? _self.clientCode : clientCode // ignore: cast_nullable_to_non_nullable
as String?,lastVisit: freezed == lastVisit ? _self.lastVisit : lastVisit // ignore: cast_nullable_to_non_nullable
as String?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
