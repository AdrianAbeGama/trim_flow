import 'package:core/core.dart';

class TenantInfo {
  final String id;
  final String name;
  final String slug;
  final AppColorsInterface colors;
  final int points;

  const TenantInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.colors,
    this.points = 0,
  });
}
