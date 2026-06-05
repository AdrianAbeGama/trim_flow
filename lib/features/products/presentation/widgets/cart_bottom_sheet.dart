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
import 'package:trim_flow/features/products/presentation/views/cart_view.dart';
import 'package:trim_flow/features/products/presentation/views/product_detail_view.dart';
import 'package:trim_flow/features/products/presentation/widgets/cart_list_row.dart';
import 'package:trim_flow/features/products/presentation/widgets/cart_summary_bar.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  static void show(BuildContext context) {
    final cartBloc = context.read<CartBloc>();
    final productBloc = context.read<ProductBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0B0B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cartBloc),
          BlocProvider.value(value: productBloc),
        ],
        child: const CartBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final isEmpty = state.items.isEmpty;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SheetHeader(count: state.totalItems),
              if (isEmpty)
                const _EmptyCart()
              else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Dismissible(
                        key: ValueKey('cart_sheet_dismiss_${item.product.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          HapticFeedback.mediumImpact();
                          context.read<CartBloc>().add(CartEvent.removeItem(item.product.id));
                        },
                        background: const CartDismissBackground(),
                        child: CartListRow(
                          key: ValueKey('cart_sheet_${item.product.id}'),
                          item: item,
                          onIncrement: () => context.read<CartBloc>().add(CartEvent.updateQuantity(item.product.id, 1)),
                          onDecrement: () => context.read<CartBloc>().add(CartEvent.updateQuantity(item.product.id, -1)),
                          onTap: () => _openDetail(context, item.product.id, state),
                        ),
                      ).animate().fadeIn(
                            delay: (40 * index).clamp(0, 400).ms,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ).slideY(begin: 0.08, end: 0, delay: (40 * index).clamp(0, 400).ms, duration: 450.ms, curve: Curves.easeOutCubic);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: CartSummaryBar(
                    total: state.totalPrice,
                    onCheckout: () {
                      final cartBloc = context.read<CartBloc>();
                      final productBloc = context.read<ProductBloc>();
                      Navigator.pop(context);
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
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, String productId, CartState state) {
    final item = state.items.firstWhere((it) => it.product.id == productId);
    final pb = context.read<ProductBloc>();
    final cb = context.read<CartBloc>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: pb),
            BlocProvider.value(value: cb),
          ],
          child: ProductDetailView(product: item.product),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Carrito',
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.4, height: 1.0),
                    ),
                    const SizedBox(width: 9),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        count == 0 ? '' : '· ${count == 1 ? "1 producto" : "$count productos"}',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: gold, letterSpacing: -0.2),
                      ),
                    ),
                  ],
                ),
              ),
              PremiumPressable(
                pressedScale: 0.85,
                onTap: () {
                  final cartBloc = context.read<CartBloc>();
                  final productBloc = context.read<ProductBloc>();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: cartBloc),
                          BlocProvider.value(value: productBloc),
                        ],
                        child: const CartView(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Icon(Icons.fullscreen_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
                ),
              ),
            ],
          ),
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
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: gold.withValues(alpha: 0.75), size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            'Tu carrito está vacío',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          Text(
            'Agrega productos para verlos aquí.',
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}
