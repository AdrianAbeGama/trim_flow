import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

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
        Text(
          '1. ELIGE TU CENTRO',
          style: TextStyle(
            color: context.primaryGold,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        ...centers.map((center) => _buildCenterCard(context, center)),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context) {
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
              Icon(Icons.location_on_rounded,
                  color: context.primaryGold, size: 18),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Centro Seleccionado',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    selectedCenter!.name,
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

  Widget _buildCenterCard(BuildContext context, BarberCenter center) {
    final isSelected = selectedCenter?.id == center.id;
    return GestureDetector(
      onTap: () => onSelect(center),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutQuart,
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
            ClipRRect(
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
                          child: Icon(Icons.storefront_rounded,
                              color: Colors.white38),
                        ),
                      )
                    : const ColoredBox(
                        color: Colors.white10,
                        child: Icon(Icons.storefront_rounded,
                            color: Colors.white38),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    center.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(
                        center.location,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? context.primaryGold : Colors.white24,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
