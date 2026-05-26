import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trim_flow/core/config/app_config.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/notifications/notifications.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';

const Color _kBackground = Color(0xFF070707);
const Color _kPremiumGold = Color(0xFFD4AF37);
const int _kMinimumSplashMs = 1800;

class LoadingApp extends StatefulWidget {
  const LoadingApp({super.key, required this.onInitializationComplete});

  final VoidCallback onInitializationComplete;

  @override
  State<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

      tz.initializeTimeZones();

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
                  )
                : const _SplashLoadingView(),
          ),
        ),
      ),
    );
  }
}

class _SplashLoadingView extends StatelessWidget {
  const _SplashLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _BrandHeader(),
        SizedBox(height: 48),
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: _kPremiumGold,
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }
}

class _SplashErrorView extends StatelessWidget {
  const _SplashErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BrandHeader(),
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
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPremiumGold,
              side: const BorderSide(color: _kPremiumGold, width: 1),
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
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.content_cut_rounded,
          color: _kPremiumGold,
          size: 48,
        ),
        SizedBox(height: 24),
        Text(
          'TRIMFLOW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 6),
        Text(
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
