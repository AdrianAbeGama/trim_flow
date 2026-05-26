import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/theme/default_tenant_colors.dart';

const String kDefaultTenantId = 'default';

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
      tenantId: kDefaultTenantId,
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
      fontFamily: 'Inter',
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

@lazySingleton
class TenantThemeBloc extends Cubit<TenantThemeState> {
  TenantThemeBloc() : super(TenantThemeState.initial());

  StreamSubscription<AuthState>? _authSub;
  bool _resolving = false;

  void loadTenant(String tenantId) {
    emit(state.copyWith(tenantId: tenantId));
  }

  Future<void> loadTenantFromAuth() async {
    _ensureAuthSubscription();
    await _resolveTenantFromAuth();
  }

  Future<void> _resolveTenantFromAuth() async {
    if (_resolving) return;
    _resolving = true;
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        emit(state.copyWith(tenantId: kDefaultTenantId));
        return;
      }

      final resolvedTenantId = await _lookupTenantId(client, user.id);

      if (resolvedTenantId != null) {
        emit(state.copyWith(tenantId: resolvedTenantId));
      } else {
        emit(state.copyWith(tenantId: kDefaultTenantId));
      }
    } catch (e) {
      debugPrint('TenantThemeBloc: tenant resolution failed -> $e');
      emit(state.copyWith(tenantId: kDefaultTenantId));
    } finally {
      _resolving = false;
    }
  }

  Future<String?> _lookupTenantId(SupabaseClient client, String userId) async {
    final profileRow = await client
        .from('profiles')
        .select('tenant_id')
        .eq('id', userId)
        .maybeSingle();

    final profileTenantId = profileRow?['tenant_id'] as String?;
    if (profileTenantId != null && profileTenantId.isNotEmpty) {
      return profileTenantId;
    }

    final customerRow = await client
        .from('customers')
        .select('tenant_id')
        .eq('auth_user_id', userId)
        .maybeSingle();

    final customerTenantId = customerRow?['tenant_id'] as String?;
    if (customerTenantId != null && customerTenantId.isNotEmpty) {
      return customerTenantId;
    }

    return null;
  }

  void _ensureAuthSubscription() {
    if (_authSub != null) return;
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.signedOut ||
            event == AuthChangeEvent.userUpdated) {
          _resolveTenantFromAuth();
        }
      });
    } catch (e) {
      debugPrint('TenantThemeBloc: auth subscription failed -> $e');
    }
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    _authSub = null;
    return super.close();
  }
}
