import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/avatar_premium.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/home/view/home_page.dart';
import 'package:core/core.dart';

class Phase3ProfessionalSelector extends StatefulWidget {
  final List<Professional> professionals;
  final Professional? selectedProfessional;
  final bool hasSelectedAny;
  final ValueChanged<Professional?> onSelect;
  final bool isCompleted;

  const Phase3ProfessionalSelector({
    super.key,
    required this.professionals,
    required this.selectedProfessional,
    required this.hasSelectedAny,
    required this.onSelect,
    required this.isCompleted,
  });

  @override
  State<Phase3ProfessionalSelector> createState() => _Phase3ProfessionalSelectorState();
}

class _Phase3ProfessionalSelectorState extends State<Phase3ProfessionalSelector> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted && widget.hasSelectedAny) {
      return _buildCompletedState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionLabel('3 · Elige a tu barbero'),
        const SizedBox(height: 18),
        _buildAnyAvailableOption(context),
        const SizedBox(height: 12),
        ...widget.professionals.asMap().entries.map((e) {
          return _buildProfessionalCard(context, e.value)
              .animate()
              .fadeIn(delay: (60 * e.key).clamp(0, 450).ms, duration: 400.ms)
              .slideY(begin: -0.06, end: 0, delay: (60 * e.key).clamp(0, 450).ms, duration: 400.ms, curve: Curves.easeOutCubic);
        }),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final gold = context.primaryGold;
    final title = widget.selectedProfessional?.name ?? 'Máxima Disponibilidad';
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
              Icon(Icons.person_rounded, color: gold, size: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BARBERO SELECCIONADO',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          Icon(Icons.check_circle_rounded, color: gold, size: 20),
        ],
      ),
    );
  }

  Widget _buildAnyAvailableOption(BuildContext context) {
    final gold = context.primaryGold;
    final isSelected = widget.hasSelectedAny && widget.selectedProfessional == null;
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: () => widget.onSelect(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? gold.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? gold : Colors.white.withValues(alpha: 0.06), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withValues(alpha: 0.12),
                border: Border.all(color: gold.withValues(alpha: 0.4)),
              ),
              child: Icon(Icons.bolt_rounded, color: gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Máxima disponibilidad',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: gold, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                  const SizedBox(height: 2),
                  Text('Primer barbero disponible',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? gold : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(BuildContext context, Professional professional) {
    final gold = context.primaryGold;
    final isSelected = widget.selectedProfessional?.id == professional.id;
    final specialties = professional.specialties.join(' · ');

    return PremiumPressable(
      pressedScale: 0.98,
      onTap: () => widget.onSelect(professional),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? gold.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? gold : Colors.white.withValues(alpha: 0.06), width: isSelected ? 1.5 : 1),
          boxShadow: isSelected ? [BoxShadow(color: gold.withValues(alpha: 0.22), blurRadius: 16, spreadRadius: -3)] : null,
        ),
        child: Row(
          children: [
            AvatarPremium(displayName: professional.name, photoUrl: professional.imageUrl, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(professional.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 3),
                  if (specialties.isNotEmpty)
                    Text(specialties,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (professional.yearsOfExperience > 0)
                        Text('${professional.yearsOfExperience} años de experiencia',
                            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w500)),
                      PremiumPressable(
                        pressedScale: 0.92,
                        onTap: () => HomePage.requestedTab.value = HomePage.galleryTabIndex,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Ver trabajos', style: GoogleFonts.inter(color: gold, fontSize: 11, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_forward_rounded, size: 12, color: gold),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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
