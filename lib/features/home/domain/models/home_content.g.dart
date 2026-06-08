// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeContent _$HomeContentFromJson(Map<String, dynamic> json) => _HomeContent(
  heroTitle: json['heroTitle'] as String? ?? 'TrimFlow Premium Studio',
  heroSubtitle:
      json['heroSubtitle'] as String? ??
      'Donde el estilo se encuentra con la precisión.',
  heroImageUrl:
      json['heroImageUrl'] as String? ??
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
  heroTag1: json['heroTag1'] as String? ?? 'DREAM FLOW ELITE',
  heroTag2: json['heroTag2'] as String? ?? 'PREMIUM STUDIO',
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
  aboutUsTitle: json['aboutUsTitle'] as String? ?? 'Sobre Nosotros',
  aboutUsText:
      json['aboutUsText'] as String? ??
      'Pasión por el detalle, respeto por la tradición y compromiso con tu estilo. Bienvenido a la experiencia Trimflow.',
  aboutUsImageUrl:
      json['aboutUsImageUrl'] as String? ??
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800',
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
      const [
        {
          'label': 'Sede Central',
          'address': 'CALLE PRINCIPAL 123, AREQUIPA',
          'mapUrl': 'https://maps.google.com',
        },
        {
          'label': 'Sede Yanahuara',
          'address': 'AV. EJÉRCITO 456, AREQUIPA',
          'mapUrl': 'https://maps.google.com',
        },
      ],
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
