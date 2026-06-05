import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/views/checkout_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_detail_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/cart_list_row.dart';
import 'package:trim_flow/features/products/presentation/widgets/cart_summary_bar.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final isEmpty = state.items.isEmpty;
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    CartPremiumHeader(count: state.totalItems, showBack: true),
                    if (isEmpty)
                      const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = state.items[index];
                              return Dismissible(
                                key: ValueKey('cart_dismiss_${item.product.id}'),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  HapticFeedback.mediumImpact();
                                  context.read<CartBloc>().add(CartEvent.removeItem(item.product.id));
                                },
                                background: const CartDismissBackground(),
                                child: CartListRow(
                                  key: ValueKey('cart_${item.product.id}'),
                                  item: item,
                                  onIncrement: () => context.read<CartBloc>().add(CartEvent.updateQuantity(item.product.id, 1)),
                                  onDecrement: () => context.read<CartBloc>().add(CartEvent.updateQuantity(item.product.id, -1)),
                                  onTap: () => _openDetail(context, item.product.id, state),
                                ),
                              ).animate().fadeIn(
                                    delay: (40 * index).clamp(0, 500).ms,
                                    duration: 450.ms,
                                    curve: Curves.easeOutCubic,
                                  ).slideY(begin: 0.08, end: 0, delay: (40 * index).clamp(0, 500).ms, duration: 500.ms, curve: Curves.easeOutCubic);
                            },
                            childCount: state.items.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
              if (!isEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: CartSummaryBar(
                      total: state.totalPrice,
                      onCheckout: () {
                        final cartBloc = context.read<CartBloc>();
                        final productBloc = context.read<ProductBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: cartBloc),
                                BlocProvider.value(value: productBloc),
                              ],
                              child: const CheckoutView(),
                            ),
                          ),
                        );
                      },
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.4, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, String productId, CartState state) {
    final item = state.items.firstWhere((it) => it.product.id == productId);
    final cartBloc = context.read<CartBloc>();
    final productBloc = context.read<ProductBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: cartBloc),
          ],
          child: ProductDetailView(product: item.product),
        ),
      ),
    );
  }
}

/// Header premium del carrito — mismo patrón que Favoritos/Destacados.
class CartPremiumHeader extends StatelessWidget {
  const CartPremiumHeader({super.key, required this.count, this.showBack = true});

  final int count;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: CartHeaderContent(count: count, showBack: showBack),
        ),
      ),
    );
  }
}

/// Contenido del header del carrito (título "Carrito" con el contador al lado).
class CartHeaderContent extends StatelessWidget {
  const CartHeaderContent({super.key, required this.count, this.showBack = true});

  final int count;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBack)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: PremiumBackButton(onTap: () => Navigator.pop(context)),
          )
              .animate().fadeIn(duration: 400.ms).slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Carrito',
              style: GoogleFonts.inter(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.8, height: 1.0),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                count == 0 ? '' : '· ${count == 1 ? "1 producto" : "$count productos"}',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: gold, letterSpacing: -0.2),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 120.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, delay: 120.ms, duration: 600.ms, curve: Curves.easeOutCubic),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(width: 16, height: 1.5, color: gold),
            const SizedBox(width: 8),
            Text(
              count == 0 ? 'Tu carrito está vacío' : 'Listo para pagar cuando quieras',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), letterSpacing: -0.1),
            ),
          ],
        ).animate().fadeIn(delay: 280.ms, duration: 500.ms),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(color: gold.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.shopping_bag_outlined, color: gold.withValues(alpha: 0.75), size: 42),
            ),
            const SizedBox(height: 22),
            Text(
              'Tu carrito está vacío',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4),
            ),
            const SizedBox(height: 6),
            Text(
              'Explora el catálogo y agrega tus productos.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45), height: 1.5),
            ),
            const SizedBox(height: 24),
            PremiumPressable(
              pressedScale: 0.96,
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'EXPLORAR PRODUCTOS',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
