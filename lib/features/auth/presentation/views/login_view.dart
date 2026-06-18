import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/trimflow_logo.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            TrimflowLogo(size: 104, color: context.primaryGold)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.95, end: 1.05, duration: 1600.ms, curve: Curves.easeInOut)
                .shimmer(delay: 400.ms, duration: 1900.ms, color: context.primaryGold.withValues(alpha: 0.6)),

            const SizedBox(height: 40),

            const Text(
              'BIENVENIDO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .slideY(begin: 0.25, end: 0, delay: 150.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            Text(
              'ELEVA TU ESTILO CON TRIMFLOW',
              style: TextStyle(
                color: context.primaryGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 280.ms, duration: 500.ms),

            const Spacer(flex: 2),

            // Botón Google Rediseñado
            GestureDetector(
              onTap: () => context.read<AppModeBloc>().add(const AppModeEvent.loginWithGoogle()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/google.png',
                      height: 24,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'CONTINUAR CON GOOGLE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 420.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, delay: 420.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 20),

            Text(
              'Acceso rápido y seguro',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 11,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(delay: 560.ms, duration: 500.ms),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
