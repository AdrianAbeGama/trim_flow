import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';

/// Info card del visor a pantalla completa — diseño magazine.
/// Tag categoría grande en top, nombre BIG con animación de entrada,
/// chips inline de stats (barbero · destacado), descripción y CTAs flotantes.
class GalleryFullscreenBottomInfo extends StatelessWidget {
  const GalleryFullscreenBottomInfo({
    super.key,
    required this.item,
    required this.isBarberMode,
    required this.onToggleFav,
    required this.onReserve,
  });

  final GalleryItem item;
  final bool isBarberMode;
  final VoidCallback onToggleFav;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return BlocBuilder<GalleryBloc, GalleryState>(
      buildWhen: (a, b) => a.allItems != b.allItems,
      builder: (context, state) {
        final fresh = state.allItems.firstWhere(
          (it) => it.id == item.id,
          orElse: () => item,
        );
        return _MagazineLayout(
          item: fresh,
          gold: gold,
          isBarberMode: isBarberMode,
          starYellow: gold,
          onToggleFav: onToggleFav,
          onReserve: onReserve,
        );
      },
    );
  }
}

class _MagazineLayout extends StatelessWidget {
  const _MagazineLayout({
    required this.item,
    required this.gold,
    required this.isBarberMode,
    required this.starYellow,
    required this.onToggleFav,
    required this.onReserve,
  });

  final GalleryItem item;
  final Color gold;
  final bool isBarberMode;
  final Color starYellow;
  final VoidCallback onToggleFav;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final specialty = (item.barberSpecialty ?? 'Estilista profesional').toUpperCase();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow (especialidad) + estrella fav.
        Row(
          children: [
            Expanded(
              child: Text(
                specialty,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: gold,
                  letterSpacing: 2.4,
                  shadows: const [Shadow(blurRadius: 4, color: Color(0xAA000000))],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _CircleAction(
              icon: item.isFeatured ? Icons.star_rounded : Icons.star_outline_rounded,
              color: item.isFeatured ? Colors.black : starYellow,
              bg: item.isFeatured ? starYellow : starYellow.withValues(alpha: 0.10),
              border: starYellow,
              onTap: onToggleFav,
            ),
          ],
        ).animate().fadeIn(delay: 60.ms, duration: 350.ms),
        const SizedBox(height: 10),

        // Nombre del estilista BIG.
        _BigName(name: item.barberFullName ?? 'Estilista'),
        const SizedBox(height: 12),

        // Línea de acento + destacado discreto.
        Row(
          children: [
            Container(width: 28, height: 2, color: gold),
            if (item.isFeatured) ...[
              const SizedBox(width: 10),
              Icon(Icons.star_rounded, color: gold, size: 13),
              const SizedBox(width: 5),
              Text(
                'DESTACADO',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: gold,
                  letterSpacing: 1.8,
                  shadows: const [Shadow(blurRadius: 4, color: Color(0xAA000000))],
                ),
              ),
            ],
          ],
        ).animate().fadeIn(delay: 220.ms, duration: 400.ms),
        const SizedBox(height: 20),

        // Reservar minimalista (color del tenant).
        _ReserveMinimal(onTap: onReserve, accent: gold),
      ],
    );
  }
}

/// Nombre BIG con animación letra por letra estilo magazine cover.
class _BigName extends StatelessWidget {
  const _BigName({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -1.0,
        height: 1.0,
        shadows: const [
          Shadow(blurRadius: 8, color: Color(0xDD000000)),
        ],
      ),
    )
        .animate(key: ValueKey(name))
        .fadeIn(delay: 140.ms, duration: 450.ms)
        .slideY(
          begin: 0.4,
          end: 0,
          delay: 140.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Botón circular pequeño (fav, share).
class _CircleAction extends StatefulWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  @override
  State<_CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<_CircleAction> {
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
        scale: _pressed ? 0.85 : 1,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: widget.bg,
            shape: BoxShape.circle,
            border: Border.all(color: widget.border, width: 1.2),
          ),
          child: Icon(widget.icon, color: widget.color, size: 18),
        ),
      ),
    );
  }
}

/// Reservar minimalista — pill con el color del tenant (sin glow ni ruido).
class _ReserveMinimal extends StatefulWidget {
  const _ReserveMinimal({required this.onTap, required this.accent});
  final VoidCallback onTap;
  final Color accent;

  @override
  State<_ReserveMinimal> createState() => _ReserveMinimalState();
}

class _ReserveMinimalState extends State<_ReserveMinimal> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final fg = premiumOnAccent(widget.accent);
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
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: widget.accent.withValues(alpha: 0.3), blurRadius: 14, spreadRadius: 0.5),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available_rounded, size: 17, color: fg),
              const SizedBox(width: 8),
              Text(
                'RESERVAR CITA',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: fg,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
