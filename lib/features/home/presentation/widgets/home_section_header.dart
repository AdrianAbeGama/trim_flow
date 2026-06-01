import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isEditing;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isEditing = false,
    this.onAdd,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 20), // Compacted padding
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, context.primaryGold],
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.primaryGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.primaryGold, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onAdd != null)
                    _buildActionButton(
                      context,
                      icon: Icons.add_rounded,
                      label: 'AÑADIR NUEVO',
                      onTap: onAdd!,
                      isPrimary: true,
                    ),
                  if (onAdd != null && onEdit != null) const SizedBox(width: 12),
                  if (onEdit != null)
                    _buildActionButton(
                      context,
                      icon: Icons.edit_rounded,
                      label: 'EDITAR SECCIÓN',
                      onTap: onEdit!,
                      isPrimary: false,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? context.primaryGold : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
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
