import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Vista de favoritos a pantalla completa — design language Profile/Home.
/// Misma estructura que la GalleryView principal pero filtrada a favoritos.
class GalleryFavoritesFullView extends StatelessWidget {
  const GalleryFavoritesFullView({super.key});

  static const List<double> _heights = [280, 220, 260, 240, 290, 230, 270, 210, 250];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            final favorites = state.allItems.where((it) => it.isFeatured).toList();
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _Header(count: favorites.length),
                if (favorites.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childCount: favorites.length,
                      itemBuilder: (context, index) {
                        final item = favorites[index];
                        final h = _heights[index % _heights.length];
                        return _FavMosaicCard(
                          item: item,
                          height: h,
                          onTap: () => _openFullscreen(context, favorites, index),
                          onRemove: () {
                            if (item.id == null) return;
                            HapticFeedback.lightImpact();
                            context
                                .read<GalleryBloc>()
                                .add(GalleryEvent.itemToggledFeatured(item.id!));
                          },
                        ).animate().fadeIn(
                              delay: (40 * index).clamp(0, 500).ms,
                              duration: 450.ms,
                              curve: Curves.easeOutCubic,
                            ).slideY(
                              begin: 0.08,
                              end: 0,
                              delay: (40 * index).clamp(0, 500).ms,
                              duration: 500.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, List<GalleryItem> items, int index) {
    final bloc = context.read<GalleryBloc>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GalleryFullscreenViewer(items: items, initialIndex: index),
      ),
    ));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: back + pill counter
              Row(
                children: [
                  GalleryBackButton(onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  }),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.primaryGold.withValues(alpha: 0.55)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC93C), size: 13),
                        const SizedBox(width: 5),
                        Text(
                          '$count ${count == 1 ? "DESTACADO" : "DESTACADOS"}',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: context.primaryGold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.4, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 22),
              // Greeting BIG
              Text(
                'Mis',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: -0.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 120.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 4),
              Text(
                'Destacados',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.6,
                  height: 1.05,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(width: 16, height: 1.5, color: gold),
                  const SizedBox(width: 8),
                  Text(
                    count == 0
                        ? 'Aún no tienes piezas favoritas'
                        : 'Las piezas que más te gustan',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 320.ms, duration: 500.ms),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.star_outline_rounded,
              color: gold.withValues(alpha: 0.75),
              size: 44,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Sin destacados aún',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Toca la estrella en cualquier foto del portafolio para guardarla aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavMosaicCard extends StatelessWidget {
  const _FavMosaicCard({
    required this.item,
    required this.height,
    required this.onTap,
    required this.onRemove,
  });

  final GalleryItem item;
  final double height;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GalleryPressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GalleryItemImage(item: item),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.0),
                  ),
                ),
              ),
              // Gradient bottom
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
              ),
              // Info bottom
              Positioned(
                left: 12, right: 12, bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (item.barberFullName ?? 'Estilista').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.4,
                        height: 1.15,
                        shadows: const [
                          Shadow(blurRadius: 3, color: Color(0xAA000000)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: gold,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove fav button (top right)
              Positioned(
                top: 8, right: 8,
                child: _RemoveFavButton(onTap: onRemove),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveFavButton extends StatefulWidget {
  const _RemoveFavButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RemoveFavButton> createState() => _RemoveFavButtonState();
}

class _RemoveFavButtonState extends State<_RemoveFavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 1.2),
          ),
          child: const Icon(Icons.star_rounded, size: 17, color: Color(0xFFFFC93C)),
        ),
      ),
    );
  }
}

