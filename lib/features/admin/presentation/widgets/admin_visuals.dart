import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Paleta multicolor para series (barberos, servicios, etc.).
const List<Color> adminPalette = [
  Color(0xFF3E8E6F),
  Color(0xFF6E6AB0),
  Color(0xFF3F8E9C),
  Color(0xFF4A77AE),
  Color(0xFFB68A4A),
  Color(0xFFB06A74),
  Color(0xFF8A9A52),
  Color(0xFF9A6AA8),
];

/// Color propio por metodo de pago (efectivo verde, yape morado, etc.).
Color adminPaymentColor(String method) {
  switch (method) {
    case 'cash':
      return const Color(0xFF3E8E6F);
    case 'yape':
      return const Color(0xFF6E6AB0);
    case 'plin':
      return const Color(0xFF3F8E9C);
    case 'card_present':
      return const Color(0xFF4A77AE);
    case 'transfer':
      return const Color(0xFFB68A4A);
    case 'other':
      return const Color(0xFFB06A74);
    default:
      return const Color(0xFF6B7280);
  }
}

/// Visuales premium del panel admin SIN recuadros de fondo: metricas abiertas,
/// barras, dona y reloj analogico en vivo. Todo pintado a mano (sin paquetes
/// extra) y con el acento del tenant.

const Color _adminUp = Color(0xFF34C759);
const Color _adminDown = Color(0xFFCF6679);

/// Paleta de series derivada del acento: degrada a tonos del dorado y neutros.
List<Color> adminSeriesColors(Color gold, int n) {
  final base = <Color>[
    gold,
    gold.withValues(alpha: 0.62),
    Colors.white.withValues(alpha: 0.55),
    gold.withValues(alpha: 0.38),
    Colors.white.withValues(alpha: 0.3),
    Colors.white.withValues(alpha: 0.16),
  ];
  if (n <= base.length) return base.sublist(0, n);
  return [for (var i = 0; i < n; i++) base[i % base.length]];
}

/// Linea fina divisoria (reemplaza los bordes de las cajas).
class AdminHairline extends StatelessWidget {
  const AdminHairline({super.key, this.vertical = false, this.length});
  final bool vertical;
  final double? length;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.07);
    return vertical
        ? Container(width: 1, height: length ?? 30, color: color)
        : Container(height: 1, width: length, color: color);
  }
}

/// Metrica protagonista: numero enorme abierto (sin caja), con delta opcional.
class AdminHeroMetric extends StatelessWidget {
  const AdminHeroMetric({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.delta,
  });

  final String label;
  final String value;
  final String? caption;
  final ({bool up, String text})? delta;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: gold,
                  letterSpacing: -1.6,
                  height: 1,
                ),
              ),
            ),
            if (delta != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: _DeltaPill(up: delta!.up, text: delta!.text),
              ),
            ],
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: 7),
          Text(
            caption!,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ],
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.up, required this.text});
  final bool up;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = up ? _adminUp : _adminDown;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 12, color: c),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w800, color: c),
          ),
        ],
      ),
    );
  }
}

/// Metrica secundaria abierta (sin caja). Usar dentro de [AdminStatStrip].
class AdminStat {
  const AdminStat({required this.label, required this.value});
  final String label;
  final String value;
}

/// Fila de metricas secundarias separadas por lineas finas (sin cajas).
class AdminStatStrip extends StatelessWidget {
  const AdminStatStrip({super.key, required this.stats});
  final List<AdminStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const AdminHairline(vertical: true, length: 32),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 14, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats[i].value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stats[i].label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Avatar circular con iniciales (sin foto) para rankings/listas.
class AdminInitialAvatar extends StatelessWidget {
  const AdminInitialAvatar({super.key, required this.name, this.size = 36});
  final String name;
  final double size;

  static String initialsOf(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gold.withValues(alpha: 0.12),
        border: Border.all(color: gold.withValues(alpha: 0.22)),
      ),
      child: Text(
        initialsOf(name),
        style: GoogleFonts.inter(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: gold,
        ),
      ),
    );
  }
}

/// Fila tipo barra horizontal (ranking / desglose) abierta, sin caja.
class AdminBarRow extends StatelessWidget {
  const AdminBarRow({
    super.key,
    required this.title,
    required this.amount,
    required this.fraction,
    this.note,
    this.leading,
  });

