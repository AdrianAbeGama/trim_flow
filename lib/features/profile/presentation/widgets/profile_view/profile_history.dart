import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_history_sheet.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_primitives.dart';

class ProfileHistoryTimeline extends StatelessWidget {
  const ProfileHistoryTimeline({
    super.key,
    required this.history,
    this.hasMore = false,
  });

  final List<PastAppointment> history;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    final preview = history.take(3).toList();
    final showViewAll = history.length > 3 && hasMore;
    final gold = context.primaryGold;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSectionTitle(
              text: 'Historial de cortes',
              trailing: history.isEmpty ? null : '${history.length}',
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: history.isEmpty
                  ? const _HistoryEmpty()
                  : Column(
                      children: [
                        for (var i = 0; i < preview.length; i++)
                          ProfileHistoryRowItem(
                            item: preview[i],
                            isLast: i == preview.length - 1 && !showViewAll,
                            onTap: () => ProfileHistoryDetailSheet.show(context, preview[i]),
                          ),
                        if (showViewAll)
                          _ViewAllRow(
                            total: history.length,
                            history: history,
                            gold: gold,
                          ),
                      ],
                    ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 640.ms, duration: 600.ms),
      ),
    );
  }
}

/// Empty state premium del historial — sin cortes todavía.
class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Text(
        'Aún no tienes historial',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

/// Tile de motivo en el sheet de cancelación.
class ProfileHistoryRowItem extends StatelessWidget {
  const ProfileHistoryRowItem({
    super.key, required this.item, this.isLast = false, this.onTap});

  final PastAppointment item;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final isCompleted = item.status == 'completed';
    final accent =
        isCompleted ? context.primaryGold : const Color(0xFFCF6679);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          HistoryStatusCircle(accent: accent, isCompleted: isCompleted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.professionalName} · ${item.dateStr}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.4)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          HistoryTrailing(
            price: item.paidPrice,
            accent: accent,
            gold: gold,
            discounted: item.wasDiscounted,
            isCompleted: isCompleted,
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.white.withValues(alpha: 0.25)),
          ],
        ],
      ),
    );

    final row = onTap == null
        ? content
        : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: content);

    if (isLast) return row;
    return Column(children: [row, const HistoryRowDivider()]);
  }
}

/// Indicador de estado del historial — línea vertical fina con el color del
/// tenant (completado) o rojo (cancelado). Reemplaza el círculo grande.
class HistoryStatusCircle extends StatelessWidget {
  const HistoryStatusCircle({super.key, required this.accent, required this.isCompleted});

  final Color accent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 34,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isCompleted ? 0.9 : 0.85),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

/// Precio o estado al final de una fila de historial — compartido.
class HistoryTrailing extends StatelessWidget {
  const HistoryTrailing({
    super.key,
    required this.price,
    required this.accent,
    required this.gold,
    required this.discounted,
    required this.isCompleted,
  });

  final double? price;
  final Color accent;
  final Color gold;
  final bool discounted;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (price != null && price! > 0) {
      return Text(
        'S/ ${price!.toStringAsFixed(0)}',
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: discounted ? accent : gold, letterSpacing: -0.3),
      );
    }
    return Text(
      isCompleted ? '—' : 'Cancelado',
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: accent.withValues(alpha: isCompleted ? 0.4 : 1)),
    );
  }
}

/// Separador fino entre filas del historial — compartido.
class HistoryRowDivider extends StatelessWidget {
  const HistoryRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}

/// Row "VER LOS X CORTES" — abre sheet con historial completo.
class _ViewAllRow extends StatefulWidget {
  const _ViewAllRow({
    required this.total,
    required this.history,
    required this.gold,
  });

  final int total;
  final List<PastAppointment> history;
  final Color gold;

  @override
  State<_ViewAllRow> createState() => _ViewAllRowState();
}

class _ViewAllRowState extends State<_ViewAllRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        ProfileFullHistorySheet.show(context, widget.history);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: _pressed
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.transparent,
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
                  color: widget.gold,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: widget.gold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet con historial completo del cliente.
