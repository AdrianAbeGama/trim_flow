import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
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
    final primaryFilters = ['Todos', 'Destacados', 'Guardados'];
    
    // Si no está expandido, solo mostramos los primarios. Si está expandido, mostramos todos.
    final displayFilters = _showAllCategories 
        ? [...primaryFilters, ...allCategories]
        : primaryFilters;

    List<Service> filteredServices;
    if (_selectedFilter == 'Todos') {
      filteredServices = widget.services;
    } else if (_selectedFilter == 'Destacados') {
      filteredServices = widget.services.where((s) => s.isFeatured).toList();
    } else if (_selectedFilter == 'Guardados') {
      filteredServices = widget.selectedServices;
    } else {
      filteredServices = widget.services
          .where((s) => s.category == _selectedFilter)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. SELECCIONA TU SERVICIO',
          style: TextStyle(
            color: context.primaryGold,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ...displayFilters.map((cat) => _buildFilterChip(context, cat)),
              if (!_showAllCategories && allCategories.isNotEmpty)
                _buildExpandButton(context),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (filteredServices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                _selectedFilter == 'Guardados'
                    ? 'Selecciona servicios para guardarlos aquí'
                    : 'No hay servicios en esta categoría',
                style: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          )
        else
          ...filteredServices.map((service) => _buildServiceCard(context, service)),
        const SizedBox(height: 160),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String cat) {
    final isSelected = _selectedFilter == cat;
    final isSpecial = cat == 'Destacados' || cat == 'Guardados';
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? context.primaryGold
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? context.primaryGold
                  : isSpecial
                      ? context.primaryGold.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cat == 'Destacados') ...[
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: isSelected ? context.backgroundBlack : context.primaryGold,
                ),
                const SizedBox(width: 4),
              ],
              if (cat == 'Guardados') ...[
                Icon(
                  Icons.bookmark_rounded,
                  size: 14,
                  color: isSelected ? context.backgroundBlack : context.primaryGold,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                cat,
                style: TextStyle(
                  color: isSelected
                      ? context.backgroundBlack
                      : isSpecial
                          ? context.primaryGold
                          : Colors.white70,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showAllCategories = true),
      child: Container(
        padding: const EdgeInsets.all(8),
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
          Expanded(
            child: Row(
              children: [
                Icon(Icons.content_cut_rounded,
                    color: context.primaryGold, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Servicios Seleccionados',
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      Text(
                        '${widget.selectedServices.length} servicio(s) · S/ ${widget.selectedServices.fold(0.0, (s, e) => s + e.price).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: context.primaryGold, size: 20),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, Service service) {
    final isSelected = widget.selectedServices.any((s) => s.id == service.id);
    return GestureDetector(
      onTap: () => widget.onToggle(service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryGold.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.primaryGold
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1,
          ),
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
                        Icon(Icons.star_rounded,
                            size: 14, color: context.primaryGold),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          service.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${service.durationInMinutes} min · ${service.category}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'S/ ${service.price.toStringAsFixed(0)}',
              style: TextStyle(
                color: context.primaryGold,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? context.primaryGold : Colors.white10,
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
