import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class ProfileDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final dynamic icon;
  final VoidCallback? onTap;

  const ProfileDetailItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FaIcon(icon, color: context.primaryGold, size: 18),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
            Row(
              children: [
                Text(
                  value, 
                  style: TextStyle(
                    color: value == 'Pendiente' ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white38, 
                    fontSize: 15
                  )
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white10, size: 18),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
