// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/products/domain/models/product_category.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<ProductCategory> categories;
  final String? selectedId;
  final Function(String?) onSelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTRAR POR CATEGORÍA',
            style: GoogleFonts.inter(
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
                isSelected: selectedId == null,
                onTap: () => onSelected(null),
              ),
              ...categories.where((cat) => cat.id != 'todos').map((cat) => _FilterChip(
                    label: cat.name.toUpperCase(),
                    isSelected: selectedId == cat.id,
                    onTap: () => onSelected(cat.id),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? context.primaryGold : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? context.primaryGold : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: widget.isSelected ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
