import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Primitivos compartidos por las secciones del perfil del cliente.

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.text, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfilePressableScale extends StatefulWidget {
  const ProfilePressableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<ProfilePressableScale> createState() => _ProfilePressableScaleState();
}

class _ProfilePressableScaleState extends State<ProfilePressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class ProfilePrimaryPill extends StatefulWidget {
  const ProfilePrimaryPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<ProfilePrimaryPill> createState() => _ProfilePrimaryPillState();
}

class _ProfilePrimaryPillState extends State<ProfilePrimaryPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

/// Punto pulsante con halo (usado en historial de citas).
class ProfilePulseDot extends StatefulWidget {
  const ProfilePulseDot({super.key, required this.color});
  final Color color;
  static const double dotSize = 28;
  static const double innerSize = 7;

  @override
  State<ProfilePulseDot> createState() => _ProfilePulseDotState();
}

class _ProfilePulseDotState extends State<ProfilePulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ProfilePulseDot.dotSize,
      height: ProfilePulseDot.dotSize,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = _ctrl.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ProfilePulseDot.dotSize * (0.55 + 0.45 * t),
                height: ProfilePulseDot.dotSize * (0.55 + 0.45 * t),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.22 * (1 - t)),
                ),
              ),
              Container(
                width: ProfilePulseDot.dotSize * 0.55,
                height: ProfilePulseDot.dotSize * 0.55,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: ProfilePulseDot.innerSize,
                height: ProfilePulseDot.innerSize,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Pantalla de carga (CupertinoActivityIndicator dorado).
class ProfileLoadingState extends StatelessWidget {
  const ProfileLoadingState({super.key, required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(color: gold, radius: 14),
    );
  }
}

/// Pantalla de error con retry.
class ProfileErrorState extends StatelessWidget {
  const ProfileErrorState({super.key, required this.onRetry, required this.gold});

  final VoidCallback onRetry;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 48,
            ),
            const SizedBox(height: 18),
            Text(
              'No pudimos cargar tu perfil',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onRetry();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'REINTENTAR',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
