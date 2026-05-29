import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';

class RotatingProductsBanner extends StatefulWidget {
  const RotatingProductsBanner({super.key});

  static const List<_BannerSlide> _slides = [
    _BannerSlide(
      eyebrow: 'OFERTA DE LA SEMANA',
      title: '20% DESCUENTO',
      caption: 'En toda nuestra línea de pomadas y ceras mate.',
    ),
    _BannerSlide(
      eyebrow: 'KIT PREMIUM',
      title: 'LLEVATE 3, PAGA 2',
      caption: 'En tónicos para el cuidado de barba.',
    ),
    _BannerSlide(
      eyebrow: 'NUEVO INGRESO',
      title: 'SHAMPOO ANTICASPA',
      caption: 'Fórmula enriquecida con carbón activado.',
    ),
    _BannerSlide(
      eyebrow: 'CUIDADO INTEGRAL',
      title: '-15% EN ACEITES',
      caption: 'Aceites esenciales para suavizar el vello facial.',
    ),
  ];

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
    // Start at a large multiple of slides length to allow backwards swiping infinitely
    final initialPage = RotatingProductsBanner._slides.length * 1000;
    _page = initialPage;
    _controller = PageController(initialPage: initialPage);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _isUserHolding) return;
      _page++;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastOutSlowIn,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Listener(
        onPointerDown: (_) => _isUserHolding = true,
        onPointerUp: (_) => _isUserHolding = false,
        onPointerCancel: (_) => _isUserHolding = false,
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final actualIndex = index % RotatingProductsBanner._slides.length;
                  return _BannerCard(slide: RotatingProductsBanner._slides[actualIndex]);
                },
              ),
            ),
            const SizedBox(height: 12),
            _HorizontalDots(
              total: RotatingProductsBanner._slides.length,
              activeIndex: _page % RotatingProductsBanner._slides.length,
            ),
          ],
        ),
      ),
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
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 3,
          width: isActive ? 18 : 6,
          decoration: BoxDecoration(
            color: isActive ? gold : gold.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _BannerSlide {
  final String eyebrow;
  final String title;
  final String caption;
  const _BannerSlide({
    required this.eyebrow,
    required this.title,
    required this.caption,
  });
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.slide});
  final _BannerSlide slide;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 48,
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.eyebrow,
                  style: TextStyle(
                    color: gold.withValues(alpha: 0.8),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slide.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
