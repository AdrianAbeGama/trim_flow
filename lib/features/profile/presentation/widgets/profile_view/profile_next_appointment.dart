import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfileNextAppointmentHero extends StatelessWidget {
  const ProfileNextAppointmentHero({
    super.key,required this.appointment, required this.onTap});

  final Reservation appointment;
  final VoidCallback onTap;

  static const List<String> _cancelReasons = [
    'Tuve un imprevisto',
    'Cambié de opinión',
    'Emergencia familiar',
    'Ya no puedo asistir',
    'Otro motivo',
  ];

  void _showCancelSheet(BuildContext context, Reservation r) {
    HapticFeedback.mediumImpact();
    final gold = context.primaryGold;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancelar cita',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Selecciona un motivo',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ..._cancelReasons.map(
                  (reason) => _CancelReasonTile(
                    label: reason,
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      HapticFeedback.heavyImpact();
                      context.read<ProfileBloc>().add(
                            ProfileEvent.cancelAppointment(
                              reservationId: r.id ?? '',
                              reason: reason,
                            ),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(sheetCtx),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Text(
                        'Mantener cita',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: gold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final dateStr = appointment.date != null
        ? DateFormat("EEE d 'de' MMM", 'es')
            .format(appointment.date!)
            .toUpperCase()
        : '—';
    final timeStr = appointment.time ?? '—';
    final serviceName = appointment.services.isNotEmpty
        ? appointment.services.first.name
        : 'Servicio';
    final barberName = appointment.professional?.name ?? 'Tu barbero';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSectionTitle(text: 'Próxima cita'),
            const SizedBox(height: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ProfilePressableScale(
              onTap: onTap,
              pressedScale: 0.985,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top accent line dorada muy sutil
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            gold.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status badge + fecha
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7BE38C)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF7BE38C),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'CONFIRMADA',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF7BE38C),
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                dateStr,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.45),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Hora gigante
                          Text(
                            timeStr,
                            style: GoogleFonts.inter(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2.5,
                              height: 0.95,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            serviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'con $barberName',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(height: 0.5, color: Colors.white.withValues(alpha: 0.06)),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              // Cancelar (texto rojo sutil, izquierda)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showCancelSheet(context, appointment);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Text(
                                  'Cancelar',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF6B6B)
                                        .withValues(alpha: 0.85),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Ver ticket (derecha)
                              Text(
                                'Ver ticket completo',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: gold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 16, color: gold),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: _RisingParticles(
                      colors: [
                        gold,
                        context.tenantColors.accentGold,
                        Color.lerp(gold, Colors.white, 0.45)!,
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 360.ms, duration: 700.ms)
                .slideY(
                  begin: 0.08,
                  end: 0,
                  delay: 360.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutCubic,
                ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. QUICK STATS ROW
// ============================================================================

class _CancelReasonTile extends StatefulWidget {
  const _CancelReasonTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_CancelReasonTile> createState() => _CancelReasonTileState();
}

class _CancelReasonTileState extends State<_CancelReasonTile> {
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bolitas luminosas de distintos tamaños y colores que estallan desde el
/// centro de la tarjeta en TODAS las direcciones (360°) y se desvanecen
/// (efecto 3D premium). Se reproduce una sola vez al llegar al perfil tras
/// confirmar una reserva (`HomePage.justBooked`). No bloquea taps ni hace loop.
class _RisingParticles extends StatefulWidget {
  const _RisingParticles({required this.colors});

  final List<Color> colors;

  @override
  State<_RisingParticles> createState() => _RisingParticlesState();
}

class _RisingParticlesState extends State<_RisingParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    _particles = _buildParticles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (HomePage.justBooked.value) {
        HomePage.justBooked.value = false;
        _controller.forward(from: 0);
      }
    });
  }

  List<_Particle> _buildParticles() {
    final rnd = math.Random(7);
    final palette = widget.colors;
    const count = 34;
    return List.generate(count, (i) {
      // Ángulo repartido en 360° (con jitter) → estalla por todos lados.
      final angle = (i / count) * math.pi * 2 + (rnd.nextDouble() - 0.5) * 0.5;
      return _Particle(
        angle: angle,
        size: 3 + rnd.nextDouble() * 8,
        color: palette[rnd.nextInt(palette.length)],
        distance: 0.45 + rnd.nextDouble() * 0.75,
        delay: rnd.nextDouble() * 0.28,
        depth: 0.5 + rnd.nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isDismissed) return const SizedBox.shrink();
        return CustomPaint(
          painter: _RisingParticlesPainter(progress: _controller.value, particles: _particles),
        );
      },
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.size,
    required this.color,
    required this.distance,
    required this.delay,
    required this.depth,
  });

  final double angle;
  final double size;
  final Color color;
  final double distance;
  final double delay;
  final double depth;
}

class _RisingParticlesPainter extends CustomPainter {
  _RisingParticlesPainter({required this.progress, required this.particles});

  final double progress;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.longestSide * 0.62;

    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final eased = Curves.easeOutCubic.transform(t);
      final radius = eased * p.distance * maxR;
      final x = center.dx + math.cos(p.angle) * radius;
      final y = center.dy + math.sin(p.angle) * radius;

      final fade = math.sin(t * math.pi); // aparece y se desvanece al alejarse
      final opacity = (fade * p.depth).clamp(0.0, 1.0);
      if (opacity <= 0.01) continue;

      final scale = 0.6 + 0.5 * fade;
      final r = p.size * scale * p.depth;

      // Halo (glow) difuminado
      final glow = Paint()
        ..color = p.color.withValues(alpha: opacity * 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.4);
      canvas.drawCircle(Offset(x, y), r * 1.9, glow);

      // Núcleo
      final core = Paint()..color = p.color.withValues(alpha: opacity * 0.92);
      canvas.drawCircle(Offset(x, y), r, core);

      // Reflejo (sensación 3D)
      final hi = Paint()..color = Colors.white.withValues(alpha: opacity * 0.5);
      canvas.drawCircle(Offset(x - r * 0.32, y - r * 0.32), r * 0.34, hi);
    }
  }

  @override
  bool shouldRepaint(covariant _RisingParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
