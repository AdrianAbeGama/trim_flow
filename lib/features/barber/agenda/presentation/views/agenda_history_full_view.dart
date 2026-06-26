import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';
import 'package:trim_flow/features/barber/agenda/presentation/widgets/appointment_card.dart';

/// Historial a pantalla completa (estilo "Destacados") con gráfica de
/// ingresos por día. Recibe las citas completadas/canceladas/no-show.
class AgendaHistoryFullView extends StatelessWidget {
  const AgendaHistoryFullView({super.key, required this.appointments});

  final List<AgendaAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    final totalEarned = appointments
        .where((a) => a.status == AgendaStatus.completed)
        .fold<double>(0, (s, a) => s + (a.priceAtBooking ?? 0));

    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _Header(count: appointments.length, totalEarned: totalEarned),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: _RevenueChartCard(appointments: appointments)
                    .animate()
                    .fadeIn(delay: 360.ms, duration: 500.ms)
                    .slideY(begin: 0.08, end: 0, delay: 360.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
            ),
            if (appointments.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList.separated(
                  itemCount: appointments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return AppointmentCard(appointment: appointments[index])
                        .animate()
                        .fadeIn(delay: (40 * index).clamp(0, 500).ms, duration: 450.ms, curve: Curves.easeOutCubic)
                        .slideY(begin: 0.08, end: 0, delay: (40 * index).clamp(0, 500).ms, duration: 500.ms, curve: Curves.easeOutCubic);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.totalEarned});
  final int count;
  final double totalEarned;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PremiumBackButton(onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  }),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: gold.withValues(alpha: 0.55)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, color: gold, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          '$count ${count == 1 ? "CORTE" : "CORTES"}',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: gold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 22),
              Text(
                'Tu',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 4),
              Text(
                'Historial',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(width: 16, height: 1.5, color: gold),
                  const SizedBox(width: 8),
                  Text(
                    'Ganado: S/ ${totalEarned.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: gold, letterSpacing: -0.1),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 320.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard({required this.appointments});

  final List<AgendaAppointment> appointments;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final now = DateTime.now();
    final realToday = appointments
        .where((a) => a.status == AgendaStatus.completed)
        .fold<double>(0, (s, a) => s + (a.priceAtBooking ?? 0));

    final values = <double>[0, 0, 0, 0, 0, 0, realToday];
    final labels = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateFormat('E', 'es').format(day).substring(0, 1).toUpperCase();
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'INGRESOS · 7 DÍAS',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4),
              ),
              const Spacer(),
              Text(
                'solo hoy',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.25), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(values: values, labels: labels, accent: gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.values, required this.labels, required this.accent});

  final List<double> values;
  final List<String> labels;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final bestIndex = values.indexOf(maxVal);
    const topPad = 18.0; // espacio reservado arriba para la etiqueta del valor
    const labelH = 20.0; // espacio abajo para el día
    final baseline = size.height - labelH;
    final maxBarH = baseline - topPad;
    final slot = size.width / values.length;
    const barW = 18.0;

    // Baseline sutil.
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseline), Offset(size.width, baseline), basePaint);

    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < values.length; i++) {
      final cx = slot * i + slot / 2;
      final norm = maxVal <= 0 ? 0.0 : values[i] / maxVal;
      final barH = (maxBarH * norm).clamp(3.0, maxBarH);
      final isBest = i == bestIndex && maxVal > 0;
      final top = baseline - barH;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - barW / 2, top, barW, barH),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      final paint = Paint()..color = isBest ? accent : Colors.white.withValues(alpha: 0.12);
      canvas.drawRRect(rect, paint);

      // Valor sobre la mejor barra, en el margen superior reservado (sin solape).
      if (isBest) {
        tp.text = TextSpan(
          text: 'S/${values[i].toStringAsFixed(0)}',
          style: GoogleFonts.inter(color: accent, fontSize: 10, fontWeight: FontWeight.w900),
        );
        tp.layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, (top - 15).clamp(0.0, baseline)));
      }

      // Label del día.
      tp.text = TextSpan(
        text: labels[i],
        style: GoogleFonts.inter(
          color: isBest ? accent : Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, baseline + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.accent != accent;
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.history_rounded, color: gold, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            'Sin historial aún',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.4),
          ),
          const SizedBox(height: 6),
          Text(
            'Los cortes completados y cancelados\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ],
      ),
    );
  }
}
