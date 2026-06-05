import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/cart_item.dart';

/// Fila de ítem de carrito — estilo minimal editorial (sin caja).
class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    this.onTap,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final lineTotal = item.product.price * item.quantity;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SafeImage(url: item.product.imageUrl, width: 66, height: 66, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.product.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Text(
                    'S/ ${lineTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      color: gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  _StepBtn(icon: Icons.remove_rounded, onTap: onDecrement),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                  _StepBtn(icon: Icons.add_rounded, onTap: onIncrement, accent: gold),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return row;
    return PremiumPressable(pressedScale: 0.99, onTap: onTap, child: row);
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap, this.accent});

  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final isAccent = accent != null;
    return PremiumPressable(
      pressedScale: 0.82,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAccent ? accent!.withValues(alpha: 0.12) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isAccent ? accent!.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: isAccent ? accent : Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
