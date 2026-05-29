import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_card.dart';

class GalleryFavoritesFullView extends StatelessWidget {
  const GalleryFavoritesFullView({super.key});

  static const List<double> _heightSeed = [
    240, 220, 280, 200, 260, 230, 270, 210, 250, 235, 215, 290,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          BlocBuilder<GalleryBloc, GalleryState>(
            builder: (context, state) {
              final favorites = state.allItems.where((it) => it.isFeatured).toList();
              
              if (favorites.isEmpty) {
                return _buildEmptyState(context);
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: favorites.length,
                  itemBuilder: (context, index) {
                    final item = favorites[index];
                    final height = _heightSeed[index % _heightSeed.length];
                    final itemId = item.id;
                    return GalleryMasonryCard(
                      item: item,
                      height: height,
                      isEditing: false,
                      isFirstItem: false,
                      onTap: () => _openFullscreen(context, favorites, index),
                      onDelete: itemId == null
                          ? () {}
                          : () => context
                              .read<GalleryBloc>()
                              .add(GalleryItemToggledFeatured(itemId)),
                    );
                  },
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.star_rounded, color: context.primaryGold, size: 28),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'MIS\nDESTACADOS',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 40, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(width: 40, height: 3, color: context.primaryGold),
            ],
          ),
        ),
      ),
    );
  }


  void _openFullscreen(BuildContext context, List items, int index) {
    final bloc = context.read<GalleryBloc>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GalleryFullscreenViewer(
          items: items.cast(),
          initialIndex: index,
        ),
      ),
    ));
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border_rounded, color: Colors.white.withValues(alpha: 0.05), size: 80),
            const SizedBox(height: 24),
            const Text(
              'AÚN NO TIENES DESTACADOS',
              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Text(
              'Toca la estrella en cualquier\ncorte para guardarlo aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
