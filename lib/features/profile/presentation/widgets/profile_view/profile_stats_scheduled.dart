import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfileQuickStatsRow extends StatelessWidget {
  const ProfileQuickStatsRow({
    super.key,
    required this.totalCuts,
    required this.scheduled,
    required this.couponsCount,
  });

  final int totalCuts;
  final int scheduled;
  final int couponsCount;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(child: _StatSegment(icon: Icons.content_cut_rounded, value: '$totalCuts', label: 'Cortes', accent: gold)),
              _StatDivider(),
              Expanded(child: _StatSegment(icon: Icons.event_available_rounded, value: '$scheduled', label: 'Próximas', accent: gold)),
              _StatDivider(),
              Expanded(child: _StatSegment(icon: Icons.confirmation_number_rounded, value: '$couponsCount', label: 'Cupones', accent: gold)),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 460.ms, duration: 600.ms)
            .slideY(begin: 0.08, end: 0, delay: 460.ms, duration: 600.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}

class _StatSegment extends StatelessWidget {
  const _StatSegment({required this.icon, required this.value, required this.label, required this.accent});

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: accent, size: 17),
        const SizedBox(height: 9),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 21, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.8, height: 1),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.2),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.06));
  }
}

// ============================================================================
// 5. CITAS PROGRAMADAS — Lista vertical minimalista
// ============================================================================

class ProfileScheduledCarousel extends StatelessWidget {
  const ProfileScheduledCarousel({
    super.key, required this.appointments, required this.onTap});

  final List<Reservation> appointments;
  final void Function(Reservation) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: ProfileSectionTitle(
                text: 'También agendadas',
                trailing: '${appointments.length}',
              ),
            ),
            ...appointments.asMap().entries.map((e) {
              final isLast = e.key == appointments.length - 1;
              return _ScheduledRow(
                reservation: e.value,
                showDivider: !isLast,
                onTap: () => onTap(e.value),
              );
            }),
          ],
        )
            .animate()
            .fadeIn(delay: 560.ms, duration: 600.ms),
      ),
    );
  }
}

class _ScheduledRow extends StatelessWidget {
  const _ScheduledRow({required this.reservation, required this.onTap, required this.showDivider});

  final Reservation reservation;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hasDate = reservation.date != null;
    final day = hasDate ? reservation.date!.day.toString() : '--';
    final month = hasDate ? DateFormat('MMM', 'es').format(reservation.date!).toUpperCase() : '';
    final timeStr = reservation.time ?? '—';
    final serviceName = reservation.services.isNotEmpty ? reservation.services.first.name : 'Servicio';

    return ProfilePressableScale(
      onTap: onTap,
      pressedScale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: gold, height: 1)),
                        Text(month, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: gold.withValues(alpha: 0.6), letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          serviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeStr,
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white.withValues(alpha: 0.25)),
                ],
              ),
            ),
            if (showDivider) Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. HISTORIAL TIMELINE
// ============================================================================

