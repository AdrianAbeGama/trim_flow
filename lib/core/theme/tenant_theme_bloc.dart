import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/theme/default_tenant_colors.dart';
import 'package:trim_flow/core/theme/tenant_branding_colors.dart';

const String kDefaultTenantId = 'default';

class TenantThemeState {
  final String tenantId;
  final AppColorsInterface colors;
  final ThemeData themeData;
  final bool isResolving;
  final bool isResolved;
  final String? resolvedForUserId;

  TenantThemeState({
    required this.tenantId,
    required this.colors,
    required this.themeData,
    this.isResolving = false,
    this.isResolved = false,
    this.resolvedForUserId,
  });

  factory TenantThemeState.initial() {
    final colors = DefaultTenantColors();
    return TenantThemeState(
      tenantId: kDefaultTenantId,
      colors: colors,
      themeData: _buildTheme(colors),
      isResolving: false,
      isResolved: false,
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _PremiumFadeTransitionsBuilder(),
          TargetPlatform.iOS: _PremiumFadeTransitionsBuilder(),
          TargetPlatform.fuchsia: _PremiumFadeTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }

  TenantThemeState copyWith({
    String? tenantId,
    AppColorsInterface? colors,
    bool? isResolving,
    bool? isResolved,
    String? resolvedForUserId,
    bool clearResolvedForUserId = false,
  }) {
    final newColors = colors ?? this.colors;
    return TenantThemeState(
      tenantId: tenantId ?? this.tenantId,
      colors: newColors,
      themeData: _buildTheme(newColors),
      isResolving: isResolving ?? this.isResolving,
      isResolved: isResolved ?? this.isResolved,
      resolvedForUserId: clearResolvedForUserId
          ? null
          : (resolvedForUserId ?? this.resolvedForUserId),
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

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final currentUserId = user?.id;

    // Guarda: si ya está resuelto para este mismo usuario, no re-fetch.
    // Evita el loader transitorio cuando Supabase re-emite signedIn al
    // arrancar (sesión restaurada).
    if (state.isResolved && state.resolvedForUserId == currentUserId) {
      return;
    }

    _resolving = true;
    emit(state.copyWith(isResolving: true));
    try {
      if (user == null) {
        emit(TenantThemeState.initial().copyWith(
          isResolved: true,
          clearResolvedForUserId: true,
        ));
        return;
      }

      final resolvedTenantId = await _lookupTenantId(client, user.id);

      if (resolvedTenantId != null) {
        final colors = await _fetchTenantColors(client, resolvedTenantId);
        if (colors != null) {
          emit(state.copyWith(
            tenantId: resolvedTenantId,
            colors: colors,
            isResolving: false,
            isResolved: true,
            resolvedForUserId: user.id,
          ));
        } else {
          // Fallo transitorio al leer el branding: no degradar a titanio si ya
          // teníamos un tenant real resuelto; conservar sus colores.
          _emitPreservingColors(user.id);
        }
      } else {
        emit(TenantThemeState.initial().copyWith(
          isResolved: true,
          resolvedForUserId: user.id,
        ));
      }
    } catch (e) {
      debugPrint('TenantThemeBloc: tenant resolution failed -> $e');
      _emitPreservingColors(user?.id);
    } finally {
      _resolving = false;
    }
  }

  /// Marca el tema como resuelto conservando los colores del tenant ya
  /// resuelto (si lo había). Solo cae a titanio si nunca hubo tenant real.
  void _emitPreservingColors(String? userId) {
    if (state.tenantId != kDefaultTenantId) {
      emit(state.copyWith(
        isResolving: false,
        isResolved: true,
        resolvedForUserId: userId,
      ));
    } else {
      emit(TenantThemeState.initial().copyWith(
        isResolved: true,
        resolvedForUserId: userId,
      ));
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

  /// Devuelve los colores del tenant. `null` señala un fallo de red tras
  /// reintentar (para que el caller conserve los colores ya resueltos).
  /// Si la consulta funciona pero no hay branding válido, devuelve el default.
  Future<AppColorsInterface?> _fetchTenantColors(
      SupabaseClient client, String tenantId) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final row = await client
            .from('tenants')
            .select('branding')
            .eq('id', tenantId)
            .maybeSingle();
        final raw = row?['branding'];
        if (raw is Map<String, dynamic>) {
          return TenantBrandingColors.tryParse(raw) ?? DefaultTenantColors();
        }
        return DefaultTenantColors();
      } catch (e) {
        debugPrint('TenantThemeBloc: branding fetch attempt ${attempt + 1} failed -> $e');
        if (attempt < 2) {
          await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      }
    }
    return null;
  }

  void _ensureAuthSubscription() {
    if (_authSub != null) return;
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          final newUserId = data.session?.user.id;
          // Skip si ya resolvimos para este mismo usuario (Supabase puede
          // re-emitir signedIn al arrancar con sesión restaurada).
          if (state.isResolved && state.resolvedForUserId == newUserId) {
            return;
          }
          // Marca el tema como "no resuelto" inmediatamente para que App muestre
          // el loader neutro mientras se resuelve el tenant del nuevo usuario.
          if (!isClosed && !_resolving) {
            emit(state.copyWith(isResolved: false, isResolving: true));
          }
          _resolveTenantFromAuth();
        } else if (event == AuthChangeEvent.signedOut) {
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

class _PremiumFadeTransitionsBuilder extends PageTransitionsBuilder {
  const _PremiumFadeTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
