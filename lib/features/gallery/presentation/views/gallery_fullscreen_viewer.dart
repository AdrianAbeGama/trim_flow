import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

class GalleryFullscreenViewer extends StatefulWidget {
  const GalleryFullscreenViewer({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<GalleryItem> items;
  final int initialIndex;

  @override
  State<GalleryFullscreenViewer> createState() => _GalleryFullscreenViewerState();
}

class _GalleryFullscreenViewerState extends State<GalleryFullscreenViewer> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        if (_currentIndex < widget.items.length - 1) {
          _pageController.animateToPage(
            _currentIndex + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // If it's the last one, just close the viewer
          Navigator.of(context).pop();
        }
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      // Tap left
      if (_currentIndex > 0) {
        _animController.stop();
        _animController.reset();
        _pageController.animateToPage(
          _currentIndex - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Tap right
      if (_currentIndex < widget.items.length - 1) {
        _animController.stop();
        _animController.reset();
        _pageController.animateToPage(
          _currentIndex + 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _animController.stop();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black, body: SizedBox.shrink());
    }

    final currentItem = widget.items[_currentIndex];
    final gold = context.primaryGold;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              physics: const NeverScrollableScrollPhysics(), // Handled by taps now
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                _animController.stop();
                _animController.reset();
                _animController.forward();
              },
              itemBuilder: (context, i) {
                final item = widget.items[i];
                return _FullImage(item: item);
              },
            ),

            // Top gradient for indicators
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Story Progress Indicators
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(
                  widget.items.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _StoryProgress(
                        animController: _animController,
                        index: index,
                        currentIndex: _currentIndex,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top Right Actions (Close)
            Positioned(
              top: MediaQuery.of(context).padding.top + 24,
              right: 16,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),

            // Bottom Gradient and Info
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7), Colors.black.withValues(alpha: 0.95)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: gold.withValues(alpha: 0.2),
                                      border: Border.all(color: gold, width: 1.5),
                                    ),
                                    child: const Center(
                                      child: FaIcon(FontAwesomeIcons.solidUser, size: 16, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (currentItem.barberFullName ?? 'ESTILISTA').toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currentItem.barberSpecialty ?? currentItem.categoryLabel,
                                        style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (currentItem.description != null && currentItem.description!.trim().isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  currentItem.description!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Actions (Favorite)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<GalleryBloc, GalleryState>(
                              builder: (context, state) {
                                final isFeatured = state.allItems.firstWhere((it) => it.id == currentItem.id, orElse: () => currentItem).isFeatured;
                                return _ActionButton(
                                  icon: isFeatured ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: isFeatured ? gold : Colors.white,
                                  onTap: () {
                                    if (currentItem.id != null) {
                                      context.read<GalleryBloc>().add(GalleryItemToggledFeatured(currentItem.id!));
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          HomePage.requestedTab.value = HomePage.reservationsTabIndex;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'RESERVAR CON ESTE CORTE',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
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

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({
    required this.animController,
    required this.index,
    required this.currentIndex,
  });

  final AnimationController animController;
  final int index;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              if (index < currentIndex)
                Container(
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                ),
              if (index == currentIndex)
                AnimatedBuilder(
                  animation: animController,
                  builder: (context, child) {
                    return Container(
                      width: constraints.maxWidth * animController.value,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
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

class _FullImage extends StatelessWidget {
  const _FullImage({required this.item});
  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isLocalAsset) {
      final file = File(item.imageUrl);
      return Image.file(
        file,
        fit: BoxFit.cover, // Cover entire screen like stories
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _fallback(context),
      );
    }
    return CachedNetworkImage(
      imageUrl: item.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => _fallback(context),
      errorWidget: (_, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    return Center(
      child: FaIcon(FontAwesomeIcons.scissors, color: context.primaryGold.withValues(alpha: 0.35), size: 48),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, this.color = Colors.white, required this.onTap});
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon is IconData) Icon(icon, color: color, size: 28)
          else FaIcon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}
