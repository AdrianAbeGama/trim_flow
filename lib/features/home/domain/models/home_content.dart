import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_content.freezed.dart';
part 'home_content.g.dart';

@freezed
abstract class HomeContent with _$HomeContent {
  const factory HomeContent({
    @Default('TrimFlow Premium Studio') String heroTitle,
    @Default('Donde el estilo se encuentra con la precisión.') String heroSubtitle,
    @Default('https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800') String heroImageUrl,
    @Default('DREAM FLOW ELITE') String heroTag1,
    @Default('PREMIUM STUDIO') String heroTag2,
    @Default([]) List<Map<String, String>> stories,
    @Default([]) List<Map<String, String>> services,
    @Default([]) List<Map<String, String>> products,
    @Default('Sobre Nosotros') String aboutUsTitle,
    @Default('Pasión por el detalle, respeto por la tradición y compromiso con tu estilo. Bienvenido a la experiencia Trimflow.') String aboutUsText,
    @Default('https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800') String aboutUsImageUrl,
    @Default('') String aboutUsVideoUrl,
    @Default({
      'instagram': '',
      'tiktok': '',
      'whatsapp': '',
      'facebook': ''
    }) Map<String, String> socialLinks,
    @Default([
      {'label': 'Sede Central', 'address': 'CALLE PRINCIPAL 123, AREQUIPA', 'mapUrl': 'https://maps.google.com'},
      {'label': 'Sede Yanahuara', 'address': 'AV. EJÉRCITO 456, AREQUIPA', 'mapUrl': 'https://maps.google.com'}
    ]) List<Map<String, String>> locations,
  }) = _HomeContent;

  factory HomeContent.fromJson(Map<String, dynamic> json) => _$HomeContentFromJson(json);
}
