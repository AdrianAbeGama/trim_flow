import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/agenda/domain/models/agenda_appointment.dart';

Color agendaStatusColor(AgendaStatus status, Color gold) {
  switch (status) {
    case AgendaStatus.pending:
      return gold;
    case AgendaStatus.confirmed:
      return Colors.white;
    case AgendaStatus.completed:
      return const Color(0xFF6E6E6E);
    case AgendaStatus.cancelled:
    case AgendaStatus.noShow:
      return const Color(0xFFCF6679);
    case AgendaStatus.unknown:
      return Colors.white38;
  }
}

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
      case AgendaStatus.pending:
        return _StatusPalette(
          bg: gold.withValues(alpha: 0.12),
          border: gold.withValues(alpha: 0.45),
          dot: gold,
          text: gold,
          glow: false,
        );
      case AgendaStatus.confirmed:
        return _StatusPalette(
          bg: Colors.white.withValues(alpha: 0.06),
          border: Colors.white.withValues(alpha: 0.18),
          dot: Colors.white.withValues(alpha: 0.85),
          text: Colors.white.withValues(alpha: 0.8),
          glow: false,
        );
      case AgendaStatus.completed:
        return _StatusPalette(
          bg: Colors.white.withValues(alpha: 0.04),
          border: Colors.white.withValues(alpha: 0.10),
          dot: const Color(0xFF6E6E6E),
          text: Colors.white.withValues(alpha: 0.42),
          glow: false,
        );
      case AgendaStatus.cancelled:
      case AgendaStatus.noShow:
        return const _StatusPalette(
          bg: Color(0x22CF6679),
          border: Color(0x66CF6679),
          dot: Color(0xFFCF6679),
          text: Color(0xFFD79BA6),
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
