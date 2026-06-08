import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/ripple_border_card.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfileFidelityHero extends StatefulWidget {
  const ProfileFidelityHero({
    super.key,
    required this.completed,
    required this.isRewardAvailable,
    required this.onClaim,
  });

  final int completed;
  final bool isRewardAvailable;
  final VoidCallback onClaim;

  static const int _goal = 8;

  @override
  State<ProfileFidelityHero> createState() => _FidelityHeroState();
}

class _FidelityHeroState extends State<ProfileFidelityHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveCtrl;
  bool _promoShown = false;

  @override
  void initState() {
    super.initState();
    // Loop continuo (3s) — ola de agua dentro de los círculos llenos.
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  /// Cuando falta exactamente 1 corte, muestra un aviso flotante ~5s con un
  /// detalle promocional. Se muestra una sola vez por montaje.
  void _maybeShowPromo(Color accent) {
    if (_promoShown) return;
    final remaining = ProfileFidelityHero._goal - widget.completed;
    if (widget.isRewardAvailable || remaining != 1) return;
    _promoShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => _PromoOverlay(accent: accent, onDismiss: () => entry.remove()),
      );
      overlay.insert(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final remaining =
        (ProfileFidelityHero._goal - widget.completed).clamp(0, ProfileFidelityHero._goal);
    _maybeShowPromo(gold);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: RippleBorderCard(
          accent: gold,
          radius: 22,
          child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              // Section header
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'CARTILLA DE FIDELIDAD',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: gold,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${widget.completed}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: gold,
                              letterSpacing: -0.4,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${ProfileFidelityHero._goal}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.45),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 8 círculos con wave
              AnimatedBuilder(
                animation: _waveCtrl,
                builder: (_, _) {
                  return _CirclesRow(
                    completed: widget.completed,
                    goal: ProfileFidelityHero._goal,
                    gold: gold,
                    waveProgress: _waveCtrl.value,
                  );
                },
              ),
              const SizedBox(height: 22),

              // Status + CTA
              if (widget.isRewardAvailable) ...[
                Text(
                  '¡Tu próximo corte tiene 50% OFF!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: gold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 14),
                ProfilePrimaryPill(
                  label: 'RECLAMAR DESCUENTO',
                  onTap: widget.onClaim,
                ),
              ] else
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Faltan '),
                      TextSpan(
                        text: '$remaining',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: gold,
                        ),
                      ),
                      TextSpan(
                        text: remaining == 1
                            ? ' corte para tu 50% OFF'
                            : ' cortes para tu 50% OFF',
                      ),
                    ],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: -0.1,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(
              begin: 0.05,
              end: 0,
              delay: 200.ms,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}

/// Fila de 8 círculos con water effect — cada círculo lleno tiene una
/// onda animada continua dentro (simulando agua moviéndose).
class _CirclesRow extends StatelessWidget {
  const _CirclesRow({
    required this.completed,
    required this.goal,
    required this.gold,
    required this.waveProgress,
  });

  final int completed;
  final int goal;
  final Color gold;
  final double waveProgress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(goal, (i) {
        final filled = i < completed;
        return _LoyaltyCircle(
          index: i,
          filled: filled,
          gold: gold,
          waveProgress: waveProgress,
        );
      }),
    );
  }
}

class _LoyaltyCircle extends StatelessWidget {
  const _LoyaltyCircle({
    required this.index,
    required this.filled,
    required this.gold,
    required this.waveProgress,
  });

  final int index;
  final bool filled;
  final Color gold;
  final double waveProgress;

  @override
  Widget build(BuildContext context) {
    final staggerDelay = 300 + index * 70;

    Widget circle;
    if (filled) {
      circle = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: gold.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: 0.18),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Water painter: gold solid + wave en la superficie
              CustomPaint(
                size: const Size(36, 36),
                painter: _WaterPainter(
                  color: gold,
                  // Cada círculo desfasado para que se vea como
                  // ondas independientes pero sincronizadas
                  phase: waveProgress * 2 * math.pi + index * 0.4,
                ),
              ),
              // Check icon encima de la "agua"
              const Icon(
                Icons.check_rounded,
                color: Colors.black,
                size: 17,
                weight: 900,
              ),
            ],
          ),
        ),
      );
    } else {
      circle = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    final animated = circle.animate().fadeIn(
          delay: staggerDelay.ms,
          duration: 360.ms,
          curve: Curves.easeOutCubic,
        );

    if (filled) {
      return animated.scale(
        begin: const Offset(0.55, 0.55),
        end: const Offset(1, 1),
        delay: staggerDelay.ms,
        duration: 460.ms,
        curve: Curves.easeOutBack,
      );
    }
    return animated.slideY(
      begin: 0.25,
      end: 0,
      delay: staggerDelay.ms,
      duration: 360.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

/// Pinta el interior del círculo como agua dorada con onda en la superficie.
///
/// - Fondo: dorado oscurecido en la parte inferior, dorado base en la mitad
/// - Wave: sine wave animada en el "nivel del agua" (~25% desde arriba)
class _WaterPainter extends CustomPainter {
  _WaterPainter({required this.color, required this.phase});

  final Color color;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Nivel del agua (desde arriba): 22% del alto
    final waterLevel = h * 0.22;
    // Amplitud de la onda
    const amplitude = 1.6;
    // Wavelength: 2 ondas por círculo
    final wavelength = w / 2;

    // Construir path del agua: empieza desde izq abajo, sube por la onda,
    // baja por der, vuelve por abajo
    final path = Path();
    path.moveTo(0, h);
    path.lineTo(0, waterLevel);
    for (double x = 0; x <= w; x += 1) {
      final y = waterLevel +
          math.sin((x / wavelength) * 2 * math.pi + phase) * amplitude;
      path.lineTo(x, y);
    }
    path.lineTo(w, h);
    path.close();

    // Gradient vertical: arriba más claro, abajo más oscuro = profundidad
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          Color.lerp(color, Colors.black, 0.18) ?? color,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);

    // Highlight muy sutil en la cresta de la onda
    final highlightPath = Path();
    highlightPath.moveTo(0, waterLevel + 1);
    for (double x = 0; x <= w; x += 1) {
      final y = waterLevel +
          math.sin((x / wavelength) * 2 * math.pi + phase) * amplitude;
      highlightPath.lineTo(x, y);
    }
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterPainter old) =>
      old.phase != phase || old.color != color;
}

/// Aviso flotante (~5s) cuando al cliente le falta 1 corte para su recompensa.
class _PromoOverlay extends StatefulWidget {
  const _PromoOverlay({required this.accent, required this.onDismiss});

  final Color accent;
  final VoidCallback onDismiss;

  @override
  State<_PromoOverlay> createState() => _PromoOverlayState();
}

class _PromoOverlayState extends State<_PromoOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();
    _timer = Timer(const Duration(milliseconds: 5000), _close);
  }

  Future<void> _close() async {
    _timer?.cancel();
    if (!mounted) return;
    await _c.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _close,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.45)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 10)),
                    BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 18, spreadRadius: -2),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(Icons.celebration_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡Te falta solo 1 corte!',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hazlo y tu próximo corte tiene 50% OFF + 15% en productos hoy.',
                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.5, fontWeight: FontWeight.w500, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 3. PRÓXIMA CITA — Hero card con gradiente
// ============================================================================

