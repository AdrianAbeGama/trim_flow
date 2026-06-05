import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:core/core.dart';

/// Paso 5 — resumen minimalista de la compra (sin caja de fondo). El botón
/// de confirmar vive en la barra inferior del wizard.
class Phase5ConfirmationReceipt extends StatelessWidget {
  const Phase5ConfirmationReceipt({super.key, required this.reservation, required this.isSuccess});

  final Reservation reservation;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    if (isSuccess) return const SizedBox.shrink();

    final gold = context.primaryGold;
    final service = reservation.services.isNotEmpty ? reservation.services.first.name : '—';
    final barber = reservation.professional?.name ?? 'Máxima disponibilidad';
    final center = reservation.center?.name ?? '—';
    final duration = reservation.totalDurationInMinutes;
    final serviceLine = duration > 0 ? '$service · $duration min' : service;
    final dateStr = reservation.date != null ? _cap(DateFormat("EEE d 'de' MMM", 'es').format(reservation.date!)) : '—';
    final timeStr = reservation.time ?? '—';
    final basePrice = reservation.services.fold(0.0, (s, e) => s + e.price);
    final isDiscount = reservation.totalPrice < basePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionLabel('5 · Confirma tu reserva'),
        const SizedBox(height: 22),
        _line('Lugar', center),
        _line('Servicio', serviceLine),
        _line('Barbero', barber),
        _line('Fecha', dateStr),
        _line('Hora', timeStr),
        const SizedBox(height: 18),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
        const SizedBox(height: 16),
        if (isDiscount) ...[
          _line('Subtotal', 'S/ ${basePrice.toStringAsFixed(2)}', muted: true),
          _line('Descuento fidelidad', '- S/ ${(basePrice * 0.5).toStringAsFixed(2)}', valueColor: const Color(0xFF6FAE8A)),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            Text(
              'Total a pagar',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              'S/ ${reservation.totalPrice.toStringAsFixed(2)}',
              style: GoogleFonts.inter(color: gold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.6),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _line(String label, String value, {bool muted = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: muted ? 0.35 : 0.45),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: valueColor ?? (muted ? Colors.white.withValues(alpha: 0.6) : Colors.white),
                fontSize: 14,
                fontWeight: muted ? FontWeight.w600 : FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
