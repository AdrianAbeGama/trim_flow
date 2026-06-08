import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';

class HomeNextAppointmentWidget extends StatelessWidget {
  const HomeNextAppointmentWidget({
    super.key,required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final next = state.scheduledAppointments.isNotEmpty
            ? state.scheduledAppointments.first
            : null;

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeSectionTitle(text: 'Tu próxima cita'),
                const SizedBox(height: 12),
                if (next != null)
                  _ScheduledCard(reservation: next, onTap: () {
                    HapticFeedback.lightImpact();
                    onTap?.call();
                  })
                else
                  _NoAppointmentCard(onReserve: () {
                    HapticFeedback.lightImpact();
                    onTap?.call();
                  }),
              ],
            )
                .animate()
                .fadeIn(delay: 260.ms, duration: 600.ms)
                .slideY(
                  begin: 0.06,
                  end: 0,
                  delay: 260.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        );
      },
    );
  }
}

class _ScheduledCard extends StatelessWidget {
  const _ScheduledCard({required this.reservation, required this.onTap});

  final Reservation reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final dateStr = reservation.date != null
        ? DateFormat("EEE d 'de' MMM", 'es').format(reservation.date!).toUpperCase()
        : '—';
    final time = reservation.time ?? '—';
    final service = reservation.services.isNotEmpty
        ? reservation.services.first.name
        : 'Servicio';

    return HomePressable(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Bloque hora
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: gold,
                      letterSpacing: -0.4,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr.split(' ').take(2).join(' '),
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: gold.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7BE38C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
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
                  const SizedBox(height: 6),
                  Text(
                    service,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reservation.professional?.name ?? 'Tu barbero',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
  const _NoAppointmentCard({required this.onReserve});
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: gold.withValues(alpha: 0.22)),
                ),
                child: Icon(Icons.event_available_rounded, color: gold, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No tienes citas',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Es un buen momento para reservar tu próximo corte',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: -0.1,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          HomePressable(
            onTap: onReserve,
            pressedScale: 0.97,
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'RESERVAR AHORA',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4-5-6. STYLE SECTION — unificado looks/servicios/productos con auto-rotate
// ============================================================================

