import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DefaultTenantColors implements AppColorsInterface {
  @override
  Color get primaryGold => const Color(0xFFD4AF37);
  
  @override
  Color get backgroundBlack => const Color(0xFF000000);
  
  @override
  Color get textWhite => const Color(0xFFFFFFFF);
  
  @override
  Color get surfaceDark => const Color(0xFF1A1A1A);
  
  @override
  Color get accentGold => const Color(0xFFC5A028);
  
  @override
  Color get errorRed => const Color(0xFFCF6679);
}
