import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/notifications/notifications.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';

class LoadingApp extends StatefulWidget {
  const LoadingApp({super.key, required this.onInitializationComplete});

  final VoidCallback onInitializationComplete;

  @override
  State<LoadingApp> createState() => _LoadingAppState();
}

class _LoadingAppState extends State<LoadingApp> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Quick micro-animation for the brand intro
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
      // 1. Initialize Supabase
      await Supabase.initialize(
        url: 'https://uqhszqujcsmlmubeynfp.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxaHN6cXVqY3NtbG11YmV5bmZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcwNTA4MzAsImV4cCI6MjA5MjYyNjgzMH0.N_bpGFk3U2f6ilP-1Bcr7HlVOHOL-xHdwzF64Bx_86w',
      );

      // 2. Initialize Dependency Injection (GetIt)
      configureDependencies();

      // 3. Initialize and await session verification in background (resolves the first-frame flash!)
      final appModeBloc = getIt<AppModeBloc>();
      appModeBloc.add(const AppModeEvent.initialize());
      await appModeBloc.stream.firstWhere((state) => state.isInitialized);

      // 4. Initialize Local Notifications
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

      // 5. Initialize Timezones
      tz.initializeTimeZones();

      // Enforce minimum premium display duration of 1800ms
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = 1800 - elapsed;
      if (remaining > 0) {
        await Future.delayed(Duration(milliseconds: remaining));
      }

      if (mounted) {
        widget.onInitializationComplete();
      }
    } catch (e, stack) {
      debugPrint('Initialization error: $e\n$stack');
      // Even if there's a startup error, proceed so the app doesn't crash on boot
      if (mounted) {
        widget.onInitializationComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF070707),
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist and premium icon
                const Icon(
                  Icons.content_cut_rounded,
                  color: Color(0xFFD4AF37), // Premium Gold
                  size: 48,
                ),
                const SizedBox(height: 24),
                // Brand Name
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
                const SizedBox(height: 48),
                // Elegant circular spinner in premium gold
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
