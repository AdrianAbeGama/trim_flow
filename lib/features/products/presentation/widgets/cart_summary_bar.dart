import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';

/// Barra de resumen del carrito: total + CTA comprar (crema). Minimalista.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.total,
    required this.onCheckout,
    this.label = 'TOTAL',
  });

  final double total;
  final VoidCallback onCheckout;
  final String label;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.only(bottom: 14),
          color: Colors.white.withValues(alpha: 0.06),
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'S/ ${total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PremiumPressable(
              pressedScale: 0.97,
              onTap: () {
                HapticFeedback.mediumImpact();
                onCheckout();
              },
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 36),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'COMPRAR',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
