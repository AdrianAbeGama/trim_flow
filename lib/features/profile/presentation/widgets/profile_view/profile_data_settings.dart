import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfilePersonalDataGrid extends StatelessWidget {
  const ProfilePersonalDataGrid({
    super.key,required this.user, required this.onTap});

  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final phoneVal = user.phone.isEmpty ? 'Pendiente' : '+51 ${user.phone}';
    final birthVal =
        user.birthDate.isEmpty ? 'Pendiente' : _formatBirth(user.birthDate);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title + edit button pequeño
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ProfileSectionTitle(text: 'Datos personales'),
                ),
                _MiniEditButton(onTap: onTap),
              ],
            ),
            const SizedBox(height: 8),
            _DataRow(
              icon: Icons.chat_rounded,
              label: 'WHATSAPP',
              value: phoneVal,
              isPending: user.phone.isEmpty,
              onTap: onTap,
            ),
            _DataDivider(),
            _DataRow(
              icon: Icons.cake_rounded,
              label: 'CUMPLEAÑOS',
              value: birthVal,
              isPending: user.birthDate.isEmpty,
              onTap: onTap,
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 720.ms, duration: 600.ms),
      ),
    );
  }

  String _formatBirth(String raw) {
    try {
      final d = DateTime.parse(raw);
      const months = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
      ];
      return '${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return raw;
    }
  }
}

/// Botón mini "Editar" — pill outline pequeño con icono lápiz.
class _MiniEditButton extends StatefulWidget {
  const _MiniEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MiniEditButton> createState() => _MiniEditButtonState();
}

class _MiniEditButtonState extends State<_MiniEditButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 11,
                color: gold,
              ),
              const SizedBox(width: 5),
              Text(
                'EDITAR',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: gold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de dato personal — sin recuadro, ícono + label + valor + acción.
class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPending,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return ProfilePressableScale(
      onTap: onTap,
      pressedScale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: gold.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, size: 18, color: gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isPending ? const Color(0xFFFF8A95) : Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isPending ? Icons.add_circle_outline_rounded : Icons.chevron_right_rounded,
              size: isPending ? 18 : 20,
              color: isPending ? const Color(0xFFFF8A95) : Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

/// Separador fino entre filas de datos.
class _DataDivider extends StatelessWidget {
  const _DataDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

// ============================================================================
// 8. SETTINGS SHORTCUTS
// ============================================================================

class ProfileSettingsShortcuts extends StatelessWidget {
  const ProfileSettingsShortcuts({
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
            ProfileSectionTitle(text: 'Más'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.tune_rounded,
                    label: 'Configuración',
                    subtitle: 'Notificaciones, rendimiento, soporte',
                    onTap: onOpenSettings,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 56),
                    height: 0.5,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_active_rounded,
                    label: 'Probar alerta',
                    subtitle: 'Envía una notificación de prueba',
                    onTap: onTestAlert,
                  ),
                ],
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
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
  Widget build(BuildContext context) {
    return ProfilePressableScale(
      onTap: onTap,
      pressedScale: 0.995,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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

// ============================================================================
// 9. LOGOUT
// ============================================================================

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({
    super.key,required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ProfilePressableScale(
      onTap: onTap,
      pressedScale: 0.97,
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
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 16,
                color: Color(0xFFFF6B6B),
              ),
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

// ============================================================================
// SHARED PRIMITIVES
// ============================================================================

