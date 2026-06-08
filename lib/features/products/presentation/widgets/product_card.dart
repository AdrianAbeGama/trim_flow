import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/views/product_form_view.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isInCart;
  final double? imageAspectRatio;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.isInCart = false,
    this.imageAspectRatio,
    required this.onFavorite,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) =>
          previous.expandedProductIds.contains(product.id) != current.expandedProductIds.contains(product.id) ||
          previous.isEditing != current.isEditing,
      builder: (context, state) {
        final isExpanded = state.expandedProductIds.contains(product.id);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isInCart
                  ? gold.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.05),
              width: isInCart ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              if (isInCart)
                BoxShadow(
                  color: gold.withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(19))
                    : BorderRadius.circular(19),
                child: AspectRatio(
                  aspectRatio: imageAspectRatio ?? 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap();
                        },
                        child: SafeImage(url: product.imageUrl, fit: BoxFit.cover),
                      ),
                      IgnorePointer(
                        ignoring: true,
                        child: AnimatedOpacity(
                          opacity: isExpanded ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0x8C000000),
                                  Color(0xEB000000),
                                ],
                                stops: [0.5, 0.82, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12, right: 50, bottom: 12,
                        child: IgnorePointer(
                          ignoring: true,
                          child: AnimatedOpacity(
                            opacity: isExpanded ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product.name.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                    height: 1.15,
                                    shadows: const [
                                      Shadow(blurRadius: 3, color: Color(0xAA000000)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _PricePill(price: product.price, gold: gold),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: _FavHeartButton(
                          isFav: product.isFavorite,
                          onTap: onFavorite,
                        ),
                      ),
                      if (state.isEditing)
                        Positioned(
                          top: 8, left: 8,
                          child: Row(
                            children: [
                              PremiumEditCircleButton(
                                onTap: () {
                                  final pb = context.read<ProductBloc>();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(value: pb, child: ProductFormView(product: product)),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _DeleteCircleButton(
                                onTap: () async {
                                  final pb = context.read<ProductBloc>();
                                  final ok = await PremiumConfirmDelete.show(
                                    context,
                                    title: 'Eliminar producto',
                                    message: '¿Seguro que quieres eliminar "${product.name}"? Esta acción no se puede deshacer.',
                                  );
                                  if (ok) pb.add(ProductEvent.deleteProduct(product.id));
                                },
                              ),
                            ],
                          ),
                        ),
                      Positioned(
                        bottom: 8, right: 8,
                        child: _ExpandChevron(
                          isExpanded: isExpanded,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.read<ProductBloc>().add(ProductEvent.toggleExpansion(product.id));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: _ExpandedPanel(
                  product: product,
                  gold: gold,
                  isInCart: isInCart,
                  onAddToCart: onAddToCart,
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 280),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  final Product product;
  final Color gold;
  final bool isInCart;
  final VoidCallback onAddToCart;

  const _ExpandedPanel({
    required this.product,
    required this.gold,
    required this.isInCart,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = product.description.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 1.5, color: gold),
          const SizedBox(height: 10),
          Text(
            product.name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
              height: 1.1,
            ),
          ),
          if (hasDescription) ...[
            const SizedBox(height: 6),
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'S/ ${product.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CartIconButton(
                isInCart: isInCart,
                gold: gold,
                onAddToCart: onAddToCart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartIconButton extends StatelessWidget {
  final bool isInCart;
  final Color gold;
  final VoidCallback onAddToCart;

  const _CartIconButton({
    required this.isInCart,
    required this.gold,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: () {
        HapticFeedback.lightImpact();
        onAddToCart();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isInCart ? gold : gold.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: gold.withValues(alpha: isInCart ? 1 : 0.4)),
          boxShadow: isInCart
              ? [BoxShadow(color: gold.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
              : null,
        ),
        child: Icon(
          isInCart ? Icons.check_rounded : Icons.shopping_bag_outlined,
          color: isInCart ? Colors.black : gold,
          size: 16,
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final double price;
  final Color gold;

  const _PricePill({required this.price, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: gold.withValues(alpha: 0.30)),
      ),
      child: Text(
        'S/ ${price.toStringAsFixed(2)}',
        style: GoogleFonts.inter(
          color: gold,
          fontSize: 11.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _FavHeartButton extends StatelessWidget {
  final bool isFav;
  final VoidCallback onTap;

  const _FavHeartButton({required this.isFav, required this.onTap});

  static const Color _heartRed = Color(0xFFFF8A95);

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.82,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: isFav ? 0.65 : 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: isFav ? 0.45 : 0.35),
            width: 1.2,
          ),
        ),
        child: Icon(
          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: isFav ? _heartRed : Colors.white,
        ),
      ),
    );
  }
}

class _DeleteCircleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteCircleButton({required this.onTap});

  static const Color _danger = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.82,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          border: Border.all(color: _danger.withValues(alpha: 0.8), width: 1.2),
          boxShadow: [BoxShadow(color: _danger.withValues(alpha: 0.25), blurRadius: 8, spreadRadius: 1)],
        ),
        child: const Icon(Icons.close_rounded, size: 16, color: _danger),
      ),
    );
  }
}

class _ExpandChevron extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandChevron({required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.85,
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: gold.withValues(alpha: 0.4), width: 1),
        ),
        child: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: Icon(Icons.keyboard_arrow_down_rounded, color: gold, size: 18),
        ),
      ),
    );
  }
}
