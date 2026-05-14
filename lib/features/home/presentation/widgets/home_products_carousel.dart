import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import '../../domain/models/home_content.dart';

class HomeProductsCarousel extends StatelessWidget {
  final HomeContent content;
  final bool isEditing;
  final Function(int, Map<String, String>) onEdit;
  final Function(int) onRemove;
  final VoidCallback onAdd;

  const HomeProductsCarousel({
    super.key,
    required this.content,
    required this.isEditing,
    required this.onEdit,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (content.products.isEmpty && !isEditing) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final itemCount = isEditing 
        ? (content.products.length < 5 ? content.products.length + 1 : 5)
        : content.products.length;

    return SliverToBoxAdapter(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          height: 220,
          viewportFraction: 0.9,
          autoPlay: !isEditing,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          pauseAutoPlayOnTouch: true,
          enlargeCenterPage: true,
          enableInfiniteScroll: !isEditing && content.products.length > 1,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index, realIndex) {
          if (isEditing && index == content.products.length) {
            return _buildAddCard(context);
          }
          final p = content.products[index];
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildProductImage(p['img']!),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p['name']!.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p['desc'] ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p['price']!,
                              style: TextStyle(
                                color: context.primaryGold,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isEditing)
                Positioned(
                  top: 12,
                  right: 15,
                  child: Row(
                    children: [
                      _buildMiniEditIcon(() => onEdit(index, p)),
                      const SizedBox(width: 4),
                      _buildMiniRemoveIcon(context, () => onRemove(index)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.primaryGold.withValues(alpha: 0.2), width: 1),
      ),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: context.primaryGold.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                  border: Border(right: BorderSide(color: context.primaryGold.withValues(alpha: 0.1), width: 1)),
                ),
                child: Icon(Icons.add_shopping_cart_rounded, color: context.primaryGold, size: 32),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'AÑADIR PRODUCTO',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MÁXIMO 5',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    Widget image;
    if (url.startsWith('http')) {
      image = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.white10, size: 24)),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.white10, size: 24)),
      );
    } else if (url.startsWith('assets/')) {
      image = Image.asset(url, fit: BoxFit.cover);
    } else if (url.isNotEmpty && File(url).existsSync()) {
      image = Image.file(File(url), fit: BoxFit.cover);
    } else {
      image = Container(
        color: Colors.white.withValues(alpha: 0.02),
        child: const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.white10, size: 24)),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02)),
        child: image,
      ),
    );
  }

  Widget _buildMiniEditIcon(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Text(
          'EDITAR',
          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildMiniRemoveIcon(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161616),
            title: const Text('ELIMINAR PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            content: const Text('¿Quieres eliminar este producto?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NO', style: TextStyle(color: Colors.white38)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('SÍ, ELIMINAR', style: TextStyle(color: Color(0xFFFF4D4D), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (confirm == true) onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFFF4D4D).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF4D4D), width: 1),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF4D4D), size: 10),
      ),
    );
  }
}
