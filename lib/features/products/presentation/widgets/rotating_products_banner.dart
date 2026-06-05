import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/products/data/offers_store.dart';
import 'package:trim_flow/features/products/domain/models/promo_offer.dart';

class RotatingProductsBanner extends StatefulWidget {
  const RotatingProductsBanner({super.key});

  @override
  State<RotatingProductsBanner> createState() => _RotatingProductsBannerState();
}

class _RotatingProductsBannerState extends State<RotatingProductsBanner> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 0;
  bool _isUserHolding = false;

  @override
  void initState() {
    super.initState();
    final count = OffersStore.instance.offers.value.length;
    final initialPage = count == 0 ? 0 : count * 1000;
    _page = initialPage;
    _controller = PageController(initialPage: initialPage, viewportFraction: 0.92);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _isUserHolding) return;
      _page++;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PromoOffer>>(
      valueListenable: OffersStore.instance.offers,
      builder: (context, offers, _) {
        if (offers.isEmpty) return const SizedBox.shrink();
        return Listener(
          onPointerDown: (_) => _isUserHolding = true,
          onPointerUp: (_) => _isUserHolding = false,
          onPointerCancel: (_) => _isUserHolding = false,
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (i) {
                    HapticFeedback.lightImpact();
                    setState(() => _page = i);
                  },
                  itemBuilder: (context, index) {
                    final offer = offers[index % offers.length];
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        double delta = 0;
                        if (_controller.position.haveDimensions) {
                          delta = (_controller.page ?? _page.toDouble()) - index;
                        }
                        final t = delta.abs().clamp(0.0, 1.0);
                        return Opacity(
                          opacity: 1 - 0.5 * t,
                          child: Transform.scale(scale: 1 - 0.06 * t, child: child),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _BannerCard(offer: offer),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              _HorizontalDots(
                total: offers.length,
                activeIndex: _page % offers.length,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HorizontalDots extends StatelessWidget {
  const _HorizontalDots({required this.total, required this.activeIndex});

  final int total;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 3,
          width: isActive ? 20 : 6,
          decoration: BoxDecoration(
            color: isActive ? gold : gold.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.offer});
  final PromoOffer offer;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF0D0D0D)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(color: gold.withValues(alpha: 0.06), blurRadius: 24, spreadRadius: -4),
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -14,
            child: Icon(offer.icon, size: 128, color: gold.withValues(alpha: 0.06)),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 0)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: gold.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(offer.icon, color: gold, size: 11),
                              const SizedBox(width: 5),
                              Text(
                                offer.eyebrow,
                                style: GoogleFonts.inter(
                                  color: gold,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(delay: 1200.ms, duration: 2200.ms, color: gold.withValues(alpha: 0.45)),
                        const SizedBox(height: 9),
                        Text(
                          offer.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
