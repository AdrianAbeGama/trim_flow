import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_bloc.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_event.dart';

class AppointmentActionSheet extends StatelessWidget {
  const AppointmentActionSheet({super.key, required this.appointment});

  final AgendaAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final name = (appointment.customerName ?? 'Cliente sin registrar').toUpperCase();
    final service = appointment.serviceName ?? 'Servicio no especificado';
    
    final hh = appointment.startTime.hour.toString().padLeft(2, '0');
    final mm = appointment.startTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hh:$mm';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FaIcon(FontAwesomeIcons.clock, size: 14, color: gold),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              const FaIcon(FontAwesomeIcons.scissors, size: 14, color: Colors.white54),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCF6679).withValues(alpha: 0.1),
                    foregroundColor: const Color(0xFFCF6679),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFFCF6679).withValues(alpha: 0.2)),
                    ),
                  ),
                  onPressed: () => _handleCancel(context),
                  child: const Text(
                    'CANCELAR CITA',
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _handleComplete(context),
                  child: const Text(
                    'COMPLETAR CORTE',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _handleComplete(BuildContext context) {
    context.read<AgendaBloc>().add(AgendaEvent.statusChanged(appointment.id, AgendaStatus.completed));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita completada exitosamente.')),
    );
  }

  void _handleCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: const Text('Cancelar Cita', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de cancelar esta cita?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NO', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AgendaBloc>().add(AgendaEvent.statusChanged(appointment.id, AgendaStatus.cancelled));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cita cancelada.')),
              );
            },
            child: const Text('SÍ, CANCELAR', style: TextStyle(color: Color(0xFFCF6679))),
          ),
        ],
      ),
    );
  }
}
