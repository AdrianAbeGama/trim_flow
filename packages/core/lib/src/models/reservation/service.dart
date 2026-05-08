import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';
part 'service.g.dart';

@freezed
abstract class Service with _$Service {
  const factory Service({
    required String tenantId,
    required String id,
    required String name,
    required double price,
    required int durationInMinutes,
    required String category,
    @Default(false) bool isFeatured,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
}
