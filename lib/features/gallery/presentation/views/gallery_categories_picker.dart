import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';

class GalleryCategoriesPicker extends StatelessWidget {
  const GalleryCategoriesPicker({
    super.key,
    required this.categories,
    required this.selectedSlug,
  });

  final List<GalleryCategory> categories;
  final String? selectedSlug;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0E0E0E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 3,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.layerGroup, color: gold, size: 14),
                  const SizedBox(width: 10),
                  const Text(
                    'CATEGORIAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 32, height: 2, color: gold),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _PickerTile(
                        label: 'TODAS LAS CATEGORIAS',
                        isSelected: selectedSlug == null,
                        onTap: () => Navigator.of(context).pop<String?>(null),
                      );
                    }
                    final cat = categories[index - 1];
                    return _PickerTile(
                      label: cat.label.toUpperCase(),
                      isSelected: selectedSlug == cat.slug,
                      onTap: () => Navigator.of(context).pop<String?>(cat.slug),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? gold.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: isSelected ? gold : gold.withValues(alpha: 0.18),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? gold : gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? gold : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            if (isSelected)
              FaIcon(FontAwesomeIcons.check, color: gold, size: 12),
          ],
        ),
      ),
    );
  }
}
