import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_content.freezed.dart';
part 'home_content.g.dart';

@freezed
abstract class HomeContent with _$HomeContent {
  const factory HomeContent({
    @Default('') String heroTitle,
    @Default('') String heroSubtitle,
    @Default('') String heroImageUrl,
    @Default('') String heroTag1,
    @Default('') String heroTag2,
    @Default([]) List<Map<String, String>> stories,
    @Default([]) List<Map<String, String>> services,
    @Default([]) List<Map<String, String>> products,
    @Default('') String aboutUsTitle,
    @Default('') String aboutUsText,
    @Default('') String aboutUsImageUrl,
    @Default('') String aboutUsVideoUrl,
    @Default({
      'instagram': '',
      'tiktok': '',
      'whatsapp': '',
      'facebook': ''
    }) Map<String, String> socialLinks,
    @Default([]) List<Map<String, String>> locations,
  }) = _HomeContent;

  factory HomeContent.fromJson(Map<String, dynamic> json) => _$HomeContentFromJson(json);
}
