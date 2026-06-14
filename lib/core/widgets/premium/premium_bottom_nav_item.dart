import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Item de la barra inferior premium: pildora dorada deslizante con la etiqueta
/// visible solo en el tab activo (compartido entre cliente y barbero).
class PremiumBottomNavItem extends StatelessWidget {
  const PremiumBottomNavItem({
    super.key,
    this.icon,
    this.imageAsset,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = false,
  });

  final IconData? icon;
  final String? imageAsset;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final onAccent = premiumOnAccent(gold);
    final color = active ? onAccent : Colors.white.withValues(alpha: 0.45);

    Widget iconW = imageAsset != null
        ? Image.asset(imageAsset!, width: 22, height: 22, color: color, fit: BoxFit.contain)
        : Icon(icon, size: 23, color: color);

    if (badge) {
      iconW = Stack(
        clipBehavior: Clip.none,
        children: [
          iconW,
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF141414), width: 1.5),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: active
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
            : const EdgeInsets.all(9),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gold, Color.lerp(gold, Colors.black, 0.22)!],
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [BoxShadow(color: gold.withValues(alpha: 0.32), blurRadius: 12, spreadRadius: -4)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconW,
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          color: onAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
