// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CuttingRecord {

 String get day; String get time; String get price;
/// Create a copy of CuttingRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CuttingRecordCopyWith<CuttingRecord> get copyWith => _$CuttingRecordCopyWithImpl<CuttingRecord>(this as CuttingRecord, _$identity);

  /// Serializes this CuttingRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CuttingRecord&&(identical(other.day, day) || other.day == day)&&(identical(other.time, time) || other.time == time)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,time,price);

@override
String toString() {
  return 'CuttingRecord(day: $day, time: $time, price: $price)';
}


}

/// @nodoc
abstract mixin class $CuttingRecordCopyWith<$Res>  {
  factory $CuttingRecordCopyWith(CuttingRecord value, $Res Function(CuttingRecord) _then) = _$CuttingRecordCopyWithImpl;
@useResult
$Res call({
 String day, String time, String price
});




}
/// @nodoc
class _$CuttingRecordCopyWithImpl<$Res>
    implements $CuttingRecordCopyWith<$Res> {
  _$CuttingRecordCopyWithImpl(this._self, this._then);

  final CuttingRecord _self;
  final $Res Function(CuttingRecord) _then;

/// Create a copy of CuttingRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? time = null,Object? price = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CuttingRecord].
extension CuttingRecordPatterns on CuttingRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CuttingRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CuttingRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CuttingRecord value)  $default,){
final _that = this;
switch (_that) {
case _CuttingRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CuttingRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CuttingRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  String time,  String price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CuttingRecord() when $default != null:
return $default(_that.day,_that.time,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  String time,  String price)  $default,) {final _that = this;
switch (_that) {
case _CuttingRecord():
return $default(_that.day,_that.time,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  String time,  String price)?  $default,) {final _that = this;
switch (_that) {
case _CuttingRecord() when $default != null:
return $default(_that.day,_that.time,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CuttingRecord implements CuttingRecord {
  const _CuttingRecord({required this.day, required this.time, required this.price});
  factory _CuttingRecord.fromJson(Map<String, dynamic> json) => _$CuttingRecordFromJson(json);

@override final  String day;
@override final  String time;
@override final  String price;

/// Create a copy of CuttingRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CuttingRecordCopyWith<_CuttingRecord> get copyWith => __$CuttingRecordCopyWithImpl<_CuttingRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CuttingRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CuttingRecord&&(identical(other.day, day) || other.day == day)&&(identical(other.time, time) || other.time == time)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,time,price);

@override
String toString() {
  return 'CuttingRecord(day: $day, time: $time, price: $price)';
}


}

/// @nodoc
abstract mixin class _$CuttingRecordCopyWith<$Res> implements $CuttingRecordCopyWith<$Res> {
  factory _$CuttingRecordCopyWith(_CuttingRecord value, $Res Function(_CuttingRecord) _then) = __$CuttingRecordCopyWithImpl;
@override @useResult
$Res call({
 String day, String time, String price
});




}
/// @nodoc
class __$CuttingRecordCopyWithImpl<$Res>
    implements _$CuttingRecordCopyWith<$Res> {
  __$CuttingRecordCopyWithImpl(this._self, this._then);

  final _CuttingRecord _self;
  final $Res Function(_CuttingRecord) _then;

/// Create a copy of CuttingRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? time = null,Object? price = null,}) {
  return _then(_CuttingRecord(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserProfile {

 String get tenantId; String get id; String get firstName; String get lastName; String get email; String get photoUrl; String get phone; String get birthDate; bool get notificationsEnabled; String? get customerId; String? get barberId; int get completedCuts; List<CuttingRecord> get history;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.completedCuts, completedCuts) || other.completedCuts == completedCuts)&&const DeepCollectionEquality().equals(other.history, history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,firstName,lastName,email,photoUrl,phone,birthDate,notificationsEnabled,customerId,barberId,completedCuts,const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'UserProfile(tenantId: $tenantId, id: $id, firstName: $firstName, lastName: $lastName, email: $email, photoUrl: $photoUrl, phone: $phone, birthDate: $birthDate, notificationsEnabled: $notificationsEnabled, customerId: $customerId, barberId: $barberId, completedCuts: $completedCuts, history: $history)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String tenantId, String id, String firstName, String lastName, String email, String photoUrl, String phone, String birthDate, bool notificationsEnabled, String? customerId, String? barberId, int completedCuts, List<CuttingRecord> history
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? photoUrl = null,Object? phone = null,Object? birthDate = null,Object? notificationsEnabled = null,Object? customerId = freezed,Object? barberId = freezed,Object? completedCuts = null,Object? history = null,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,barberId: freezed == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String?,completedCuts: null == completedCuts ? _self.completedCuts : completedCuts // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<CuttingRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  String id,  String firstName,  String lastName,  String email,  String photoUrl,  String phone,  String birthDate,  bool notificationsEnabled,  String? customerId,  String? barberId,  int completedCuts,  List<CuttingRecord> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.tenantId,_that.id,_that.firstName,_that.lastName,_that.email,_that.photoUrl,_that.phone,_that.birthDate,_that.notificationsEnabled,_that.customerId,_that.barberId,_that.completedCuts,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  String id,  String firstName,  String lastName,  String email,  String photoUrl,  String phone,  String birthDate,  bool notificationsEnabled,  String? customerId,  String? barberId,  int completedCuts,  List<CuttingRecord> history)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.tenantId,_that.id,_that.firstName,_that.lastName,_that.email,_that.photoUrl,_that.phone,_that.birthDate,_that.notificationsEnabled,_that.customerId,_that.barberId,_that.completedCuts,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  String id,  String firstName,  String lastName,  String email,  String photoUrl,  String phone,  String birthDate,  bool notificationsEnabled,  String? customerId,  String? barberId,  int completedCuts,  List<CuttingRecord> history)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.tenantId,_that.id,_that.firstName,_that.lastName,_that.email,_that.photoUrl,_that.phone,_that.birthDate,_that.notificationsEnabled,_that.customerId,_that.barberId,_that.completedCuts,_that.history);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.tenantId, required this.id, required this.firstName, required this.lastName, required this.email, required this.photoUrl, required this.phone, required this.birthDate, required this.notificationsEnabled, this.customerId, this.barberId, this.completedCuts = 2, final  List<CuttingRecord> history = const []}): _history = history;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String tenantId;
@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  String photoUrl;
@override final  String phone;
@override final  String birthDate;
@override final  bool notificationsEnabled;
@override final  String? customerId;
@override final  String? barberId;
@override@JsonKey() final  int completedCuts;
 final  List<CuttingRecord> _history;
@override@JsonKey() List<CuttingRecord> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.completedCuts, completedCuts) || other.completedCuts == completedCuts)&&const DeepCollectionEquality().equals(other._history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,firstName,lastName,email,photoUrl,phone,birthDate,notificationsEnabled,customerId,barberId,completedCuts,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'UserProfile(tenantId: $tenantId, id: $id, firstName: $firstName, lastName: $lastName, email: $email, photoUrl: $photoUrl, phone: $phone, birthDate: $birthDate, notificationsEnabled: $notificationsEnabled, customerId: $customerId, barberId: $barberId, completedCuts: $completedCuts, history: $history)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, String id, String firstName, String lastName, String email, String photoUrl, String phone, String birthDate, bool notificationsEnabled, String? customerId, String? barberId, int completedCuts, List<CuttingRecord> history
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? photoUrl = null,Object? phone = null,Object? birthDate = null,Object? notificationsEnabled = null,Object? customerId = freezed,Object? barberId = freezed,Object? completedCuts = null,Object? history = null,}) {
  return _then(_UserProfile(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,customerId: freezed == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String?,barberId: freezed == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String?,completedCuts: null == completedCuts ? _self.completedCuts : completedCuts // ignore: cast_nullable_to_non_nullable
as int,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<CuttingRecord>,
  ));
}


}

// dart format on
