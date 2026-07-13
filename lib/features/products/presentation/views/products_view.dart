import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/app_toast.dart';
import 'package:trim_flow/core/widgets/premium/premium_quick_action_card.dart';
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:core/core.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/features/products/products_config.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/rotating_products_banner.dart';
import 'package:trim_flow/features/products/presentation/widgets/product_card.dart';
import 'package:trim_flow/features/products/presentation/widgets/product_search_bar.dart';
import 'package:trim_flow/features/products/presentation/widgets/category_filter_bar.dart';
import 'package:trim_flow/features/products/presentation/widgets/products_header.dart';
import 'package:trim_flow/features/products/presentation/widgets/products_empty_state.dart';
import 'package:trim_flow/features/products/presentation/views/product_detail_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_admin_dashboard_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_form_view.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

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
    HomePage.requestedProductId.addListener(_handleRequestedProduct);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRequestedProduct());
  }

  @override
  void dispose() {
    HomePage.requestedProductId.removeListener(_handleRequestedProduct);
    super.dispose();
  }

  void _handleRequestedProduct() {
    final requested = HomePage.requestedProductId.value;
    if (requested == null || !mounted) return;
    HomePage.requestedProductId.value = null;
    AppToast.info(context, 'Buscando', message: requested);
    context.read<ProductBloc>().add(ProductEvent.searchChanged(requested));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return BlocBuilder<AppModeBloc, AppModeState>(
          builder: (context, modeState) {
            return Scaffold(
              backgroundColor: const Color(0xFF0A0A0A),
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ProductsHeader(isBarber: modeState.mode == AppMode.barber),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickActions(context, state, modeState),
                  ),
                  if (kProductPurchaseEnabled)
                    const SliverToBoxAdapter(child: RotatingProductsBanner())
                  else
                    const SliverToBoxAdapter(child: _BrowseOnlyHint()),
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
                    SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: context.primaryGold)))
                  else if (state.products.isEmpty)
                    const SliverToBoxAdapter(child: ProductsEmptyState())
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
    if (modeState.mode != AppMode.barber ||
        !productState.isEditing ||
        !PermissionsStore.instance.can('products_manage')) {
      return const SizedBox.shrink();
    }
    final pb = context.read<ProductBloc>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: PremiumQuickActionCard(
              icon: Icons.add_box_rounded,
              label: 'CREAR\nPRODUCTO',
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
          const SizedBox(width: 10),
          Expanded(
            child: PremiumQuickActionCard(
              icon: Icons.tune_rounded,
              label: 'PANEL\nADMIN',
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
              final delay = (40 * (index % 6)).ms;

              return ProductCard(
                key: ValueKey('grid_${product.id}'),
                product: product,
                isInCart: isInCart,
                imageAspectRatio: ratio,
                onFavorite: () => context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id)),
                onAddToCart: kProductPurchaseEnabled
                    ? () => context.read<CartBloc>().add(CartEvent.addItem(product))
                    : () => AppToast.info(context, 'Al reservar',
                        message: 'Agrega los productos al reservar tu cita.'),
                onTap: () => _openProductDetail(context, product),
              )
                  .animate()
                  .fadeIn(delay: delay, duration: 350.ms)
                  .slideY(
                    begin: 0.08, end: 0,
                    delay: delay, duration: 350.ms,
                    curve: Curves.easeOutCubic,
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
}

class _BrowseOnlyHint extends StatelessWidget {
  const _BrowseOnlyHint();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(Icons.content_cut_rounded, color: gold, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Explora los productos y agrégalos al reservar tu cita.',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
