import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trim_flow/core/config/app_config.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/notifications/notifications.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

const Color _kBackground = Color(0xFF070707);
// Marca TrimFlow universal: gris titanio premium (no dorado).
// Si el tenant tiene branding propio, animamos hacia su accent al resolverse.
const Color _kBrandAccent = Color(0xFFB8BCBF);
const int _kMinimumSplashMs = 800;
const Duration _kAccentTransitionDuration = Duration(milliseconds: 700);

class LoadingApp extends StatefulWidget {
  const LoadingApp({super.key, required this.onInitializationComplete});

  final VoidCallback onInitializationComplete;

  @override
  State<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final ValueNotifier<Color> _accentColor = ValueNotifier<Color>(_kBrandAccent);

  bool _hasError = false;
  String? _errorMessage;
  bool _diServicesConfigured = false;
  bool _supabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    _initializeServices();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _accentColor.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    final startTime = DateTime.now();
    try {
      AppConfig.validate();

      if (!_supabaseInitialized) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
        _supabaseInitialized = true;
      }

      if (!_diServicesConfigured) {
        configureDependencies();
        _diServicesConfigured = true;
      }

      final appModeBloc = getIt<AppModeBloc>();
      appModeBloc.add(const AppModeEvent.initialize());
      await appModeBloc.stream.firstWhere((state) => state.isInitialized);

      // Inicializa el listener de auth del TenantThemeBloc SIEMPRE
      // (incluso sin sesión activa) — así detecta cuando el usuario
      // se loguea más tarde via Google y resuelve el tenant.
      final themeBloc = getIt<TenantThemeBloc>();
      await themeBloc.loadTenantFromAuth();

      // Transición de marca: del gris titanio (TrimFlow universal) al accent del tenant.
      // Si el tenant resuelto tiene branding propio, animamos hacia su color.
      if (themeBloc.state.tenantId != kDefaultTenantId && mounted) {
        _accentColor.value = themeBloc.state.colors.primaryGold;
      }

      // Si ya hay sesión, espera a que el perfil cargue también.
      // Esto evita el flash de avatar viejo entre splash y home.
      if (appModeBloc.state.isLoggedIn) {
        final profileBloc = getIt<ProfileBloc>();
        profileBloc.add(const ProfileEvent.load());
        await profileBloc.stream.firstWhere(
          (state) =>
              state.status == ProfileStatus.loaded ||
              state.status == ProfileStatus.error,
        ).timeout(const Duration(seconds: 4), onTimeout: () => profileBloc.state);
      }

      // Notificaciones y timezones no se necesitan en el primer frame; se
      // inicializan en segundo plano para que el home aparezca antes.
      unawaited(_initNotificationsAndTz());

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = _kMinimumSplashMs - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }

      if (!mounted) return;
      widget.onInitializationComplete();
    } catch (e, stack) {
      debugPrint('Initialization error: $e\n$stack');
      if (!mounted) return;

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = _kMinimumSplashMs - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = _humanizeError(e);
      });
    }
  }

  /// Inicializa notificaciones y zonas horarias fuera del camino critico del
  /// primer frame. Opcional: si falla no debe afectar el arranque.
  Future<void> _initNotificationsAndTz() async {
    try {
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_stat_trimflow');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Notifications init skipped: $e');
    }
  }

  String _humanizeError(Object error) {
    if (error is MissingConfigException) {
      return 'Configuracion incompleta. Contacta a soporte.';
    }
    final raw = error.toString().toLowerCase();
    if (raw.contains('socket') || raw.contains('network') || raw.contains('failed host')) {
      return 'No pudimos conectarte. Revisa tu conexion a internet.';
    }
    return 'Algo salio mal al iniciar. Intentalo de nuevo.';
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
    });
    _initializeServices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _kBackground,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _hasError
                ? _SplashErrorView(
                    message: _errorMessage ?? 'Algo salio mal.',
                    onRetry: _retry,
                    accentColor: _accentColor,
                  )
                : _SplashLoadingView(accentColor: _accentColor),
          ),
        ),
      ),
    );
  }
}

class _SplashLoadingView extends StatelessWidget {
  const _SplashLoadingView({required this.accentColor});

  final ValueNotifier<Color> accentColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColor,
      builder: (context, color, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BrandHeader(accentColor: color),
            const SizedBox(height: 48),
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: _kAccentTransitionDuration,
              curve: Curves.easeInOutCubic,
              builder: (context, animatedColor, _) {
                return SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: animatedColor ?? _kBrandAccent,
                    strokeWidth: 2,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SplashErrorView extends StatelessWidget {
  const _SplashErrorView({
    required this.message,
    required this.onRetry,
    required this.accentColor,
  });

  final String message;
  final VoidCallback onRetry;
  final ValueNotifier<Color> accentColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColor,
      builder: (context, color, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BrandHeader(accentColor: color),
              const SizedBox(height: 48),
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white38,
                size: 36,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 32),
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: color),
                duration: _kAccentTransitionDuration,
                curve: Curves.easeInOutCubic,
                builder: (context, animatedColor, _) {
                  final c = animatedColor ?? _kBrandAccent;
                  return OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c,
                      side: BorderSide(color: c, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    child: const Text(
                      'REINTENTAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: accentColor),
          duration: _kAccentTransitionDuration,
          curve: Curves.easeInOutCubic,
          builder: (context, color, _) {
            return TrimflowLogo(
              size: 72,
              color: color ?? _kBrandAccent,
              shimmer: true,
            );
          },
        )
            .animate()
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 700.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        const Text(
          'TRIMFLOW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'PREMIUM STUDIO',
          style: TextStyle(
            color: Colors.white30,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