  final String title;
  final String amount;
  final double fraction;
  final String? note;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final f = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      amount,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: gold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Stack(
                          children: [
                            Container(
                                height: 5,
                                color: Colors.white.withValues(alpha: 0.06)),
                            FractionallySizedBox(
                              widthFactor: f,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: gold,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (note != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        note!,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dona (donut) pintada a mano con texto al centro.
class AdminDonut extends StatelessWidget {
  const AdminDonut({
    super.key,
    required this.segments,
    this.size = 132,
    this.centerTop,
    this.centerBottom,
  });

  final List<({double value, Color color})> segments;
  final double size;
  final String? centerTop;
  final String? centerBottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          segments: segments,
          track: Colors.white.withValues(alpha: 0.06),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerTop != null)
                Text(
                  centerTop!,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1,
                  ),
                ),
              if (centerBottom != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      centerBottom!,
                      maxLines: 1,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
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

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.track});
  final List<({double value, Color color})> segments;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.13;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);

    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    var start = -math.pi / 2;
    const gap = 0.05;
    for (final seg in segments) {
      final full = (seg.value / total) * (2 * math.pi);
      final sweep = full - gap;
      if (sweep > 0) {
        final p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = seg.color;
        canvas.drawArc(rect, start + gap / 2, sweep, false, p);
      }
      start += full;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => true;
}

/// Item de leyenda para la dona (punto + etiqueta + valor).
class AdminLegendItem extends StatelessWidget {
  const AdminLegendItem({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    this.note,
  });

  final Color color;
  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          if (note != null) ...[
            const SizedBox(width: 6),
            Text(
              note!,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.38),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reloj analogico en vivo (tic tac cada segundo), pintado a mano.
class AdminAnalogClock extends StatefulWidget {
  const AdminAnalogClock({super.key, this.size = 124, this.open = true});
  final double size;
  final bool open;

  @override
  State<AdminAnalogClock> createState() => _AdminAnalogClockState();
}

class _AdminAnalogClockState extends State<AdminAnalogClock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _ClockPainter(
          time: _now,
          accent: widget.open ? gold : Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter({required this.time, required this.accent});
  final DateTime time;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      c,
      r - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.08),
    );

    for (var i = 0; i < 12; i++) {
      final a = (i / 12) * 2 * math.pi - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final outer = c + dir * (r - 6);
      final inner = c + dir * (r - (i % 3 == 0 ? 14 : 10));
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = i % 3 == 0 ? 2 : 1
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: i % 3 == 0 ? 0.32 : 0.14),
      );
    }

    final hour = (time.hour % 12) + time.minute / 60;
    final minute = time.minute + time.second / 60;
    _hand(canvas, c, (hour / 12) * 2 * math.pi, r * 0.5, 3.2,
        Colors.white.withValues(alpha: 0.85));
    _hand(canvas, c, (minute / 60) * 2 * math.pi, r * 0.72, 2.4,
        Colors.white.withValues(alpha: 0.7));
    _hand(canvas, c, (time.second / 60) * 2 * math.pi, r * 0.78, 1.2, accent);

    canvas.drawCircle(c, 3.4, Paint()..color = accent);
    canvas.drawCircle(c, 1.4, Paint()..color = const Color(0xFF0A0A0A));
  }

  void _hand(Canvas canvas, Offset c, double angle, double len, double w,
      Color color) {
    final a = angle - math.pi / 2;
    final end = c + Offset(math.cos(a), math.sin(a)) * len;
    canvas.drawLine(
      c,
      end,
      Paint()
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) =>
      old.time != time || old.accent != accent;
}

/// Un segmento de datos para [AdminSeriesChart].
class ChartSeg {
  const ChartSeg({
    required this.label,
    required this.value,
    required this.color,
    this.note,
  });

  final String label;
  final double value;
  final Color color;
  final String? note;
}

/// Grafico con vistas conmutables (Dona / Barras / Columnas). Para muchos items
/// arranca en barras. Cada segmento lleva su color.
class AdminSeriesChart extends StatefulWidget {
  const AdminSeriesChart({
    super.key,
    required this.segments,
    required this.formatValue,
    this.centerTop = 'TOTAL',
  });

  final List<ChartSeg> segments;
  final String Function(double) formatValue;
  final String centerTop;

  @override
  State<AdminSeriesChart> createState() => _AdminSeriesChartState();
}

class _AdminSeriesChartState extends State<AdminSeriesChart> {
  static const _labels = ['Dona', 'Barras', 'Columnas'];
  int _view = 0;

  @override
  void initState() {
    super.initState();
    _view = widget.segments.length > 6 ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) {
      return Text(
        'Sin datos en este periodo',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.35),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _toggle(context),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: switch (_view) {
            1 => _bars(context),
            2 => _columns(context),
            _ => _donut(context),
          },
        ),
      ],
    );
  }

  Widget _toggle(BuildContext context) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _view = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: _view == i ? gold : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _view == i
                      ? gold
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                _labels[i],
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: _view == i
                      ? onAccent
                      : Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _donut(BuildContext context) {
    final total = widget.segments.fold<double>(0, (s, e) => s + e.value);
    return Row(
      key: const ValueKey('donut'),
      children: [
        AdminDonut(
          segments: [
            for (final s in widget.segments) (value: s.value, color: s.color),
          ],
          centerTop: widget.centerTop,
          centerBottom: widget.formatValue(total),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              for (final s in widget.segments)
                AdminLegendItem(
                  color: s.color,
                  label: s.label,
                  value: widget.formatValue(s.value),
                  note: s.note,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bars(BuildContext context) {
    final maxV = widget.segments.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    return Column(
      key: const ValueKey('bars'),
      children: [
        for (final s in widget.segments)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration:
                          BoxDecoration(color: s.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.formatValue(s.value),
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (s.note != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        s.note!,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Stack(
                    children: [
                      Container(
                          height: 6,
                          color: Colors.white.withValues(alpha: 0.06)),
                      FractionallySizedBox(
                        widthFactor: maxV <= 0 ? 0 : s.value / maxV,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _columns(BuildContext context) {
    final maxV = widget.segments.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    return SizedBox(
      key: const ValueKey('cols'),
      height: 168,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final s in widget.segments)
              Container(
                width: 60,
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.formatValue(s.value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: maxV <= 0
                          ? 3
                          : (112 * (s.value / maxV)).clamp(3, 112),
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 26,
                      child: Text(
                        s.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.5),
                          height: 1.2,
                        ),
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
