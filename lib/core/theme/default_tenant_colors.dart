import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Paleta universal de marca TrimFlow (SaaS): negro / blanco / gris titanio.
/// Se usa cuando no hay tenant resuelto (splash, login, post-login transitorio).
/// Los tenants reales (Ocean, Verde, Dream Flow, etc.) la sobreescriben con
/// su propia paleta via tenants.branding JSONB → TenantBrandingColors.
class DefaultTenantColors implements AppColorsInterface {
  @override
  Color get primaryGold => const Color(0xFFB8BCBF);

  @override
  Color get backgroundBlack => const Color(0xFF000000);

  @override
  Color get textWhite => const Color(0xFFFFFFFF);

  @override
  Color get surfaceDark => const Color(0xFF1A1A1A);

  @override
  Color get accentGold => const Color(0xFF7C8084);

  @override
  Color get errorRed => const Color(0xFFCF6679);
}
