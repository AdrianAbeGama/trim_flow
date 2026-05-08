import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/default_tenant_colors.dart';

class TenantThemeState {
  final String tenantId;
  final AppColorsInterface colors;
  final ThemeData themeData;

  TenantThemeState({
    required this.tenantId,
    required this.colors,
    required this.themeData,
  });

  factory TenantThemeState.initial() {
    final colors = DefaultTenantColors();
    return TenantThemeState(
      tenantId: 'default',
      colors: colors,
      themeData: _buildTheme(colors),
    );
  }

  static ThemeData _buildTheme(AppColorsInterface colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.backgroundBlack,
      primaryColor: colors.primaryGold,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryGold,
        secondary: colors.accentGold,
        surface: colors.surfaceDark,
        error: colors.errorRed,
      ),
      fontFamily: 'Inter', // Assuming Inter is available
    );
  }

  TenantThemeState copyWith({
    String? tenantId,
    AppColorsInterface? colors,
  }) {
    final newColors = colors ?? this.colors;
    return TenantThemeState(
      tenantId: tenantId ?? this.tenantId,
      colors: newColors,
      themeData: _buildTheme(newColors),
    );
  }
}

class TenantThemeBloc extends Cubit<TenantThemeState> {
  TenantThemeBloc() : super(TenantThemeState.initial());

  void loadTenant(String tenantId) {
    // Simulating loading tenant config from Supabase
    // In a real scenario, this would fetch colors/logos from the DB
    emit(state.copyWith(tenantId: tenantId));
  }
}
