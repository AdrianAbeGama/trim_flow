import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_ticket_modal.dart';

const List<String> _kClientCancelReasons = [
  'Me surgió un imprevisto',
  'Cambié de fecha',
  'Ya no necesito el servicio',
  'Me equivoqué al reservar',
  'Otro motivo',
];

/// Landing de Reservar cuando el cliente YA tiene cita(s): muestra sus próximas
/// citas + un CTA "Hacer otra reserva" que abre el wizard.
class ReservationLanding extends StatelessWidget {
  const ReservationLanding({super.key, required this.appointments, required this.onNew});

  final List<Reservation> appointments;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final now = DateTime.now();
    bool isToday(Reservation r) =>
        r.date != null && r.date!.year == now.year && r.date!.month == now.month && r.date!.day == now.day;
    final hoy = appointments.where(isToday).toList();
    final otros = appointments.where((r) => !isToday(r)).toList();

    final sectionChildren = <Widget>[
      if (hoy.isNotEmpty) ...[
        _sectionLabel('HOY'),
        ...hoy.map((r) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _AppointmentCard(reservation: r))),
      ],
      if (otros.isNotEmpty) ...[
        if (hoy.isNotEmpty) const SizedBox(height: 10),
        _sectionLabel('PRÓXIMOS DÍAS'),
        ...otros.map((r) => Padding(padding: const EdgeInsets.only(bottom: 14), child: _AppointmentCard(reservation: r))),
      ],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const PremiumPill(icon: Icons.event_available_rounded, label: 'TUS RESERVAS'),
                              const Spacer(),
                              _NewReservationButton(onTap: onNew),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Tus',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Citas',
                            style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(width: 16, height: 1.5, color: gold),
                              const SizedBox(width: 8),
                              Text(
                                appointments.length == 1 ? '1 cita agendada' : '${appointments.length} citas agendadas',
                                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: -0.1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(sectionChildren),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.6),
      ),
    );

class _NewReservationButton extends StatelessWidget {
  const _NewReservationButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.94,
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: premiumOnAccent(gold), size: 18),
            const SizedBox(width: 5),
            Text(
              'NUEVA',
              style: GoogleFonts.inter(color: premiumOnAccent(gold), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.8),
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

  Future<void> _cancel(BuildContext context) async {
    final gold = context.primaryGold;
    final profileBloc = context.read<ProfileBloc>();
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.event_busy_rounded, color: Color(0xFFCF6679), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    '¿Cancelar tu cita?',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.4),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Cuéntanos el motivo (opcional para nosotros, útil para ti).',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ..._kClientCancelReasons.map(
                (r) => PremiumPressable(
                  pressedScale: 0.98,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(ctx, r);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 16, color: gold.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;
    profileBloc.add(ProfileEvent.cancelAppointment(reservationId: reservation.id ?? '', reason: reason));
  }

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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bloque de fecha + hora (lateral)
            Container(
              width: 76,
              color: gold.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayNum, style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w900, color: gold, height: 1, letterSpacing: -1)),
                  Text(monthAbbr, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: gold.withValues(alpha: 0.7), letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Container(width: 26, height: 1, color: gold.withValues(alpha: 0.25)),
                  const SizedBox(height: 10),
                  Text(timeStr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                    const SizedBox(height: 10),
                    Text(service,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text('con $barber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _CardAction(
                          icon: Icons.close_rounded,
                          label: 'Cancelar',
                          color: const Color(0xFFCF6679),
                          onTap: () => _cancel(context),
                        ),
                        const Spacer(),
                        _CardAction(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Ver ticket',
                          color: gold,
                          onTap: () => ProfileTicketModal.show(context, reservation),
                        ),
                      ],
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

class _CardAction extends StatelessWidget {
  const _CardAction({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.95,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
