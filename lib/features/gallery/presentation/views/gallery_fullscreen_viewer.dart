import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_fullscreen_bottom_info.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

/// Visor a pantalla completa — limpio y premium. Swipe lateral entre fotos con
/// flechas indicadoras izq/der, volver con flecha (arriba izq) y destacado
/// (arriba der, mismo estilo). Sin barras de story ni auto-avance.
class GalleryFullscreenViewer extends StatefulWidget {
  const GalleryFullscreenViewer({
    super.key,
    required this.items,
    required this.initialIndex,
    this.isBarberMode = false,
  });

  final List<GalleryItem> items;
  final int initialIndex;
  final bool isBarberMode;

  @override
  State<GalleryFullscreenViewer> createState() =>
      _GalleryFullscreenViewerState();
}

class _GalleryFullscreenViewerState extends State<GalleryFullscreenViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _reserve(GalleryItem item) {
    HapticFeedback.mediumImpact();
    HomePage.requestedBarberId.value = item.barberProfileId;
    HomePage.requestedService.value = {'title': item.categoryLabel};
    Navigator.of(context).popUntil((r) => r.isFirst);
    HomePage.requestedTab.value = HomePage.reservationsTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Scaffold(
          backgroundColor: Colors.black, body: SizedBox.shrink());
    }

    final topPad = MediaQuery.of(context).padding.top;
    final currentItem = widget.items[_currentIndex];
    final canPrev = _currentIndex > 0;
    final canNext = _currentIndex < widget.items.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _FullImage(item: widget.items[i]),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.92),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.42, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (canPrev)
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavHint(
                  icon: Icons.chevron_left_rounded,
                  toRight: false,
                  onTap: () => _goTo(_currentIndex - 1),
                ),
              ),
            ),
          if (canNext)
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavHint(
                  icon: Icons.chevron_right_rounded,
                  toRight: true,
                  onTap: () => _goTo(_currentIndex + 1),
                ),
              ),
            ),
          Positioned(
            top: topPad + 12,
            left: 14,
            child: _CircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 17,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          if (currentItem.id != null)
            Positioned(
              top: topPad + 12,
              right: 14,
              child: BlocBuilder<GalleryBloc, GalleryState>(
                buildWhen: (a, b) => a.allItems != b.allItems,
                builder: (context, state) {
                  final fresh = state.allItems.firstWhere(
                    (it) => it.id == currentItem.id,
                    orElse: () => currentItem,
                  );
                  return _CircleButton(
                    icon: fresh.isFeatured
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    iconSize: 20,
                    iconColor: fresh.isFeatured
                        ? const Color(0xFFFFC93C)
                        : Colors.white,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context
                          .read<GalleryBloc>()
                          .add(GalleryEvent.itemToggledFeatured(fresh.id!));
                    },
                  );
                },
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: GalleryFullscreenBottomInfo(
                  item: currentItem,
                  onReserve: () => _reserve(currentItem),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconSize = 18,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}

class _NavHint extends StatelessWidget {
  const _NavHint({
    required this.icon,
    required this.toRight,
    required this.onTap,
  });

  final IconData icon;
  final bool toRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hint = Icon(
      icon,
      size: 30,
      color: Colors.white.withValues(alpha: 0.45),
      shadows: const [Shadow(blurRadius: 8, color: Color(0xCC000000))],
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveX(
          begin: 0,
          end: toRight ? 5 : -5,
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 24),
        child: hint,
      ),
    );
  }
}

class _FullImage extends StatelessWidget {
  const _FullImage({required this.item});
  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (item.isLocalAsset && item.imageUrl.startsWith('assets/')) {
      child = Image.asset(
        item.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _fallback(context),
      );
    } else if (item.imageUrl.startsWith('http')) {
      child = CachedNetworkImage(
        imageUrl: item.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, _) => _fallback(context),
        errorWidget: (_, _, _) => _fallback(context),
      );
    } else if (item.imageUrl.isNotEmpty) {
      child = Image.file(
        File(item.imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _fallback(context),
      );
    } else {
      child = _fallback(context);
    }
    return child;
  }

  Widget _fallback(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      color: const Color(0xFF050505),
      child: Center(
        child: Icon(
          Icons.content_cut_rounded,
          color: gold.withValues(alpha: 0.30),
          size: 56,
        ),
      ),
    );
  }
}
