import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/features/barber/agenda/presentation/bloc/agenda_state.dart';

class AgendaViewToggle extends StatelessWidget {
  const AgendaViewToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final AgendaViewMode mode;
  final ValueChanged<AgendaViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            label: 'LISTA',
            iconBuilder: (color, size) => FaIcon(FontAwesomeIcons.listUl, color: color, size: size),
            isSelected: mode == AgendaViewMode.list,
            onTap: () => onChanged(AgendaViewMode.list),
          ),
          const SizedBox(width: 4),
          _Pill(
            label: 'MATRIZ',
            iconBuilder: (color, size) => FaIcon(FontAwesomeIcons.tableCellsLarge, color: color, size: size),
            isSelected: mode == AgendaViewMode.matrix,
            onTap: () => onChanged(AgendaViewMode.matrix),
          ),
        ],
      ),
    );
  }
}

typedef _PillIconBuilder = Widget Function(Color color, double size);

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.iconBuilder,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final _PillIconBuilder iconBuilder;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconBuilder(color, 12),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
