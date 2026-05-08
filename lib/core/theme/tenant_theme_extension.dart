import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';

extension TenantThemeExtension on BuildContext {
  AppColorsInterface get tenantColors => watch<TenantThemeBloc>().state.colors;
  
  // Shortcut for common colors
  Color get primaryGold => tenantColors.primaryGold;
  Color get backgroundBlack => tenantColors.backgroundBlack;
}
