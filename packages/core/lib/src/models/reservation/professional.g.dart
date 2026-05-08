// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professional.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Professional _$ProfessionalFromJson(Map<String, dynamic> json) =>
    _Professional(
      tenantId: json['tenantId'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      specialties: (json['specialties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      statusLabel: json['statusLabel'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ProfessionalToJson(_Professional instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'id': instance.id,
      'name': instance.name,
      'specialties': instance.specialties,
      'yearsOfExperience': instance.yearsOfExperience,
      'isAvailable': instance.isAvailable,
      'statusLabel': instance.statusLabel,
      'imageUrl': instance.imageUrl,
    };
