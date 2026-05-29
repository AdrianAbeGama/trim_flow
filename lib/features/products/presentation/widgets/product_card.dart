// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/products/domain/models/product.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/product_state.dart';
import 'package:trim_flow/features/products/presentation/views/product_form_view.dart';

class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (previous, current) =>
          previous.expandedProductIds.contains(widget.product.id) != current.expandedProductIds.contains(widget.product.id) ||
          previous.isEditing != current.isEditing,
      builder: (context, state) {
        final isExpanded = state.expandedProductIds.contains(widget.product.id);
        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isInCart
                    ? context.primaryGold.withOpacity(0.4)
                    : Colors.white.withOpacity(0.05),
                width: widget.isInCart ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    // Imagen con proporción fija y simétrica (cuadrada 1.0) si está cerrado
                    ClipRRect(
                      borderRadius: isExpanded
                          ? const BorderRadius.vertical(top: Radius.circular(23))
                          : BorderRadius.circular(23),
                      child: AspectRatio(
                        aspectRatio: widget.imageAspectRatio ?? 1.0,
                        child: _buildImage(),
                      ),
                    ),
                    // Degradado y Texto Inferior (Siempre presente en árbol, animado con opacidad estable)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: isExpanded,
                        child: AnimatedOpacity(
                          opacity: isExpanded ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(23)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(12, 32, 50, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.product.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.0, // Reducido 2 puntos (era 15)
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'S/ ${widget.product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: context.primaryGold,
                                    fontSize: 12.0, // Reducido 2 puntos (era 14)
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Botón de Favorito
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _ActionBtn(
                        icon: widget.product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: widget.product.isFavorite ? Colors.red : Colors.white,
                        onTap: widget.onFavorite,
                      ),
                    ),
                    // Botón de Editar (Modo Barbero - Flotante Esquina Superior Izquierda)
                    if (state.isEditing)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: GestureDetector(
                          onTap: () {
                            final pb = context.read<ProductBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(value: pb, child: ProductFormView(product: widget.product)),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: context.primaryGold.withOpacity(0.4), width: 1),
                                ),
                                child: const Text(
                                  'EDITAR',
                                  style: TextStyle(
                                    color: Color(0xFFF5F5DC),
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Botón de Expansión/Colapso - Esquina Inferior Derecha (Siempre fijo en la imagen)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _ActionBtn(
                        icon: isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: context.primaryGold,
                        onTap: () => context.read<ProductBloc>().add(ProductEvent.toggleExpansion(widget.product.id)),
                      ),
                    ),
                  ],
                ),
                // Contenido Expandible (Detalles abajo en cuadrante 2x2 premium)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila 1: Título
                        Text(
                          widget.product.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Fila 2: Descripción
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Fila 3: Precio y Carrito alineados
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'S/ ${widget.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: context.primaryGold,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onAddToCart,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: widget.isInCart ? context.primaryGold : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: widget.isInCart ? context.primaryGold : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  widget.isInCart ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                                  color: widget.isInCart ? Colors.black : Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    return SafeImage(
      url: widget.product.imageUrl,
      fit: BoxFit.cover,
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
