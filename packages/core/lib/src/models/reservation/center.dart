import 'package:freezed_annotation/freezed_annotation.dart';

part 'center.freezed.dart';
part 'center.g.dart';

@freezed
abstract class BarberCenter with _$BarberCenter {
  const factory BarberCenter({
    required String tenantId,
    required String id,
    required String name,
    required String location,
    String? imageUrl,
  }) = _BarberCenter;

  factory BarberCenter.fromJson(Map<String, dynamic> json) => _$BarberCenterFromJson(json);
}
