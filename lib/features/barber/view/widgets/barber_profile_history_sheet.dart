import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/barber/view/widgets/barber_profile_history.dart';

/// Sheet adaptable del historial del barbero: pequeño al inicio (~3), con scroll
/// si hay más, y botón de pantalla completa.
class BarberProfileFullHistorySheet extends StatelessWidget {
  const BarberProfileFullHistorySheet({super.key, required this.history});

  final List<BarberHistoryItem> history;

  static void show(BuildContext context, List<BarberHistoryItem> history) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BarberProfileFullHistorySheet(history: history),
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
                      Text('Historial', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(width: 8),
                      Text('${history.length}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.3))),
                      const Spacer(),
                      _CircleIcon(
                        icon: Icons.fullscreen_rounded,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => BarberProfileHistoryFullView(history: history)),
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
                itemBuilder: (_, i) => BarberHistoryRow(item: history[i], isLast: i == history.length - 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Historial del barbero a pantalla completa (estilo "Destacados").
class BarberProfileHistoryFullView extends StatelessWidget {
  const BarberProfileHistoryFullView({super.key, required this.history});

  final List<BarberHistoryItem> history;

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
              itemBuilder: (_, i) => BarberHistoryRow(item: history[i], isLast: i == history.length - 1),
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
