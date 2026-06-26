// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeContent _$HomeContentFromJson(Map<String, dynamic> json) => _HomeContent(
  heroTitle: json['heroTitle'] as String? ?? '',
  heroSubtitle: json['heroSubtitle'] as String? ?? '',
  heroImageUrl: json['heroImageUrl'] as String? ?? '',
  heroTag1: json['heroTag1'] as String? ?? '',
  heroTag2: json['heroTag2'] as String? ?? '',
  stories:
      (json['stories'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ??
      const [],
  services:
      (json['services'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ??
      const [],
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ??
      const [],
  aboutUsTitle: json['aboutUsTitle'] as String? ?? '',
  aboutUsText: json['aboutUsText'] as String? ?? '',
  aboutUsImageUrl: json['aboutUsImageUrl'] as String? ?? '',
  aboutUsVideoUrl: json['aboutUsVideoUrl'] as String? ?? '',
  socialLinks:
      (json['socialLinks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {'instagram': '', 'tiktok': '', 'whatsapp': '', 'facebook': ''},
  locations:
      (json['locations'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HomeContentToJson(_HomeContent instance) =>
    <String, dynamic>{
      'heroTitle': instance.heroTitle,
      'heroSubtitle': instance.heroSubtitle,
      'heroImageUrl': instance.heroImageUrl,
      'heroTag1': instance.heroTag1,
      'heroTag2': instance.heroTag2,
      'stories': instance.stories,
      'services': instance.services,
      'products': instance.products,
      'aboutUsTitle': instance.aboutUsTitle,
      'aboutUsText': instance.aboutUsText,
      'aboutUsImageUrl': instance.aboutUsImageUrl,
      'aboutUsVideoUrl': instance.aboutUsVideoUrl,
      'socialLinks': instance.socialLinks,
      'locations': instance.locations,
    };
