import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/widgets/profile_view/profile_history.dart';

/// Sheet adaptable de historial: pequeño al inicio (muestra ~3), con scroll si
/// hay más, y un botón de pantalla completa.
class ProfileFullHistorySheet extends StatelessWidget {
  const ProfileFullHistorySheet({super.key, required this.history});

  final List<PastAppointment> history;

  static void show(BuildContext context, List<PastAppointment> history) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfileFullHistorySheet(history: history),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Historial',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${history.length}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      const Spacer(),
                      _CircleIcon(
                        icon: Icons.fullscreen_rounded,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => ProfileHistoryFullView(history: history)),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _CircleIcon(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: mq.size.height * 0.5),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: history.length,
                itemBuilder: (_, i) {
                  return ProfileHistoryRowItem(
                    item: history[i],
                    isLast: i == history.length - 1,
                    onTap: () => ProfileHistoryDetailSheet.show(context, history[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Historial a pantalla completa (estilo "Destacados"): header animado + lista.
class ProfileHistoryFullView extends StatelessWidget {
  const ProfileHistoryFullView({super.key, required this.history});

  final List<PastAppointment> history;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
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
                                '${history.length} ${history.length == 1 ? "CORTE" : "CORTES"}',
                                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: gold, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 22),
                    Text('Tu', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55), letterSpacing: -0.2))
                        .animate().fadeIn(delay: 120.ms, duration: 500.ms).slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 4),
                    Text('Historial', style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.6, height: 1.05))
                        .animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(width: 16, height: 1.5, color: gold),
                        const SizedBox(width: 8),
                        Text('Todos tus cortes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), letterSpacing: -0.1)),
                      ],
                    ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList.builder(
              itemCount: history.length,
              itemBuilder: (_, i) => ProfileHistoryRowItem(
                item: history[i],
                isLast: i == history.length - 1,
                onTap: () => ProfileHistoryDetailSheet.show(context, history[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detalle completo de un corte del historial (incluye motivo si fue cancelado).
class ProfileHistoryDetailSheet extends StatelessWidget {
  const ProfileHistoryDetailSheet({super.key, required this.item});

  final PastAppointment item;

  static void show(BuildContext context, PastAppointment item) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfileHistoryDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final isCompleted = item.status == 'completed';
    final accent = isCompleted ? const Color(0xFF6FAE8A) : const Color(0xFFCF6679);
    final statusLabel = isCompleted ? 'COMPLETADO' : 'CANCELADO';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 5, height: 5, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(statusLabel, style: GoogleFonts.inter(color: accent, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _line('Barbero', item.professionalName),
            _line('Centro', item.centerName),
            _line('Fecha', item.dateStr),
            if (item.paidPrice != null) _line('Precio', 'S/ ${item.paidPrice!.toStringAsFixed(2)}', valueColor: gold),
            if (isCompleted && item.rating > 0) _line('Calificación', '${item.rating} / 5'),
            if (!isCompleted && (item.cancellationReason ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MOTIVO DE CANCELACIÓN', style: GoogleFonts.inter(color: accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text(item.cancellationReason!, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: valueColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.9,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}
