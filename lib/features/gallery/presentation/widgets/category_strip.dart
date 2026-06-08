import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';

class GalleryCategoryStrip extends StatelessWidget {
  const GalleryCategoryStrip({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onSelect,
    required this.onShowAll,
    this.maxInline = 4,
  });

  final List<GalleryCategory> categories;
  final String? selectedSlug;
  final ValueChanged<String?> onSelect;
  final VoidCallback onShowAll;
  final int maxInline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FILTRAR POR CATEGORÍA',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              _FilterChip(
                label: 'TODOS',
                isSelected: selectedSlug == null,
                onTap: () => onSelect(null),
              ),
              ...categories.map((cat) => _FilterChip(
                    label: cat.label.toUpperCase(),
                    isSelected: selectedSlug == cat.slug,
                    onTap: () => onSelect(cat.slug),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryGold : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primaryGold : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
