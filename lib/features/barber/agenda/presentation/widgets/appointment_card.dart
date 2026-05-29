import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/status_badge.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.onTap});

  final AgendaAppointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final isConfirmed = appointment.status == AgendaStatus.confirmed;
    final opacity = appointment.status == AgendaStatus.pending ? 0.78 : 1.0;

    Color getStatusColor() {
      switch (appointment.status) {
        case AgendaStatus.confirmed: return const Color(0xFF3B82F6);
        case AgendaStatus.pending: return const Color(0xFFF59E0B);
        case AgendaStatus.completed: return const Color(0xFF4ADE80);
        case AgendaStatus.cancelled:
        case AgendaStatus.noShow: return const Color(0xFFCF6679);
        default: return Colors.white38;
      }
    }

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Time Column
              SizedBox(
                width: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Text(
                      _TimeFormat.format(appointment.startTime),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _TimeFormat.format(appointment.endTime),
                      style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 2. Timeline
              SizedBox(
                width: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(width: 2, color: Colors.white.withValues(alpha: 0.05)),
                    Positioned(
                      top: 18,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: getStatusColor(),
                          shape: BoxShape.circle,
                          border: Border.all(color: context.backgroundBlack, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 3. Card Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101010),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isConfirmed ? getStatusColor().withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (appointment.customerName ?? 'Cliente sin registrar').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.scissors, color: Colors.white54, size: 9),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              appointment.serviceName ?? 'Servicio',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
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
                              style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
