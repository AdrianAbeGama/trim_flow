import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';

/// Sección "Más" con accesos a Configuración + Probar alerta.
class BarberProfileMore extends StatelessWidget {
  const BarberProfileMore({
    super.key,
    required this.onOpenSettings,
    required this.onTestAlert,
  });

  final VoidCallback onOpenSettings;
  final VoidCallback onTestAlert;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BarberSectionTitle(text: 'Más'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  _MoreRow(
                    icon: Icons.tune_rounded,
                    label: 'Configuración',
                    subtitle: 'Notificaciones, modo barbero, soporte',
                    onTap: onOpenSettings,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 56),
                    height: 0.5,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                  _MoreRow(
                    icon: Icons.notifications_active_rounded,
                    label: 'Probar alerta',
                    subtitle: 'Envía una notificación de prueba',
                    onTap: onTestAlert,
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 740.ms, duration: 600.ms),
      ),
    );
  }
}

class _MoreRow extends StatefulWidget {
  const _MoreRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_MoreRow> createState() => _MoreRowState();
}

class _MoreRowState extends State<_MoreRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: _pressed ? Colors.white.withValues(alpha: 0.02) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón "CERRAR SESIÓN" destructive con borde rojo sutil.
class BarberProfileLogoutButton extends StatefulWidget {
  const BarberProfileLogoutButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<BarberProfileLogoutButton> createState() => _BarberProfileLogoutButtonState();
}

class _BarberProfileLogoutButtonState extends State<BarberProfileLogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFFF6B6B)),
              const SizedBox(width: 8),
              Text(
                'CERRAR SESIÓN',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B6B),
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
