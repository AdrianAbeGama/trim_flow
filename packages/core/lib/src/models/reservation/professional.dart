import 'package:freezed_annotation/freezed_annotation.dart';

part 'professional.freezed.dart';
part 'professional.g.dart';

@freezed
abstract class Professional with _$Professional {
  const factory Professional({
    required String tenantId,
    required String id,
    required String name,
    required List<String> specialties,
    required int yearsOfExperience,
    @Default(true) bool isAvailable,
    String? statusLabel,
    String? imageUrl,
  }) = _Professional;

  factory Professional.fromJson(Map<String, dynamic> json) =>
      _$ProfessionalFromJson(json);
}
