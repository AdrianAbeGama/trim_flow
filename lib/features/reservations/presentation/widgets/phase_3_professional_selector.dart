import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:core/core.dart';

class Phase3ProfessionalSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isCompleted && hasSelectedAny) {
      return _buildCompletedState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. ELIGE A TU BARBERO',
          style: TextStyle(
            color: context.primaryGold,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        _buildAnyAvailableOption(context),
        const SizedBox(height: 14),
        ...professionals.map((prof) => _buildProfessionalCard(context, prof)),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final title =
        selectedProfessional?.name ?? 'Máxima Disponibilidad';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: context.primaryGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded,
                  color: context.primaryGold, size: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Barbero Seleccionado',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.check_circle_rounded,
              color: context.primaryGold, size: 20),
        ],
      ),
    );
  }

  Widget _buildAnyAvailableOption(BuildContext context) {
    final isSelected = hasSelectedAny && selectedProfessional == null;
    return GestureDetector(
      onTap: () => onSelect(null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryGold.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.primaryGold
                : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primaryGold.withValues(alpha: 0.1),
              ),
              child:
                  Icon(Icons.person_rounded, color: context.primaryGold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Máxima Disponibilidad',
                    style: TextStyle(
                      color: context.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Primer barbero disponible',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? context.primaryGold : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(BuildContext context, Professional professional) {
    final isSelected = selectedProfessional?.id == professional.id;
    final isUnavailable = !professional.isAvailable;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? context.primaryGold.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? context.primaryGold
              : Colors.white.withValues(alpha: 0.06),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: professional.imageUrl != null
                    ? Image.network(
                        professional.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const ColoredBox(
                          color: Colors.white10,
                          child: Icon(Icons.person_rounded,
                              color: Colors.white38),
                        ),
                      )
                    : const ColoredBox(
                        color: Colors.white10,
                        child:
                            Icon(Icons.person_rounded, color: Colors.white38),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isUnavailable
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFF1A2F1A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.backgroundBlack,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isUnavailable ? '💀' : '✓',
                      style: TextStyle(
                        fontSize: isUnavailable ? 9 : 10,
                        color: isUnavailable
                            ? Colors.white
                            : Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: professional.specialties
                      .map(
                        (spec) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            spec,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 10),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        size: 12, color: context.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      '${professional.yearsOfExperience} años de experiencia',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (isUnavailable && professional.statusLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    professional.statusLabel!,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                )
              else
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? context.primaryGold : Colors.white24,
                  size: 22,
                ),
            ],
          ),
        ],
      ),
    );

    if (isUnavailable) {
      return IgnorePointer(
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.33, 0.59, 0.11, 0, 0,
            0.33, 0.59, 0.11, 0, 0,
            0.33, 0.59, 0.11, 0, 0,
            0,    0,    0,    1, 0,
          ]),
          child: card,
        ),
      );
    }

    return GestureDetector(
      onTap: () => onSelect(professional),
      child: card,
    );
  }
}
