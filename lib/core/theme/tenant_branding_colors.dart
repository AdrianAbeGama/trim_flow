import 'package:core/core.dart';
import 'package:flutter/material.dart';

class TenantBrandingColors implements AppColorsInterface {
  TenantBrandingColors._({
    required this.primaryGold,
    required this.backgroundBlack,
    required this.surfaceDark,
    required this.accentGold,
  });

  @override
  final Color primaryGold;

  @override
  final Color backgroundBlack;

  @override
  final Color surfaceDark;

  @override
  final Color accentGold;

  @override
  Color get textWhite => const Color(0xFFFFFFFF);

  @override
  Color get errorRed => const Color(0xFFCF6679);

  static AppColorsInterface? tryParse(Map<String, dynamic>? branding) {
    if (branding == null) return null;
    final primary = _parseHex(branding['primary_color']);
    final accent = _parseHex(branding['accent_color']);
    if (primary == null || accent == null) return null;
    final secondary = _parseHex(branding['secondary_color']);

    return TenantBrandingColors._(
      primaryGold: accent,
      backgroundBlack: primary,
      surfaceDark: secondary ?? _lighten(primary, 0.06),
      accentGold: _darken(accent, 0.08),
    );
  }

  static Color? _parseHex(dynamic value) {
    if (value is! String) return null;
    var hex = value.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final intValue = int.tryParse(hex, radix: 16);
    if (intValue == null) return null;
    return Color(intValue);
  }

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
