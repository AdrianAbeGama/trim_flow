import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/theme/default_tenant_colors.dart';
import 'package:trim_flow/core/theme/tenant_branding_colors.dart';
import 'package:trim_flow/core/theme/tenant_info.dart';

const String kDefaultTenantId = 'default';

class TenantThemeState {
  final String tenantId;
  final AppColorsInterface colors;
  final ThemeData themeData;
  final bool isResolving;
  final bool isResolved;
  final String? resolvedForUserId;
  final List<TenantInfo> availableTenants;

  // true cuando el usuario cambia de negocio desde el switcher (no en el login
  // inicial). Permite mostrar el nombre del negocio en el loader en vez de TRIMFLOW.
  final bool isSwitching;

  TenantThemeState({
    required this.tenantId,
    required this.colors,
    required this.themeData,
    this.isResolving = false,
    this.isResolved = false,
    this.resolvedForUserId,
    this.availableTenants = const [],
    this.isSwitching = false,
  });

  factory TenantThemeState.initial() {
    final colors = DefaultTenantColors();
    return TenantThemeState(
      tenantId: kDefaultTenantId,
      colors: colors,
      themeData: _buildTheme(colors),
      isResolving: false,
      isResolved: false,
      availableTenants: const [],
    );
  }

  bool get isMultiTenant => availableTenants.length > 1;

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
    List<TenantInfo>? availableTenants,
    bool? isSwitching,
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
      availableTenants: availableTenants ?? this.availableTenants,
      isSwitching: isSwitching ?? this.isSwitching,
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

  /// Cambia al tenant indicado usando los datos ya cargados en availableTenants.
  /// No hace llamadas de red adicionales — los colores están en memoria.
  Future<void> switchTenant(String tenantId) async {
    if (tenantId == state.tenantId) return;
    final tenant = state.availableTenants
        .where((t) => t.id == tenantId)
        .firstOrNull;
    if (tenant == null) return;
    emit(state.copyWith(
      tenantId: tenantId,
      colors: tenant.colors,
      isResolved: true,
      isSwitching: true,
    ));
  }

  Future<void> _resolveTenantFromAuth() async {
    if (_resolving) return;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final currentUserId = user?.id;

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

      final tenants = await _lookupAllTenants(client, user.id);

      if (tenants.isEmpty) {
        emit(TenantThemeState.initial().copyWith(
          isResolved: true,
          resolvedForUserId: user.id,
        ));
        return;
      }

      // Si ya había un tenant activo válido en la lista, conservarlo.
      final keepActive = tenants.any((t) => t.id == state.tenantId);
      final active = keepActive
          ? tenants.firstWhere((t) => t.id == state.tenantId)
          : tenants.first;

      emit(state.copyWith(
        tenantId: active.id,
        colors: active.colors,
        isResolving: false,
        isResolved: true,
        resolvedForUserId: user.id,
        availableTenants: tenants,
        isSwitching: false,
      ));
    } catch (e) {
      debugPrint('TenantThemeBloc: tenant resolution failed -> $e');
      _emitPreservingColors(user?.id);
    } finally {
      _resolving = false;
    }
  }

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

  /// Devuelve TODOS los tenants a los que pertenece el usuario.
  /// Staff → siempre uno solo (desde profiles).
  /// Cliente → uno o más (desde customers).
  Future<List<TenantInfo>> _lookupAllTenants(
      SupabaseClient client, String userId) async {
    // 1. Staff: tiene una sola fila en profiles con un tenant_id
    final profileRow = await client
        .from('profiles')
        .select('tenant_id')
        .eq('id', userId)
        .maybeSingle();

    final profileTenantId = profileRow?['tenant_id'] as String?;
    if (profileTenantId != null && profileTenantId.isNotEmpty) {
      final info = await _fetchTenantInfo(client, profileTenantId);
      return info != null ? [info] : [];
    }

    // 2. Cliente: Hub de barberias via RPC del backend (get_my_barbershops).
    //    Reemplaza la lectura directa de customers, que rompia con multi-tenant
    //    (varias fichas bajo el mismo auth_user_id).
    final hub = await client.rpc('get_my_barbershops');
    final rows = (hub as List?) ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(_tenantInfoFromHub)
        .toList();
  }

  TenantInfo _tenantInfoFromHub(Map<String, dynamic> row) {
    final branding = <String, dynamic>{
      'primary_color': row['primaryColor'],
      'secondary_color': row['secondaryColor'],
      'accent_color': row['accentColor'],
    };
    final colors =
        TenantBrandingColors.tryParse(branding) ?? DefaultTenantColors();
    return TenantInfo(
      id: row['tenantId'] as String,
      name: (row['name'] as String?) ?? 'Negocio',
      slug: (row['slug'] as String?) ?? '',
      colors: colors,
    );
  }

  Future<TenantInfo?> _fetchTenantInfo(
      SupabaseClient client, String tenantId) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final row = await client
            .from('tenants')
            .select('id, name, slug, branding')
            .eq('id', tenantId)
            .filter('deleted_at', 'is', null)
            .maybeSingle();

        if (row == null) return null;

        final branding = row['branding'] as Map<String, dynamic>?;
        final colors =
            TenantBrandingColors.tryParse(branding) ?? DefaultTenantColors();

        return TenantInfo(
          id: row['id'] as String,
          name: (row['name'] as String?) ?? 'Negocio',
          slug: (row['slug'] as String?) ?? '',
          colors: colors,
        );
      } catch (e) {
        debugPrint(
            'TenantThemeBloc: tenant fetch attempt ${attempt + 1} failed -> $e');
        if (attempt < 2) {
          await Future<void>.delayed(
              Duration(milliseconds: 300 * (attempt + 1)));
        }
      }
    }
    return null;
  }

  void _ensureAuthSubscription() {
    if (_authSub != null) return;
    try {
      _authSub =
          Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          final newUserId = data.session?.user.id;
          if (state.isResolved && state.resolvedForUserId == newUserId) {
            return;
          }
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
