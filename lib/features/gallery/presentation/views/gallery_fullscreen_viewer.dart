import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_fullscreen_bottom_info.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

/// Visor a pantalla completa — design language Profile/Home/Galería.
/// Conserva: story-progress, tap-to-advance, long-press-pause, swipe lateral.
/// Refresca: top bar premium, info card inferior con Inter + line accent,
/// botón Reservar igual al de Home (gradient + glow + shimmer).
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
  State<GalleryFullscreenViewer> createState() => _GalleryFullscreenViewerState();
}

class _GalleryFullscreenViewerState extends State<GalleryFullscreenViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressCtrl;
  late int _currentIndex;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _progressCtrl.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        _advanceOrClose();
      }
    });
    _progressCtrl.forward();
  }

  void _advanceOrClose() {
    if (_currentIndex < widget.items.length - 1) {
      _goTo(_currentIndex + 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goTo(int i) {
    _progressCtrl.stop();
    _progressCtrl.reset();
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onTapDown(TapDownDetails details) {
    final w = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < w * 0.32) {
      if (_currentIndex > 0) _goTo(_currentIndex - 1);
    } else if (dx > w * 0.68) {
      _advanceOrClose();
    }
  }

  void _onLongPressStart(LongPressStartDetails _) {
    setState(() => _isPaused = true);
    _progressCtrl.stop();
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    setState(() => _isPaused = false);
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black, body: SizedBox.shrink());
    }

    final currentItem = widget.items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // === IMAGEN PAGE VIEW ===
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                _progressCtrl.stop();
                _progressCtrl.reset();
                if (!_isPaused) _progressCtrl.forward();
              },
              itemBuilder: (_, i) => _FullImage(item: widget.items[i]),
            ),

            // === GRADIENT TOP ===
            Positioned(
              top: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // === GRADIENT BOTTOM (más alto para acomodar magazine layout) ===
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 420,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.92),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.40, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // === STORY PROGRESS BARS ===
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12, right: 12,
              child: Row(
                children: List.generate(
                  widget.items.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _StoryProgress(
                        ctrl: _progressCtrl,
                        index: index,
                        currentIndex: _currentIndex,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // === TOP BAR: counter + close + pause indicator ===
            Positioned(
              top: MediaQuery.of(context).padding.top + 26,
              left: 16, right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.items.length}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (_isPaused) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'PAUSADO',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),

            // === INFO CARD BOTTOM + FAV + RESERVAR ===
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: GalleryFullscreenBottomInfo(
                    item: currentItem,
                    isBarberMode: widget.isBarberMode,
                    onToggleFav: () {
                      if (currentItem.id == null) return;
                      HapticFeedback.lightImpact();
                      context
                          .read<GalleryBloc>()
                          .add(GalleryEvent.itemToggledFeatured(currentItem.id!));
                    },
                    onReserve: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      HomePage.requestedTab.value = HomePage.reservationsTabIndex;
                    },
                  ),
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
// IMAGEN FULL
// ============================================================================

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

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({
    required this.ctrl,
    required this.index,
    required this.currentIndex,
  });

  final AnimationController ctrl;
  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              if (index < currentIndex)
                Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              if (index == currentIndex)
                AnimatedBuilder(
                  animation: ctrl,
                  builder: (_, _) {
                    return Container(
                      width: constraints.maxWidth * ctrl.value,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Icon(
            CupertinoIcons.xmark,
            color: Colors.white,
            size: 15,
          ),
        ),
      ),
    );
  }
}
