import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/product_card.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/products/presentation/views/product_detail_view.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final favorites = state.allProducts.where((p) => p.isFavorite).toList();

              if (favorites.isEmpty) {
                return _buildEmptyState(context);
              }

              return BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        final isInCart = cartState.items.any((item) => item.product.id == product.id);
                        
                        return ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          isInCart: isInCart,
                          onFavorite: () => context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id)),
                          onAddToCart: () {
                            context.read<CartBloc>().add(CartEvent.addItem(product));
                          },
                          onTap: () {
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
                          },
                        );
                      },
                      childCount: favorites.length,
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.favorite_rounded, color: context.primaryGold, size: 28),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'MIS\nFAVORITOS',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 40, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(width: 40, height: 3, color: context.primaryGold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, color: Colors.white.withValues(alpha: 0.05), size: 80),
            const SizedBox(height: 24),
            const Text(
              'SIN FAVORITOS',
              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
