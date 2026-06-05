import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/domain/models/inventory_item.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/products/presentation/views/checkout_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/products_favorites_mosaic_card.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  static const Color _heartRed = Color(0xFFFF8A95);
  static const List<double> _recHeights = [200, 240, 220, 260, 210, 250];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final inventoryItem = state.inventoryItems
            .where((i) => i.id.toString() == product.inventoryItemId?.toString())
            .firstOrNull;
        final isOutOfStock = inventoryItem != null && inventoryItem.quantity <= 0;
        final recommended = state.allProducts
            .where((p) => p.id != product.id && p.categoryId == product.categoryId)
            .take(6)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context)
                          .animate()
                          .fadeIn(duration: 450.ms)
                          .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                      const SizedBox(height: 18),
                      _buildStockStatus(context, inventoryItem)
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 450.ms),
                      const SizedBox(height: 26),
                      _buildDescription(context)
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                      const SizedBox(height: 34),
                      _buildActionButtons(context, isOutOfStock)
                          .animate()
                          .fadeIn(delay: 280.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 280.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                      if (recommended.isNotEmpty) ...[
                        const SizedBox(height: 44),
                        _buildRecommendedSection(context, recommended),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 440,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0A0A0A),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _openFullscreen(context),
              child: Hero(
                tag: 'product_image_${product.id}',
                child: SafeImage(url: product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const Positioned(
              top: 0, left: 0, right: 0, height: 140,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0, bottom: 0, height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, const Color(0xFF0A0A0A)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: PremiumBackButton(onTap: () => Navigator.pop(context)),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: _buildFloatingHeartButton(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    clipBehavior: Clip.none,
                    minScale: 0.5,
                    maxScale: 4,
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: SafeImage(url: product.imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Positioned(
                  top: 8, left: 16,
                  child: PremiumBackButton(onTap: () => Navigator.pop(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeartButton(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (prev, curr) {
        final p = prev.allProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
        final c = curr.allProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
        return p.isFavorite != c.isFavorite;
      },
      builder: (context, state) {
        final current = state.allProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
        final fav = current.isFavorite;
        return PremiumPressable(
          pressedScale: 0.85,
          onTap: () {
            HapticFeedback.mediumImpact();
            context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id));
          },
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 40, height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Icon(
                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: fav ? _heartRed : Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.inter(color: gold, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'IGV incluido',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockStatus(BuildContext context, InventoryItem? item) {
    if (item == null) return const SizedBox.shrink();
    final gold = context.primaryGold;
    final out = item.quantity <= 0;
    final low = item.quantity > 0 && item.quantity < 5;
    final color = out ? const Color(0xFFCF6679) : (low ? const Color(0xFFE0A458) : gold);
    final label = out
        ? 'AGOTADO'
        : (low ? 'ÚLTIMAS ${item.quantity} UNIDADES' : 'EN STOCK · ${item.quantity} DISPONIBLES');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.inter(color: color, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final gold = context.primaryGold;
    if (product.description.trim().isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 1.5, color: gold),
            const SizedBox(width: 8),
            Text(
              'DESCRIPCIÓN',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.description,
          style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, height: 1.65, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isOutOfStock) {
    final gold = context.primaryGold;
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final isInCart = cartState.items.any((i) => i.product.id == product.id);
        return Row(
          children: [
            Expanded(
              child: PremiumPressable(
                pressedScale: 0.97,
                onTap: isOutOfStock
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        context.read<CartBloc>().add(CartEvent.addItem(product));
                      },
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isInCart ? gold.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isOutOfStock
                          ? Colors.white.withValues(alpha: 0.06)
                          : (isInCart ? gold.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart ? Icons.check_rounded : Icons.shopping_bag_outlined,
                        size: 16,
                        color: isOutOfStock ? Colors.white24 : (isInCart ? gold : Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOutOfStock ? 'AGOTADO' : (isInCart ? 'EN EL CARRITO' : 'AÑADIR'),
                        style: GoogleFonts.inter(
                          color: isOutOfStock ? Colors.white24 : (isInCart ? gold : Colors.white),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PremiumPressable(
                pressedScale: 0.97,
                onTap: isOutOfStock ? null : () => _buyNow(context),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isOutOfStock ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F3EC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isOutOfStock ? 'NO DISPONIBLE' : 'COMPRAR AHORA',
                    style: GoogleFonts.inter(
                      color: isOutOfStock ? Colors.white24 : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _buyNow(BuildContext context) {
    HapticFeedback.mediumImpact();
    final cb = context.read<CartBloc>();
    final pb = context.read<ProductBloc>();
    final isInCart = cb.state.items.any((item) => item.product.id == product.id);
    if (!isInCart) {
      cb.add(CartEvent.addItem(product));
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cb),
            BlocProvider.value(value: pb),
          ],
          child: const CheckoutView(),
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context, List<Product> recommended) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 16, height: 1.5, color: gold),
            const SizedBox(width: 8),
            Text(
              'TAMBIÉN TE PUEDE GUSTAR',
              style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
        ),
        const SizedBox(height: 18),
        MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: recommended.length,
          itemBuilder: (context, index) {
            final rec = recommended[index];
            return BlocBuilder<CartBloc, CartState>(
              buildWhen: (prev, curr) =>
                  prev.items.any((i) => i.product.id == rec.id) != curr.items.any((i) => i.product.id == rec.id),
              builder: (context, cartState) {
                final isInCart = cartState.items.any((i) => i.product.id == rec.id);
                return ProductsFavoritesMosaicCard(
                  product: rec,
                  height: _recHeights[index % _recHeights.length],
                  isInCart: isInCart,
                  isFavorite: rec.isFavorite,
                  onTap: () => _openRecommended(context, rec),
                  onRemove: () => context.read<ProductBloc>().add(ProductEvent.toggleFavorite(rec.id)),
                  onAddToCart: () => context.read<CartBloc>().add(CartEvent.addItem(rec)),
                ).animate().fadeIn(
                      delay: (60 * index).clamp(0, 400).ms,
                      duration: 450.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            );
          },
        ),
      ],
    );
  }

  void _openRecommended(BuildContext context, Product rec) {
    final pb = context.read<ProductBloc>();
    final cb = context.read<CartBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: pb),
            BlocProvider.value(value: cb),
          ],
          child: ProductDetailView(product: rec),
        ),
      ),
    );
  }
}
