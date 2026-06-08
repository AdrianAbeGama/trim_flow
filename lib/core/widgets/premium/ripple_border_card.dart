import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tarjeta con borde animado: una onda de luz del color [accent] recorre el
/// contorno en bucle, con un contorno base sutil y un leve resplandor.
class RippleBorderCard extends StatefulWidget {
  const RippleBorderCard({
    super.key,
    required this.child,
    required this.accent,
    this.radius = 22,
  });

  final Widget child;
  final Color accent;
  final double radius;

  @override
  State<RippleBorderCard> createState() => _RippleBorderCardState();
}

class _RippleBorderCardState extends State<RippleBorderCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _SweepBorderPainter(t: _c.value, accent: widget.accent, radius: widget.radius),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SweepBorderPainter extends CustomPainter {
  _SweepBorderPainter({required this.t, required this.accent, required this.radius});

  final double t;
  final Color accent;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(radius));

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = accent.withValues(alpha: 0.14),
    );

    final sweep = SweepGradient(
      transform: GradientRotation(t * 2 * math.pi),
      colors: [
        accent.withValues(alpha: 0.0),
        accent.withValues(alpha: 0.0),
        accent.withValues(alpha: 0.95),
        accent.withValues(alpha: 0.0),
        accent.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = sweep.createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = sweep.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_SweepBorderPainter old) => old.t != t || old.accent != accent;
}
