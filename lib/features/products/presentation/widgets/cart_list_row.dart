import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/cart_item.dart';

/// Fila del carrito: imagen + título + precio + contador. Sin recuadro de fondo.
/// El borrado se hace deslizando (Dismissible en la lista).
class CartListRow extends StatelessWidget {
  const CartListRow({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onTap,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final product = item.product;

    return PremiumPressable(
      pressedScale: 0.99,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SafeImage(url: product.imageUrl, width: 78, height: 78, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: -0.3, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'S/ ${(product.price * item.quantity).toStringAsFixed(2)}',
                        style: GoogleFonts.inter(color: gold, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                      ),
                      const Spacer(),
                      _QtyStepper(
                        quantity: item.quantity,
                        accent: gold,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fondo que aparece al deslizar una fila del carrito para eliminar
/// (etiqueta "ELIMINAR" + papelera chica, como favoritos).
class CartDismissBackground extends StatelessWidget {
  const CartDismissBackground({super.key});

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFCF6679);
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ELIMINAR',
            style: GoogleFonts.inter(color: danger, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: danger.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: danger, size: 16),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.accent,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final Color accent;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove_rounded, accent: accent, enabled: canDecrement, onTap: onDecrement),
        SizedBox(
          width: 30,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ),
        _StepButton(icon: Icons.add_rounded, accent: accent, enabled: true, onTap: onIncrement),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.accent, required this.enabled, required this.onTap});

  final IconData icon;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? accent : Colors.white.withValues(alpha: 0.2);
    return PremiumPressable(
      pressedScale: enabled ? 0.85 : 1.0,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled ? accent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
          shape: BoxShape.circle,
          border: Border.all(color: enabled ? accent.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
