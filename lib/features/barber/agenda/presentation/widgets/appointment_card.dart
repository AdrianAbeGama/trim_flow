import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/status_badge.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.onTap});

  final AgendaAppointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final statusColor = agendaStatusColor(appointment.status, gold);
    final opacity = appointment.status == AgendaStatus.completed ? 0.55 : 1.0;

    return Opacity(
      opacity: opacity,
      child: PremiumPressable(
        pressedScale: 0.98,
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 52,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _TimeFormat.format(appointment.startTime),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _TimeFormat.format(appointment.endTime),
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 4, color: statusColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (appointment.customerName ?? 'Cliente sin registrar').toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.scissors, color: gold.withValues(alpha: 0.8), size: 9),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      appointment.serviceName ?? 'Servicio',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  AgendaStatusBadge(status: appointment.status, compact: true),
                                  const Spacer(),
                                  if (appointment.priceAtBooking != null)
                                    Text(
                                      'S/ ${appointment.priceAtBooking!.toStringAsFixed(2)}',
                                      style: GoogleFonts.inter(color: gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.3),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeFormat {
  static String format(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
