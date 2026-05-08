// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  tenantId: json['tenantId'] as String,
  id: json['id'] as String?,
  center: json['center'] == null
      ? null
      : BarberCenter.fromJson(json['center'] as Map<String, dynamic>),
  services:
      (json['services'] as List<dynamic>?)
          ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  professional: json['professional'] == null
      ? null
      : Professional.fromJson(json['professional'] as Map<String, dynamic>),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  time: json['time'] as String?,
  totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
  totalDurationInMinutes:
      (json['totalDurationInMinutes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'id': instance.id,
      'center': instance.center,
      'services': instance.services,
      'professional': instance.professional,
      'date': instance.date?.toIso8601String(),
      'time': instance.time,
      'totalPrice': instance.totalPrice,
      'totalDurationInMinutes': instance.totalDurationInMinutes,
    };
