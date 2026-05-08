// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reservation {

 String get tenantId; String? get id; BarberCenter? get center; List<Service> get services; Professional? get professional; DateTime? get date; String? get time; double get totalPrice; int get totalDurationInMinutes;
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationCopyWith<Reservation> get copyWith => _$ReservationCopyWithImpl<Reservation>(this as Reservation, _$identity);

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reservation&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.center, center) || other.center == center)&&const DeepCollectionEquality().equals(other.services, services)&&(identical(other.professional, professional) || other.professional == professional)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.totalDurationInMinutes, totalDurationInMinutes) || other.totalDurationInMinutes == totalDurationInMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,center,const DeepCollectionEquality().hash(services),professional,date,time,totalPrice,totalDurationInMinutes);

@override
String toString() {
  return 'Reservation(tenantId: $tenantId, id: $id, center: $center, services: $services, professional: $professional, date: $date, time: $time, totalPrice: $totalPrice, totalDurationInMinutes: $totalDurationInMinutes)';
}


}

/// @nodoc
abstract mixin class $ReservationCopyWith<$Res>  {
  factory $ReservationCopyWith(Reservation value, $Res Function(Reservation) _then) = _$ReservationCopyWithImpl;
@useResult
$Res call({
 String tenantId, String? id, BarberCenter? center, List<Service> services, Professional? professional, DateTime? date, String? time, double totalPrice, int totalDurationInMinutes
});


$BarberCenterCopyWith<$Res>? get center;$ProfessionalCopyWith<$Res>? get professional;

}
/// @nodoc
class _$ReservationCopyWithImpl<$Res>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._self, this._then);

  final Reservation _self;
  final $Res Function(Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? id = freezed,Object? center = freezed,Object? services = null,Object? professional = freezed,Object? date = freezed,Object? time = freezed,Object? totalPrice = null,Object? totalDurationInMinutes = null,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,center: freezed == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as BarberCenter?,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<Service>,professional: freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as Professional?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,totalDurationInMinutes: null == totalDurationInMinutes ? _self.totalDurationInMinutes : totalDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BarberCenterCopyWith<$Res>? get center {
    if (_self.center == null) {
    return null;
  }

  return $BarberCenterCopyWith<$Res>(_self.center!, (value) {
    return _then(_self.copyWith(center: value));
  });
}/// Create a copy of Reservation
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


/// Adds pattern-matching-related methods to [Reservation].
extension ReservationPatterns on Reservation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reservation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reservation value)  $default,){
final _that = this;
switch (_that) {
case _Reservation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reservation value)?  $default,){
final _that = this;
switch (_that) {
case _Reservation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tenantId,  String? id,  BarberCenter? center,  List<Service> services,  Professional? professional,  DateTime? date,  String? time,  double totalPrice,  int totalDurationInMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.tenantId,_that.id,_that.center,_that.services,_that.professional,_that.date,_that.time,_that.totalPrice,_that.totalDurationInMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tenantId,  String? id,  BarberCenter? center,  List<Service> services,  Professional? professional,  DateTime? date,  String? time,  double totalPrice,  int totalDurationInMinutes)  $default,) {final _that = this;
switch (_that) {
case _Reservation():
return $default(_that.tenantId,_that.id,_that.center,_that.services,_that.professional,_that.date,_that.time,_that.totalPrice,_that.totalDurationInMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tenantId,  String? id,  BarberCenter? center,  List<Service> services,  Professional? professional,  DateTime? date,  String? time,  double totalPrice,  int totalDurationInMinutes)?  $default,) {final _that = this;
switch (_that) {
case _Reservation() when $default != null:
return $default(_that.tenantId,_that.id,_that.center,_that.services,_that.professional,_that.date,_that.time,_that.totalPrice,_that.totalDurationInMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reservation implements Reservation {
  const _Reservation({required this.tenantId, this.id, this.center, final  List<Service> services = const [], this.professional, this.date, this.time, this.totalPrice = 0.0, this.totalDurationInMinutes = 0}): _services = services;
  factory _Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);

@override final  String tenantId;
@override final  String? id;
@override final  BarberCenter? center;
 final  List<Service> _services;
@override@JsonKey() List<Service> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

@override final  Professional? professional;
@override final  DateTime? date;
@override final  String? time;
@override@JsonKey() final  double totalPrice;
@override@JsonKey() final  int totalDurationInMinutes;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationCopyWith<_Reservation> get copyWith => __$ReservationCopyWithImpl<_Reservation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reservation&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.id, id) || other.id == id)&&(identical(other.center, center) || other.center == center)&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.professional, professional) || other.professional == professional)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.totalDurationInMinutes, totalDurationInMinutes) || other.totalDurationInMinutes == totalDurationInMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,id,center,const DeepCollectionEquality().hash(_services),professional,date,time,totalPrice,totalDurationInMinutes);

@override
String toString() {
  return 'Reservation(tenantId: $tenantId, id: $id, center: $center, services: $services, professional: $professional, date: $date, time: $time, totalPrice: $totalPrice, totalDurationInMinutes: $totalDurationInMinutes)';
}


}

/// @nodoc
abstract mixin class _$ReservationCopyWith<$Res> implements $ReservationCopyWith<$Res> {
  factory _$ReservationCopyWith(_Reservation value, $Res Function(_Reservation) _then) = __$ReservationCopyWithImpl;
@override @useResult
$Res call({
 String tenantId, String? id, BarberCenter? center, List<Service> services, Professional? professional, DateTime? date, String? time, double totalPrice, int totalDurationInMinutes
});


@override $BarberCenterCopyWith<$Res>? get center;@override $ProfessionalCopyWith<$Res>? get professional;

}
/// @nodoc
class __$ReservationCopyWithImpl<$Res>
    implements _$ReservationCopyWith<$Res> {
  __$ReservationCopyWithImpl(this._self, this._then);

  final _Reservation _self;
  final $Res Function(_Reservation) _then;

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? id = freezed,Object? center = freezed,Object? services = null,Object? professional = freezed,Object? date = freezed,Object? time = freezed,Object? totalPrice = null,Object? totalDurationInMinutes = null,}) {
  return _then(_Reservation(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,center: freezed == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as BarberCenter?,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<Service>,professional: freezed == professional ? _self.professional : professional // ignore: cast_nullable_to_non_nullable
as Professional?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,totalDurationInMinutes: null == totalDurationInMinutes ? _self.totalDurationInMinutes : totalDurationInMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Reservation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BarberCenterCopyWith<$Res>? get center {
    if (_self.center == null) {
    return null;
  }

  return $BarberCenterCopyWith<$Res>(_self.center!, (value) {
    return _then(_self.copyWith(center: value));
  });
}/// Create a copy of Reservation
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

// dart format on
