// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CuttingRecord _$CuttingRecordFromJson(Map<String, dynamic> json) =>
    _CuttingRecord(
      day: json['day'] as String,
      time: json['time'] as String,
      price: json['price'] as String,
    );

Map<String, dynamic> _$CuttingRecordToJson(_CuttingRecord instance) =>
    <String, dynamic>{
      'day': instance.day,
      'time': instance.time,
      'price': instance.price,
    };

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  tenantId: json['tenantId'] as String,
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  photoUrl: json['photoUrl'] as String,
  phone: json['phone'] as String,
  birthDate: json['birthDate'] as String,
  notificationsEnabled: json['notificationsEnabled'] as bool,
  customerId: json['customerId'] as String?,
  barberId: json['barberId'] as String?,
  branchId: json['branchId'] as String?,
  completedCuts: (json['completedCuts'] as num?)?.toInt() ?? 2,
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => CuttingRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'phone': instance.phone,
      'birthDate': instance.birthDate,
      'notificationsEnabled': instance.notificationsEnabled,
      'customerId': instance.customerId,
      'barberId': instance.barberId,
      'branchId': instance.branchId,
      'completedCuts': instance.completedCuts,
      'history': instance.history,
    };
