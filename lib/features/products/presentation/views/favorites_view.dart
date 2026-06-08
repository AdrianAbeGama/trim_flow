import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/products/presentation/views/product_detail_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/products_favorites_mosaic_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  static const Color _accent = Color(0xFFFF8A95);
  static const List<double> _heights = [280, 220, 260, 240, 290, 230, 270, 210, 250];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final favorites = state.allProducts.where((p) => p.isFavorite).toList();
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _Header(count: favorites.length),
                if (favorites.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverMasonryGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childCount: favorites.length,
                          itemBuilder: (context, index) {
                            final product = favorites[index];
                            final isInCart = cartState.items.any((i) => i.product.id == product.id);
                            final h = _heights[index % _heights.length];
                            return ProductsFavoritesMosaicCard(
                              key: ValueKey('fav_${product.id}'),
                              product: product,
                              height: h,
                              isInCart: isInCart,
                              onTap: () => _openDetail(context, product),
                              onRemove: () => context
                                  .read<ProductBloc>()
                                  .add(ProductEvent.toggleFavorite(product.id)),
                              onAddToCart: () =>
                                  context.read<CartBloc>().add(CartEvent.addItem(product)),
                            ).animate().fadeIn(
                                  delay: (40 * index).clamp(0, 500).ms,
                                  duration: 450.ms,
                                  curve: Curves.easeOutCubic,
                                ).slideY(
                                  begin: 0.08,
                                  end: 0,
                                  delay: (40 * index).clamp(0, 500).ms,
                                  duration: 500.ms,
                                  curve: Curves.easeOutCubic,
                                );
                          },
                        ),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Product product) {
    final productBloc = context.read<ProductBloc>();
    final cartBloc = context.read<CartBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: cartBloc),
          ],
          child: ProductDetailView(product: product),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    const accent = FavoritesView._accent;
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PremiumBackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.55)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, color: accent, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          '$count ${count == 1 ? "FAVORITO" : "FAVORITOS"}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 22),
              Text(
                'Mis',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: -0.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 4),
              Text(
                'Favoritos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.6,
                  height: 1.05,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(width: 16, height: 1.5, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    count == 0 ? 'Aún no tienes productos guardados' : 'Lo que más te gusta',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    const accent = FavoritesView._accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: accent.withValues(alpha: 0.75),
              size: 44,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Sin favoritos aún',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca el corazón en cualquier producto para guardarlo aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
