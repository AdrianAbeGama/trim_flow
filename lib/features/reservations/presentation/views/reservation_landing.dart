import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_ticket_modal.dart';

/// Landing de Reservar cuando el cliente YA tiene su cita: una sola cita a la
/// vez, mostrada en grande. La cancelacion la gestiona la barberia.
class ReservationLanding extends StatelessWidget {
  const ReservationLanding({super.key, required this.appointments, required this.onNew});

  final List<Reservation> appointments;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final cita = appointments.first;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PremiumPill(icon: Icons.event_available_rounded, label: 'TU RESERVA'),
                    const SizedBox(height: 22),
                    Text(
                      'Tu',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cita',
                      style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(width: 16, height: 1.5, color: gold),
                        const SizedBox(width: 8),
                        Text(
                          'Tu próxima cita reservada',
                          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: -0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AppointmentCard(reservation: cita),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.025),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: gold.withValues(alpha: 0.8)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Solo puedes tener una cita a la vez. Si no podrás asistir, avísale a la barbería.',
                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hasDate = reservation.date != null;
    final dayNum = hasDate ? reservation.date!.day.toString() : '--';
    final monthAbbr = hasDate ? DateFormat('MMM', 'es').format(reservation.date!).toUpperCase() : '';
    final timeStr = reservation.time ?? '—';
    final service = reservation.services.isNotEmpty ? reservation.services.first.name : 'Servicio';
    final barber = reservation.professional?.name ?? 'Máxima disponibilidad';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 96,
              color: gold.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayNum, style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w900, color: gold, height: 1, letterSpacing: -1.5)),
                  Text(monthAbbr, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: gold.withValues(alpha: 0.7), letterSpacing: 1.5)),
                  const SizedBox(height: 14),
                  Container(width: 32, height: 1, color: gold.withValues(alpha: 0.25)),
                  const SizedBox(height: 14),
                  Text(timeStr, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6FAE8A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF6FAE8A), shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text('CONFIRMADA',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF6FAE8A), letterSpacing: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(service,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4)),
                    const SizedBox(height: 3),
                    Text('con $barber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 14),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                    const SizedBox(height: 10),
                    PremiumPressable(
                      pressedScale: 0.97,
                      onTap: () => ProfileTicketModal.show(context, reservation),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.confirmation_number_rounded, size: 15, color: gold),
                          const SizedBox(width: 6),
                          Text('Ver ticket', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: gold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
