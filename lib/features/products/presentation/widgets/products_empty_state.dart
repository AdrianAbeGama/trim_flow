import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class ProductsEmptyState extends StatelessWidget {
  const ProductsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.22)),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: gold.withValues(alpha: 0.9),
              size: 34,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          Text(
            'AÚN NO HAY PRODUCTOS',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.4,
            ),
          ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Pronto encontrarás aquí nuestro catálogo premium.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 220.ms, duration: 400.ms),
        ],
      ),
    );
  }
}
