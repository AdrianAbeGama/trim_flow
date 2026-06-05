import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Primitivos premium compartidos por todas las features (galería, productos).
/// Centralizado para evitar copiar Pressable, SmartImage, Pill, etc.

/// Color de texto/icono legible sobre un fondo del acento del tenant:
/// negro en acentos claros (dorado), blanco en acentos oscuros (burdeos).
Color premiumOnAccent(Color accent) =>
    accent.computeLuminance() > 0.55 ? Colors.black : Colors.white;

/// Wrapper que aplica AnimatedScale al press con haptic.
class PremiumPressable extends StatefulWidget {
  const PremiumPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.97,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<PremiumPressable> createState() => _PremiumPressableState();
}

class _PremiumPressableState extends State<PremiumPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Imagen universal que detecta http vs file local vs asset.
class PremiumSmartImage extends StatelessWidget {
  const PremiumSmartImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.isLocalAsset = false,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool isLocalAsset;

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF181818),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _fallback();
    if (isLocalAsset && path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        width: width,
        height: height,
        errorWidget: (_, _, _) => _fallback(),
        placeholder: (_, _) => _fallback(),
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }
}

/// Botón redondo con back chevron iOS-style.
class PremiumBackButton extends StatefulWidget {
  const PremiumBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<PremiumBackButton> createState() => _PremiumBackButtonState();
}

class _PremiumBackButtonState extends State<PremiumBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Icon(
            Icons.chevron_left_rounded,
            color: Colors.white.withValues(alpha: 0.75),
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Confirmación de borrado consistente (sheet con icono warning).
class PremiumConfirmDelete {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    const danger = Color(0xFFFF8A95);
    final res = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: PremiumPressable(
                    onTap: () => Navigator.pop(ctx, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CANCELAR',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PremiumPressable(
                    onTap: () => Navigator.pop(ctx, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ELIMINAR',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return res == true;
  }
}

/// Badge pulsante "EDICIÓN ACTIVA · X". El acento es configurable.
class PremiumEditingBadge extends StatefulWidget {
  const PremiumEditingBadge({
    super.key,
    this.label = 'EDICIÓN ACTIVA',
    this.accent = const Color(0xFFFF8A95),
  });

  final String label;
  final Color accent;

  @override
  State<PremiumEditingBadge> createState() => _PremiumEditingBadgeState();
}

class _PremiumEditingBadgeState extends State<PremiumEditingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10 + 0.05 * _pulse.value),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent.withValues(alpha: 0.35 + 0.2 * _pulse.value),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18 * _pulse.value),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.6 + 0.4 * _pulse.value),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill estilo "PILL · LABEL" con icono dorado.
class PremiumPill extends StatelessWidget {
  const PremiumPill({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 11),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: gold,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón circular de editar — glass oscuro + borde dorado + micro-glow.
/// Usado en tarjetas de galería y productos en modo edición.
class PremiumEditCircleButton extends StatelessWidget {
  const PremiumEditCircleButton({super.key, required this.onTap, this.size = 32});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.82,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: gold.withValues(alpha: 0.7), width: 1.3),
          boxShadow: [
            BoxShadow(color: gold.withValues(alpha: 0.28), blurRadius: 10, spreadRadius: -2),
          ],
        ),
        child: Icon(Icons.edit_rounded, size: size * 0.5, color: gold),
      ),
    );
  }
}

/// Section label "— LABEL" con línea dorada accent.
class PremiumSectionLabel extends StatelessWidget {
  const PremiumSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Row(
      children: [
        Container(width: 12, height: 1.5, color: gold),
        const SizedBox(width: 7),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            color: gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}
