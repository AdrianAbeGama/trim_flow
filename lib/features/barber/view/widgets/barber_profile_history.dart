import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_primitives.dart';

/// Modelo público de item histórico — usado por History list y FullHistorySheet.
class BarberHistoryItem {
  final String service;
  final String client;
  final String dateStr;
  final double price;
  final bool isCompleted;

  const BarberHistoryItem({
    required this.service,
    required this.client,
    required this.dateStr,
    required this.price,
    required this.isCompleted,
  });
}

/// Preview de historial (3 items) con "VER TODOS" si hay más.
class BarberProfileHistory extends StatelessWidget {
  const BarberProfileHistory({
    super.key,
    required this.history,
    required this.onSeeAll,
  });

  final List<BarberHistoryItem> history;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final preview = history.take(3).toList();
    final hasMore = history.length > 3;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarberSectionTitle(
              text: 'Historial de cortes',
              trailing: '${history.length}',
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < preview.length; i++)
                    BarberHistoryRow(
                      item: preview[i],
                      isLast: i == preview.length - 1 && !hasMore,
                    ),
                  if (hasMore)
                    _ViewAllRow(total: history.length, onTap: onSeeAll),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 580.ms, duration: 600.ms),
      ),
    );
  }
}

class _ViewAllRow extends StatefulWidget {
  const _ViewAllRow({required this.total, required this.onTap});

  final int total;
  final VoidCallback onTap;

  @override
  State<_ViewAllRow> createState() => _ViewAllRowState();
}

class _ViewAllRowState extends State<_ViewAllRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: _pressed ? Colors.white.withValues(alpha: 0.03) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VER LOS ${widget.total} CORTES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: gold,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: gold),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila individual del historial — timeline dot + service + status + price.
/// Pública porque la usa también la FullHistorySheet.
class BarberHistoryRow extends StatelessWidget {
  const BarberHistoryRow({super.key, required this.item, this.isLast = false});

  final BarberHistoryItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final accent = item.isCompleted
        ? const Color(0xFF6FAE8A)
        : const Color(0xFFCF6679);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Icon(item.isCompleted ? Icons.check_rounded : Icons.close_rounded, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.client} · ${item.dateStr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (item.isCompleted && item.price > 0)
            Text(
              'S/ ${item.price.toStringAsFixed(0)}',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: gold, letterSpacing: -0.3),
            )
          else
            Text(
              item.isCompleted ? '—' : 'Cancelado',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: accent.withValues(alpha: item.isCompleted ? 0.4 : 1)),
            ),
        ],
      ),
    );
    if (isLast) return row;
    return Column(
      children: [
        row,
        Container(
          margin: const EdgeInsets.only(left: 74),
          height: 1,
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ],
    );
  }
}
