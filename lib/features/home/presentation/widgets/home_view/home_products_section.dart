import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_sheets.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeProductSpotlightItem {
  final String name;
  final String image;
  final String price;
  final String description;

  const HomeProductSpotlightItem({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
  });
}

class HomeProductSpotlightSection extends StatelessWidget {
  const HomeProductSpotlightSection({
    super.key,
    required this.products,
    required this.onSeeAll,
    required this.onItemTap,
  });

  final List<HomeProductSpotlightItem> products;
  final VoidCallback? onSeeAll;
  final void Function(HomeProductSpotlightItem)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(
              text: 'Productos',
              subtitle: 'Lleva el estilo a casa',
              trailing: onSeeAll != null
                  ? HomeSeeAllPill(label: 'VER TODOS', onTap: onSeeAll!)
                  : null,
              onEdit: () => HomeEditSheets.showProductsList(context),
            ),
            const SizedBox(height: 12),
            _ProductSpotlight(products: products, onItemTap: onItemTap),
          ],
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms),
      ),
    );
  }
}

class _ProductSpotlight extends StatefulWidget {
  const _ProductSpotlight({required this.products, required this.onItemTap});
  final List<HomeProductSpotlightItem> products;
  final void Function(HomeProductSpotlightItem)? onItemTap;

  @override
  State<_ProductSpotlight> createState() => _ProductSpotlightState();
}

class _ProductSpotlightState extends State<_ProductSpotlight> {
  int _index = 0;
  Timer? _timer;
  PageController? _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 1.0);
    _startRotation();
  }

  void _startRotation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.products.isEmpty) return;
      final next = (_index + 1) % widget.products.length;
      _pageCtrl?.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final gold = context.primaryGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Card principal: split horizontal imagen|info ===
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.products.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _index = i);
              // Reset timer al interactuar
              _timer?.cancel();
              _startRotation();
            },
            itemBuilder: (_, i) {
              final p = widget.products[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _ProductCard(
                  product: p,
                  onTap: widget.onItemTap == null
                      ? null
                      : () => widget.onItemTap!(p),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // === Dots + counter elegante ===
        Row(
          children: [
            // Dots animados
            ...List.generate(widget.products.length, (i) {
              final active = i == _index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _pageCtrl?.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 6),
                  width: active ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? gold : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
            const Spacer(),
            // Counter pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                '${_index + 1} / ${widget.products.length}',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tarjeta de producto premium: split horizontal — imagen izquierda + info derecha.
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});
  final HomeProductSpotlightItem product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return HomePressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === IZQUIERDA: imagen edge-to-edge ===
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    HomeSmartImage(path: product.image),
                    // Subtle gradient para profundidad
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // === DERECHA: info + precio + CTA ===
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Línea dorada + tag PRODUCTO
                        Row(
                          children: [
                            Container(width: 14, height: 1.5, color: gold),
                            const SizedBox(width: 7),
                            Text(
                              'PRODUCTO',
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: gold.withValues(alpha: 0.85),
                                letterSpacing: 1.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    // Precio + CTA chiquito
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Precio prominente
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'PRECIO',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.35),
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'S/${product.price}',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: gold,
                                letterSpacing: -0.5,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // CTA chiquito pill dorado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: gold.withValues(alpha: 0.30)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VER',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: gold,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 11, color: gold),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// IMAGE PICKER — galería + cámara + recorte (image_picker + image_cropper)
// ============================================================================

/// Selecciona imagen DIRECTAMENTE desde la galería del celular y la recorta.
/// Sin sheet intermedio — al tocar el preview de imagen se abre la galería
/// nativa al toque. El recorte se hace con image_cropper.
/// inmediatamente en la UI del home.
