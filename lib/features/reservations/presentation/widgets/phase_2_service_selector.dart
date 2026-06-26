import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:core/core.dart';

class Phase2ServiceSelector extends StatefulWidget {
  final List<Service> services;
  final List<Service> selectedServices;
  final ValueChanged<Service> onToggle;
  final bool isCompleted;

  const Phase2ServiceSelector({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.onToggle,
    required this.isCompleted,
  });

  @override
  State<Phase2ServiceSelector> createState() => _Phase2ServiceSelectorState();
}

class _Phase2ServiceSelectorState extends State<Phase2ServiceSelector> {
  String _selectedFilter = 'Todos';
  bool _showAllCategories = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isCompleted && widget.selectedServices.isNotEmpty) {
      return _buildCompletedState(context);
    }

    final allCategories = widget.services.map((s) => s.category).toSet().toList();
    final primaryFilters = ['Todos', 'Destacados'];
    final displayFilters =
        _showAllCategories ? [...primaryFilters, ...allCategories] : primaryFilters;

    List<Service> filteredServices;
    if (_selectedFilter == 'Todos') {
      filteredServices = widget.services;
    } else if (_selectedFilter == 'Destacados') {
      filteredServices = widget.services.where((s) => s.isFeatured).toList();
    } else {
      filteredServices = widget.services.where((s) => s.category == _selectedFilter).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionLabel('2 · Selecciona tu servicio'),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...displayFilters.map((cat) => _buildFilterChip(context, cat)),
            if (!_showAllCategories && allCategories.isNotEmpty) _buildExpandButton(context),
          ],
        ),
        const SizedBox(height: 18),
        if (filteredServices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No hay servicios en esta categoría',
                style: GoogleFonts.inter(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          )
        else
          ..._buildServiceList(context, filteredServices),
        const SizedBox(height: 160),
      ],
    );
  }

  /// Lista de servicios. En la vista "Todos" con varias categorias, los agrupa
  /// bajo un encabezado por categoria. Con un filtro especifico, lista plano.
  List<Widget> _buildServiceList(BuildContext context, List<Service> services) {
    if (_selectedFilter != 'Todos') {
      return [
        for (final e in services.asMap().entries) _animatedCard(context, e.key, e.value),
      ];
    }

    final order = <String>[];
    final byCategory = <String, List<Service>>{};
    for (final s in services) {
      if (!byCategory.containsKey(s.category)) {
        order.add(s.category);
        byCategory[s.category] = <Service>[];
      }
      byCategory[s.category]!.add(s);
    }
    final showHeaders = order.length > 1;

    final widgets = <Widget>[];
    var index = 0;
    for (final category in order) {
      if (showHeaders) widgets.add(_categoryHeader(context, category));
      for (final service in byCategory[category]!) {
        widgets.add(_animatedCard(context, index, service));
        index++;
      }
    }
    return widgets;
  }

  Widget _animatedCard(BuildContext context, int index, Service service) {
    final delay = (60 * index).clamp(0, 450).ms;
    return _buildServiceCard(context, service)
        .animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideY(begin: -0.06, end: 0, delay: delay, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _categoryHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10, left: 2),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          color: context.primaryGold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String cat) {
    final gold = context.primaryGold;
    final isSelected = _selectedFilter == cat;
    final isSpecial = cat == 'Destacados';

    return PremiumPressable(
      pressedScale: 0.92,
      onTap: () => setState(() => _selectedFilter = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? gold : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? gold
                : isSpecial
                    ? gold.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSpecial) ...[
              Icon(Icons.star_rounded, size: 14, color: isSelected ? context.backgroundBlack : gold),
              const SizedBox(width: 4),
            ],
            Text(
              cat,
              style: GoogleFonts.inter(
                color: isSelected ? context.backgroundBlack : (isSpecial ? gold : Colors.white70),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.9,
      onTap: () => setState(() => _showAllCategories = true),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Icon(Icons.add_rounded, size: 16, color: context.primaryGold),
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final gold = context.primaryGold;
    final service = widget.selectedServices.first;
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
          Expanded(
            child: Row(
              children: [
                Icon(Icons.content_cut_rounded, color: gold, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SERVICIO SELECCIONADO',
                          style: GoogleFonts.inter(color: Colors.white38, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: 2),
                      Text(
                        '${service.name} · S/ ${service.price.toStringAsFixed(2)}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: gold, size: 20),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    final gold = context.primaryGold;
    final isSelected = widget.selectedServices.any((s) => s.id == service.id);
    return PremiumPressable(
      pressedScale: 0.98,
      onTap: () => widget.onToggle(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (service.isFeatured) ...[
                        Icon(Icons.star_rounded, size: 14, color: gold),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          service.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.durationInMinutes} min · ${service.category}',
                    style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'S/ ${service.price.toStringAsFixed(0)}',
              style: GoogleFonts.inter(color: gold, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? gold : Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: isSelected ? gold : Colors.white.withValues(alpha: 0.12)),
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                color: isSelected ? context.backgroundBlack : Colors.white54,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
