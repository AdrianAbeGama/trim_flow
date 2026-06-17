import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/admin/presentation/permissions/permissions_store.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_state.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/widgets/cart_bottom_sheet.dart';
import 'package:trim_flow/features/products/presentation/widgets/favorites_bottom_sheet.dart';

class ProductsHeader extends StatelessWidget {
  const ProductsHeader({super.key, required this.isBarber});

  final bool isBarber;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final favCount = state.allProducts.where((p) => p.isFavorite).length;
                return Row(
                  children: [
                    Expanded(
                      child: state.isEditing
                          ? const PremiumEditingBadge(label: 'EDICIÓN ACTIVA')
                          : const PremiumPill(
                              icon: Icons.shopping_bag_outlined,
                              label: 'TIENDA · PRODUCTOS',
                            ),
                    ),
                    const SizedBox(width: 8),
                    _FavoritesIconButton(
                      count: favCount,
                      onTap: () => FavoritesBottomSheet.show(context),
                    ),
                    const SizedBox(width: 8),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, cart) => _CartIconButton(
                        count: cart.totalItems,
                        onTap: () => CartBottomSheet.show(context),
                      ),
                    ),
                    if (isBarber)
                      ValueListenableBuilder<PreviewRole?>(
                        valueListenable: PermissionsStore.instance.preview,
                        builder: (context, _, _) {
                          if (!PermissionsStore.instance
                              .can('products_manage')) {
                            return const SizedBox.shrink();
                          }
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 8),
                              _EditToggleButton(
                                isEditing: state.isEditing,
                                onTap: () => context
                                    .read<ProductBloc>()
                                    .add(const ProductEvent.toggleEditMode()),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(
                      begin: -0.4, end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            ),
            const SizedBox(height: 22),
            Text(
              'Nuestros',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.55),
                letterSpacing: -0.2,
              ),
            )
                .animate()
                .fadeIn(delay: 120.ms, duration: 500.ms)
                .slideY(
                  begin: 0.3, end: 0,
                  delay: 120.ms, duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 4),
            Text(
              'Productos',
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
                .slideY(
                  begin: 0.2, end: 0,
                  delay: 200.ms, duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(width: 16, height: 1.5, color: context.primaryGold),
                const SizedBox(width: 8),
                Text(
                  'Nuestro catálogo premium',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

/// Botón circular con badge de conteo (favoritos / carrito).
class _CountIconButton extends StatelessWidget {
  const _CountIconButton({
    required this.icon,
    required this.count,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      pressedScale: 0.88,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Icon(
              icon,
              size: 18,
              color: count > 0 ? activeColor : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -2, right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                constraints: const BoxConstraints(minWidth: 16),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF0A0A0A), width: 1.5),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoritesIconButton extends StatelessWidget {
  const _FavoritesIconButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CountIconButton(
      icon: Icons.favorite_rounded,
      count: count,
      activeColor: const Color(0xFFFF8A95),
      onTap: onTap,
    );
  }
}

class _CartIconButton extends StatelessWidget {
  const _CartIconButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CountIconButton(
      icon: Icons.shopping_cart_rounded,
      count: count,
      activeColor: context.primaryGold,
      onTap: onTap,
    );
  }
}

class _EditToggleButton extends StatelessWidget {
  const _EditToggleButton({required this.isEditing, required this.onTap});
  final bool isEditing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = isEditing;
    final color = active ? const Color(0xFFFF8A95) : context.primaryGold;
    return PremiumPressable(
      pressedScale: 0.88,
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : const Color(0xFF161616),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          active ? Icons.check_rounded : Icons.edit_rounded,
          size: 17,
          color: active ? color : Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
