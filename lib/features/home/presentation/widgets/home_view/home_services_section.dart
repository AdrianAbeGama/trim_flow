import 'package:trim_flow/features/home/presentation/widgets/home_view/home_edit_sheets.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/presentation/widgets/home_view/home_primitives.dart';

class HomeStyleItem {
  final String name;
  final String image;
  final String? price;
  final String? duration;
  final bool featured;

  const HomeStyleItem({
    required this.name,
    required this.image,
    this.price,
    this.duration,
    this.featured = false,
  });
}

// ============================================================================
// SERVICIOS — Infinite carousel (continuo loop izq→der)
// ============================================================================

class HomeInfiniteServicesSection extends StatelessWidget {
  const HomeInfiniteServicesSection({
    super.key,
    required this.items,
    required this.onSeeAll,
    required this.onItemTap,
  });

  final List<HomeStyleItem> items;
  final VoidCallback? onSeeAll;
  final void Function(HomeStyleItem)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: HomeSectionTitle(
                text: 'Servicios',
                subtitle: 'Lo mejor para tu estilo',
                trailing: onSeeAll != null
                    ? HomeSeeAllPill(label: 'VER TODOS', onTap: onSeeAll!)
                    : null,
                onEdit: () => HomeEditSheets.showServicesList(context),
              ),
            ),
            _InfiniteCarousel(items: items, onItemTap: onItemTap),
          ],
        )
            .animate()
            .fadeIn(delay: 380.ms, duration: 600.ms),
      ),
    );
  }
}

/// Carousel **infinito** que scrollea continuamente de izq a der
/// (estilo marquee). Pausa 4s cuando el user interactúa.
class _InfiniteCarousel extends StatefulWidget {
  const _InfiniteCarousel({required this.items, required this.onItemTap});

  final List<HomeStyleItem> items;
  final void Function(HomeStyleItem)? onItemTap;

  @override
  State<_InfiniteCarousel> createState() => _InfiniteCarouselState();
}

class _InfiniteCarouselState extends State<_InfiniteCarousel> {
  late final ScrollController _ctrl;
  Timer? _timer;
  bool _paused = false;
  bool _ready = false;

  // Repetir items muchas veces para simular infinito.
  static const int _multiplier = 50;

  static const double _cardWidth = 150;
  static const double _gap = 12;
  static const double _step = 0.5; // pixels por tick
  static const Duration _tick = Duration(milliseconds: 16); // ~60fps

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    // Espera 500ms después del primer frame para asegurar layout listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _ready = true;
          _start();
        }
      });
    });
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted || !_ready || !_ctrl.hasClients || _paused) return;
      try {
        final position = _ctrl.position;
        final maxScroll = position.maxScrollExtent;
        // Si el layout no está listo (maxScroll == 0 o infinito), abortar.
        if (maxScroll <= 0 || !maxScroll.isFinite) return;

        final current = _ctrl.offset;
        final next = current + _step;
        final cycleWidth = (_cardWidth + _gap) * widget.items.length;

        // Salto invisible cuando llegamos cerca del final
        if (next >= maxScroll - cycleWidth && next - cycleWidth >= 0) {
          _ctrl.jumpTo(next - cycleWidth);
        } else if (next <= maxScroll) {
          _ctrl.jumpTo(next);
        }
      } catch (_) {
        // Silencia errores transitorios de layout/scroll
      }
    });
  }

  void _pauseAndResume() {
    _paused = true;
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted) _paused = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollStartNotification && n.dragDetails != null) {
            _pauseAndResume();
          }
          return false;
        },
        child: ListView.separated(
          controller: _ctrl,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: widget.items.length * _multiplier,
          separatorBuilder: (_, _) => const SizedBox(width: _gap),
          itemBuilder: (_, i) {
            final actual = widget.items[i % widget.items.length];
            return _StyleCard(
              item: actual,
              onTap: widget.onItemTap == null
                  ? null
                  : () {
                      _pauseAndResume();
                      widget.onItemTap!(actual);
                    },
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCTOS — Spotlight (uno solo rotando cada 3s)
// ============================================================================

class _StyleCard extends StatefulWidget {
  const _StyleCard({required this.item, required this.onTap});

  final HomeStyleItem item;
  final VoidCallback? onTap;

  @override
  State<_StyleCard> createState() => _StyleCardState();
}

class _StyleCardState extends State<_StyleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final hasPrice = widget.item.price != null;
    final hasDuration = widget.item.duration != null;

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onTap!();
            },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen de fondo
                HomeSmartImage(path: widget.item.image),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
                // Featured badge top right
                if (widget.item.featured)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'POPULAR',
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                // Contenido inferior
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre con tijera
                      Row(
                        children: [
                          Icon(
                            Icons.content_cut_rounded,
                            size: 12,
                            color: gold,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (hasDuration) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 9,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.item.duration!,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (hasPrice) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'S/${widget.item.price}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// 7. SOBRE NOSOTROS
// ============================================================================

