import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/rotating_products_banner.dart';
import 'package:trim_flow/features/products/presentation/widgets/product_card.dart';
import 'package:trim_flow/features/products/presentation/widgets/product_search_bar.dart';
import 'package:trim_flow/features/products/presentation/widgets/category_filter_bar.dart';
import 'package:trim_flow/features/products/presentation/views/product_detail_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_admin_dashboard_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_form_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/cart_bottom_sheet.dart';
import 'package:trim_flow/features/products/presentation/widgets/favorites_bottom_sheet.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const ProductEvent.started());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return BlocBuilder<AppModeBloc, AppModeState>(
          builder: (context, modeState) {
            return Scaffold(
              backgroundColor: context.backgroundBlack,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(context),
                  SliverToBoxAdapter(
                    child: _buildQuickActions(context, state, modeState),
                  ),
                  const SliverToBoxAdapter(child: RotatingProductsBanner()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ProductSearchBar(
                        onChanged: (query) => context.read<ProductBloc>().add(ProductEvent.searchChanged(query)),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: CategoryFilterBar(
                      categories: state.categories,
                      selectedId: state.selectedCategoryId,
                      onSelected: (id) => context.read<ProductBloc>().add(ProductEvent.categorySelected(id)),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (state.isLoading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))))
                  else if (state.products.isEmpty)
                    const SliverToBoxAdapter(child: SizedBox.shrink())
                  else
                    _buildMasonryGrid(context, state),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, ProductState productState, AppModeState modeState) {
    if (modeState.mode != AppMode.barber || !productState.isEditing) {
      return const SizedBox.shrink();
    }
    final pb = context.read<ProductBloc>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: _quickActionButton(
              context,
              label: 'CREAR PRODUCTO',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(value: pb, child: const ProductFormView()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _quickActionButton(
              context,
              label: 'PANEL ADMIN',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(value: pb, child: const ProductAdminDashboardView()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(BuildContext context, {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: context.primaryGold.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF5F5DC),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMasonryGrid(BuildContext context, ProductState state) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        const aspectRatios = <double>[0.65, 0.85, 0.7, 0.9, 0.75, 0.8, 0.68, 0.88];

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final isInCart = cartState.items.any((item) => item.product.id == product.id);
              final ratio = aspectRatios[index % aspectRatios.length];
              
              return ProductCard(
                key: ValueKey('grid_${product.id}'),
                product: product,
                isInCart: isInCart,
                imageAspectRatio: ratio,
                onFavorite: () => context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id)),
                onAddToCart: () => context.read<CartBloc>().add(CartEvent.addItem(product)),
                onTap: () => _openProductDetail(context, product),
              );
            },
          ),
        );
      },
    );
  }

  void _openProductDetail(BuildContext context, Product product) {
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
          child: ProductDetailView(product: product),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final modeState = context.read<AppModeBloc>().state;
    final isBarber = modeState.mode == AppMode.barber;

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_rounded, color: context.primaryGold, size: 28),
                  if (isBarber) ...[
                    const SizedBox(width: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: BarberHomePage.showBarberBadge,
                      builder: (context, showBadge, child) {
                        if (!showBadge) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.primaryGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MODO BARBERO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const Spacer(),
                  _buildActions(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'PRODUCTOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  if (isBarber) ...[
                    const SizedBox(width: 12),
                    BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () => context.read<ProductBloc>().add(const ProductEvent.toggleEditMode()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: state.isEditing ? Colors.white : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.primaryGold.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              state.isEditing ? 'LISTO' : 'EDITAR PRODUCTOS',
                              style: TextStyle(
                                color: state.isEditing ? Colors.black : context.primaryGold,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Container(width: 40, height: 3, color: context.primaryGold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final favCount = state.allProducts.where((p) => p.isFavorite).length;
        return Row(
          children: [
            _actionIcon(Icons.favorite_border_rounded, favCount, () => FavoritesBottomSheet.show(context)),
            const SizedBox(width: 12),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, cart) => _actionIcon(
                Icons.shopping_cart_outlined,
                cart.totalItems,
                () => CartBottomSheet.show(context),
                isGold: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _actionIcon(IconData icon, int count, VoidCallback onTap, {bool isGold = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isGold ? const Color(0xFFD4AF37) : const Color(0xFFFF4D4D),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isGold ? Colors.black : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }


}
