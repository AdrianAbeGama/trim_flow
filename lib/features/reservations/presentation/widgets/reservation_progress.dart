import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Indicador de progreso del wizard de reserva (segmentos tipo iOS).
class ReservationProgress extends StatelessWidget {
  const ReservationProgress({super.key, required this.currentPhase, this.total = 5});

  final int currentPhase;
  final int total;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PASO $currentPhase DE $total',
          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.6),
        ),
        const SizedBox(height: 9),
        Row(
          children: List.generate(total, (i) {
            final done = i < currentPhase;
            final isCurrent = i == currentPhase - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  height: 4,
                  decoration: BoxDecoration(
                    color: done ? gold : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isCurrent ? [BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: -1)] : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
