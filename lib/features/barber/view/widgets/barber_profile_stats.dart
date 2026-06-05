import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

/// Resumen de HOY del barbero en su perfil (datos reales): cortes, ingresos
/// y proxima cita. Devuelve una caja (se envuelve en un sliver afuera).
class BarberProfileStatsRow extends StatelessWidget {
  const BarberProfileStatsRow({
    super.key,
    required this.cutsToday,
    required this.revenueToday,
    required this.nextLabel,
  });

  final int cutsToday;
  final double revenueToday;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(child: _StatSegment(icon: Icons.content_cut_rounded, value: '$cutsToday', label: 'Cortes hoy', accent: gold)),
            _StatDivider(),
            Expanded(child: _StatSegment(icon: Icons.payments_rounded, value: 'S/${revenueToday.toStringAsFixed(0)}', label: 'Ingresos', accent: gold)),
            _StatDivider(),
            Expanded(child: _StatSegment(icon: Icons.schedule_rounded, value: nextLabel, label: 'Próxima', accent: gold)),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 120.ms, duration: 500.ms)
          .slideY(begin: 0.06, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
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
