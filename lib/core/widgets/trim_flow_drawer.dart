import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class TrimFlowDrawer extends StatelessWidget {
  const TrimFlowDrawer({
    super.key,
    required this.onTabSelected,
    required this.currentIndex,
  });

  final Function(int) onTabSelected;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.backgroundBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.content_cut_rounded,
                    color: context.primaryGold,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TRIMFLOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 2,
                    color: context.primaryGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _DrawerItem(
              icon: Icons.home_filled,
              label: 'INICIO',
              isSelected: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _DrawerItem(
              icon: Icons.grid_view_rounded,
              label: 'GALERÍA',
              isSelected: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _DrawerItem(
              icon: Icons.content_cut_rounded,
              label: 'RESERVAS',
              isSelected: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
            _DrawerItem(
              icon: Icons.shopping_bag_rounded,
              label: 'PRODUCTOS',
              isSelected: currentIndex == 3,
              onTap: () => onTabSelected(3),
            ),
            _DrawerItem(
              icon: Icons.person_rounded,
              label: 'PERFIL',
              isSelected: currentIndex == 4,
              onTap: () => onTabSelected(4),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.1),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Usamos el contexto para obtener los colores del tema
    final primaryGold = context.primaryGold;

    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      leading: Icon(
        icon,
        color: isSelected ? primaryGold : Colors.white38,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white38,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
