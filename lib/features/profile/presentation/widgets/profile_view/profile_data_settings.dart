import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfilePersonalDataGrid extends StatelessWidget {
  const ProfilePersonalDataGrid({
    super.key, required this.user, required this.onTap, this.lastVisit});

  final UserProfile user;
  final VoidCallback onTap;
  final String? lastVisit;

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
            ProfileSectionTitle(text: 'Datos personales'),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _DataCard(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WHATSAPP',
                      value: phoneVal,
                      isPending: user.phone.isEmpty,
                      onTap: onTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DataCard(
                      icon: FontAwesomeIcons.cakeCandles,
                      label: 'CUMPLEAÑOS',
                      value: birthVal,
                      isPending: user.birthDate.isEmpty,
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
            if (lastVisit != null && lastVisit!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DataCardWide(
                icon: FontAwesomeIcons.clockRotateLeft,
                label: 'ÚLTIMA VISITA',
                value: lastVisit!,
              ),
            ],
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

/// Tarjeta premium de dato personal (estilo Wallet). Editable al tocar.
class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPending,
    required this.onTap,
  });

  final dynamic icon;
  final String label;
  final String value;
  final bool isPending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    const red = Color(0xFFFF8A95);
    return ProfilePressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPending
                ? red.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, size: 19, color: isPending ? red : gold),
            const SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: isPending ? red : Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta premium de solo lectura (ancho completo). Ej: ultima visita.
class _DataCardWide extends StatelessWidget {
  const _DataCardWide({
    required this.icon,
    required this.label,
    required this.value,
  });

  final dynamic icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          FaIcon(icon, size: 18, color: gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1.4,
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
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.22),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 17,
                color: Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 9),
              Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B6B),
                  letterSpacing: -0.2,
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

