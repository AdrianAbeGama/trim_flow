import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';

class AgendaStatusBadge extends StatelessWidget {
  const AgendaStatusBadge({super.key, required this.status, this.compact = false});

  final AgendaStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final palette = _palette(gold);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border, width: 0.8),
        boxShadow: palette.glow
            ? [BoxShadow(color: palette.dot.withValues(alpha: 0.35), blurRadius: 6)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(color: palette.dot, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 5 : 7),
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
              color: palette.text,
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  _StatusPalette _palette(Color gold) {
    switch (status) {
      case AgendaStatus.confirmed:
        return const _StatusPalette(
          bg: Color(0x223B82F6),
          border: Color(0xAA3B82F6),
          dot: Color(0xFF3B82F6),
          text: Color(0xFF60A5FA),
          glow: true,
        );
      case AgendaStatus.pending:
        return const _StatusPalette(
          bg: Color(0x11F59E0B),
          border: Color(0x66F59E0B),
          dot: Color(0xFFF59E0B),
          text: Color(0xFFFBBF24),
          glow: false,
        );
      case AgendaStatus.completed:
        return const _StatusPalette(
          bg: Color(0x1F4ADE80),
          border: Color(0xFF4ADE80),
          dot: Color(0xFF4ADE80),
          text: Color(0xFF8FE9B0),
          glow: false,
        );
      case AgendaStatus.cancelled:
      case AgendaStatus.noShow:
        return const _StatusPalette(
          bg: Color(0x33CF6679),
          border: Color(0x99CF6679),
          dot: Color(0xFFCF6679),
          text: Color(0xFFE3A0AC),
          glow: false,
        );
      case AgendaStatus.unknown:
        return _StatusPalette(
          bg: Colors.white.withValues(alpha: 0.04),
          border: Colors.white24,
          dot: Colors.white38,
          text: Colors.white60,
          glow: false,
        );
    }
  }
}

class _StatusPalette {
  final Color bg;
  final Color border;
  final Color dot;
  final Color text;
  final bool glow;
  const _StatusPalette({
    required this.bg,
    required this.border,
    required this.dot,
    required this.text,
    required this.glow,
  });
}
