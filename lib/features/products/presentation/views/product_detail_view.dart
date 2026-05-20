// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
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

class ProductDetailView extends StatelessWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Encontrar el ítem de inventario vinculado con conversión segura de tipo
        final inventoryItem = state.inventoryItems
            .where((i) => i.id.toString() == product.inventoryItemId?.toString())
            .firstOrNull;
        final isOutOfStock = inventoryItem != null && inventoryItem.quantity <= 0;

        return Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildStockStatus(context, inventoryItem),
                      const SizedBox(height: 20),
                      _buildDescription(context),
                      const SizedBox(height: 32),
                      _buildActionButtons(context, isOutOfStock),
                      const SizedBox(height: 48),
                      _buildRecommendedSection(context),
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
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text(
                          product.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                      body: Center(
                        child: InteractiveViewer(
                          clipBehavior: Clip.none,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: SafeImage(
                            url: product.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: SafeImage(
                url: product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Degradado superior para legibilidad de botones flotantes
            Positioned(
              top: 0, left: 0, right: 0,
              height: 120,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Botones interactivos flotantes verticales en la esquina superior derecha
            Positioned(
              top: 60,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFloatingHeartButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHeartButton(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (prev, curr) {
        final prevProd = prev.allProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
        final currProd = curr.allProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
        return prevProd.isFavorite != currProd.isFavorite;
      },
      builder: (context, state) {
        final currentProd = state.allProducts.firstWhere((p) => p.id == product.id, orElse: () => product);
        return GestureDetector(
          onTap: () {
            context.read<ProductBloc>().add(ProductEvent.toggleFavorite(product.id));
          },
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black38,
                child: Icon(
                  currentProd.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: currentProd.isFavorite ? Colors.redAccent : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
        ),
        Text('S/ ${product.price.toStringAsFixed(2)}', style: TextStyle(color: context.primaryGold, fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildStockStatus(BuildContext context, InventoryItem? item) {
    if (item == null) return const SizedBox.shrink();
    final isLow = item.quantity > 0 && item.quantity < 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: item.quantity <= 0 ? Colors.red.withOpacity(0.1) : context.primaryGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        item.quantity <= 0 ? 'AGOTADO' : 'STOCK DISPONIBLE: ${item.quantity}',
        style: TextStyle(
          color: item.quantity <= 0 ? Colors.redAccent : (isLow ? Colors.orangeAccent : context.primaryGold),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DESCRIPCIÓN', style: TextStyle(color: context.primaryGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 12),
        Text(product.description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.6)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isOutOfStock) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final isInCart = cartState.items.any((i) => i.product.id == product.id);
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isOutOfStock ? null : () => context.read<CartBloc>().add(CartEvent.addItem(product)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isOutOfStock ? Colors.white24 : (isInCart ? context.primaryGold : Colors.white),
                  side: BorderSide(color: isOutOfStock ? Colors.white10 : (isInCart ? context.primaryGold : Colors.white24)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isOutOfStock ? 'AGOTADO' : (isInCart ? 'EN EL CARRITO' : 'AÑADIR AL CARRITO'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : () => _buyNow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock ? Colors.white10 : context.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(isOutOfStock ? 'AGOTADO' : 'COMPRAR AHORA', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _buyNow(BuildContext context) {
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

  Widget _buildRecommendedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAMBIÉN TE PUEDE GUSTAR', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 24),
      ],
    );
  }
}
