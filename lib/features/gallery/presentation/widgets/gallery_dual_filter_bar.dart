// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';

class GalleryDualFilterBar extends StatelessWidget {
  const GalleryDualFilterBar({
    super.key,
    required this.filterMode,
    required this.categories,
    required this.selectedCategorySlug,
    required this.barbers,
    required this.selectedBarberName,
    required this.onModeChanged,
    required this.onCategorySelected,
    required this.onBarberSelected,
  });

  final GalleryFilterMode filterMode;
  final List<GalleryCategory> categories;
  final String? selectedCategorySlug;
  final List<GalleryBarberSummary> barbers;
  final String? selectedBarberName;
  final ValueChanged<GalleryFilterMode> onModeChanged;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<String?> onBarberSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                filterMode == GalleryFilterMode.styles
                    ? 'FILTRAR POR ESTILO'
                    : 'FILTRAR POR BARBERO',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              _ModeToggle(mode: filterMode, onChanged: onModeChanged),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: filterMode == GalleryFilterMode.styles
                ? _StyleChips(
                    key: const ValueKey('styles'),
                    categories: categories,
                    selectedSlug: selectedCategorySlug,
                    onSelected: onCategorySelected,
                  )
                : _BarberChips(
                    key: const ValueKey('barbers'),
                    barbers: barbers,
                    selectedName: selectedBarberName,
                    onSelected: onBarberSelected,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final GalleryFilterMode mode;
  final ValueChanged<GalleryFilterMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: 'ESTILOS',
            isSelected: mode == GalleryFilterMode.styles,
            onTap: () => onChanged(GalleryFilterMode.styles),
            gold: gold,
          ),
          _ToggleChip(
            label: 'BARBEROS',
            isSelected: mode == GalleryFilterMode.barbers,
            onTap: () => onChanged(GalleryFilterMode.barbers),
            gold: gold,
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.gold,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? gold : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : gold.withValues(alpha: 0.85),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _StyleChips extends StatelessWidget {
  const _StyleChips({
    super.key,
    required this.categories,
    required this.selectedSlug,
    required this.onSelected,
  });

  final List<GalleryCategory> categories;
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: [
        _FlatChip(
          label: 'TODOS',
          isSelected: selectedSlug == null,
          onTap: () => onSelected(null),
        ),
        ...categories.map(
          (cat) => _FlatChip(
            label: cat.label.toUpperCase(),
            isSelected: selectedSlug == cat.slug,
            onTap: () => onSelected(cat.slug),
          ),
        ),
      ],
    );
  }
}

class _FlatChip extends StatelessWidget {
  const _FlatChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryGold : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.primaryGold
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarberChips extends StatelessWidget {
  const _BarberChips({
    super.key,
    required this.barbers,
    required this.selectedName,
    required this.onSelected,
  });

  final List<GalleryBarberSummary> barbers;
  final String? selectedName;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (barbers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          'AUN NO HAY BARBEROS REGISTRADOS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarChip(
            label: 'TODOS',
            isSelected: selectedName == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 16),
          ...barbers.map((barber) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _AvatarChip(
                label: barber.name.toUpperCase(),
                imageUrl: barber.avatarHint,
                isSelected: selectedName == barber.name,
                onTap: () => onSelected(barber.name),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip({
    required this.label,
    this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            padding: EdgeInsets.all(isSelected ? 3 : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? gold : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFF222222),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _FallbackIcon(),
                      )
                    : _FallbackIcon(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? gold : Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_rounded,
      color: Colors.white24,
      size: 30,
    );
  }
}
