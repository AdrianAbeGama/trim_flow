import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/appointment_card.dart';

class HistorySheet extends StatefulWidget {
  const HistorySheet({super.key, required this.state});

  final AgendaUiState state;

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet> {
  bool _isMaximized = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final historyItems = widget.state.appointments.where((a) {
      return a.status == AgendaStatus.completed || 
             a.status == AgendaStatus.cancelled || 
             a.status == AgendaStatus.noShow;
    }).toList();

    final totalEarned = historyItems
        .where((a) => a.status == AgendaStatus.completed)
        .fold(0.0, (sum, a) => sum + (a.priceAtBooking ?? 0.0));

    // Calcular altura base según reglas
    final screenHeight = MediaQuery.of(context).size.height;
    double targetHeight;
    if (_isMaximized) {
      targetHeight = screenHeight * 0.9;
    } else if (historyItems.length <= 1) {
      targetHeight = screenHeight * 0.35; // Un poco mas de 1/4 para evitar overflow del contenido
    } else {
      targetHeight = screenHeight * 0.5;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: targetHeight,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.clockRotateLeft, color: gold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HISTORIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${widget.state.selectedDay.day}/${widget.state.selectedDay.month}/${widget.state.selectedDay.year}',
                      style: TextStyle(
                        color: gold.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (historyItems.length > 3)
                IconButton(
                  icon: Icon(
                    _isMaximized ? Icons.close_fullscreen_rounded : Icons.open_in_full_rounded,
                    color: gold,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMaximized = !_isMaximized;
                    });
                  },
                ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Total Turno: S/ ${totalEarned.toStringAsFixed(2)}',
              style: TextStyle(
                color: gold,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: historyItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.boxOpen, color: gold.withValues(alpha: 0.2), size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Historial vacío',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: historyItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return AppointmentCard(appointment: historyItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
