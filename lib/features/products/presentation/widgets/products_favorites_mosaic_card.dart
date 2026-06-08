import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';

/// Tarjeta mosaico de favoritos (estilo "Destacados" de galería).
/// Foto + nombre + precio + botón quitar (corazón) + botón agregar al carrito.
class ProductsFavoritesMosaicCard extends StatelessWidget {
  const ProductsFavoritesMosaicCard({
    super.key,
    required this.product,
    required this.height,
    required this.isInCart,
    required this.onTap,
    required this.onRemove,
    required this.onAddToCart,
    this.isFavorite = true,
  });

  final Product product;
  final double height;
  final bool isInCart;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final bool isFavorite;

  static const Color _heartRed = Color(0xFFFF8A95);

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeImage(url: product.imageUrl, fit: BoxFit.cover),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
                  ),
                ),
              ),
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12, right: 56, bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                        height: 1.15,
                        shadows: const [Shadow(blurRadius: 3, color: Color(0xAA000000))],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/ ${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: gold,
                        letterSpacing: -0.2,
                        shadows: const [Shadow(blurRadius: 3, color: Color(0xAA000000))],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8, right: 8,
                child: PremiumPressable(
                  pressedScale: 0.82,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onRemove();
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.2),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 16,
                      color: isFavorite ? _heartRed : Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8, right: 8,
                child: PremiumPressable(
                  pressedScale: 0.82,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onAddToCart();
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isInCart ? gold : Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: gold.withValues(alpha: isInCart ? 1 : 0.5), width: 1.2),
                    ),
                    child: Icon(
                      isInCart ? Icons.check_rounded : Icons.shopping_bag_outlined,
                      size: 15,
                      color: isInCart ? Colors.black : gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
