import 'package:flutter/material.dart';

/// Interface defining the essential colors for a Tenant.
/// All UI components should consume these through a theme manager.
abstract class AppColorsInterface {
  Color get primaryGold;
  Color get backgroundBlack;
  Color get textWhite;
  Color get surfaceDark;
  Color get accentGold;
  Color get errorRed;
}
