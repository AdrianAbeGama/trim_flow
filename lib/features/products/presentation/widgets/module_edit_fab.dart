import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class ModuleEditFab extends StatelessWidget {
  final bool isEditing;
  final String label;
  final VoidCallback onToggle;

  const ModuleEditFab({
    super.key,
    required this.isEditing,
    required this.label,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 24,
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isEditing ? Colors.white : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.primaryGold.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
                color: isEditing ? Colors.black : context.primaryGold,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                (isEditing ? 'LISTO' : label).toUpperCase(),
                style: TextStyle(
                  color: isEditing ? Colors.black : context.primaryGold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
