import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

class Phase1CenterSelector extends StatelessWidget {
  final List<BarberCenter> centers;
  final BarberCenter? selectedCenter;
  final ValueChanged<BarberCenter> onSelect;
  final bool isCompleted;

  const Phase1CenterSelector({
    super.key,
    required this.centers,
    required this.selectedCenter,
    required this.onSelect,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted && selectedCenter != null) {
      return _buildCompletedState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionLabel('1 · Elige tu centro'),
        const SizedBox(height: 18),
        if (centers.isEmpty)
          _buildEmptyState(context)
        else
          ...centers.asMap().entries.map((e) => _buildCenterCard(context, e.value)
              .animate()
              .fadeIn(delay: (70 * e.key).clamp(0, 300).ms, duration: 400.ms)
              .slideY(begin: -0.06, end: 0, delay: (70 * e.key).clamp(0, 300).ms, duration: 400.ms, curve: Curves.easeOutCubic)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No hay sedes disponibles por ahora',
          style: GoogleFonts.inter(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: gold, size: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CENTRO SELECCIONADO',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  Text(selectedCenter!.name,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          Icon(Icons.check_circle_rounded, color: gold, size: 20),
        ],
      ),
    );
  }

  Widget _buildCenterCard(BuildContext context, BarberCenter center) {
    final gold = context.primaryGold;
    final isSelected = selectedCenter?.id == center.id;
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: () => onSelect(center),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? gold.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? gold : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: gold.withValues(alpha: 0.22), blurRadius: 16, spreadRadius: -3)] : null,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: center.imageUrl != null
                      ? Image.network(
                          center.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const ColoredBox(
                            color: Colors.white10,
                            child: Icon(Icons.storefront_rounded, color: Colors.white38),
                          ),
                        )
                      : const ColoredBox(
                          color: Colors.white10,
                          child: Icon(Icons.storefront_rounded, color: Colors.white38),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(center.name,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(center.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? gold : Colors.white24,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
