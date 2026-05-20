import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';

class ModuleSelectionView extends StatefulWidget {
  const ModuleSelectionView({super.key});

  @override
  State<ModuleSelectionView> createState() => _ModuleSelectionViewState();
}

class _ModuleSelectionViewState extends State<ModuleSelectionView> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.content_cut_rounded, color: context.primaryGold, size: 40),
                  const SizedBox(height: 24),
                  const Text(
                    'BIENVENIDO A',
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4),
                  ),
                  const Text(
                    'TRIMFLOW',
                    style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2),
                  ),
                  const SizedBox(height: 12),
                  Container(width: 60, height: 2, color: context.primaryGold),
                  const SizedBox(height: 60),
                  const Text(
                    'SELECCIONA TU MÓDULO',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  const SizedBox(height: 24),
                  _ModuleCard(
                    title: 'MODO CLIENTE',
                    subtitle: 'Reserva tu cita y explora servicios',
                    leading: Image.asset(
                      'images/beard.png',
                      color: context.primaryGold,
                      fit: BoxFit.contain,
                    ),
                    onTap: () {
                      context.read<AppModeBloc>().add(const AppModeEvent.changeMode(AppMode.client));
                    },
                  ),
                  const SizedBox(height: 16),
                  _ModuleCard(
                    title: 'MODO BARBERO',
                    subtitle: 'Gestiona tu agenda y herramientas',
                    leading: Image.asset(
                      'images/barbershop.png',
                      color: context.primaryGold,
                      fit: BoxFit.contain,
                    ),
                    onTap: () {
                      context.read<AppModeBloc>().add(const AppModeEvent.changeMode(AppMode.barber));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 28,
                height: 28,
                child: leading,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
