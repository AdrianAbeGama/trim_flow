import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/safe_image.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_favorites_full_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';

class GalleryFavoritesSheet extends StatelessWidget {
  const GalleryFavoritesSheet({super.key});

  static void show(BuildContext context) {
    final bloc = context.read<GalleryBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const GalleryFavoritesSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.8,
      ),
      child: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          final favorites = state.allItems.where((p) => p.isFeatured).toList();
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Spacer for centering
                    const Text(
                      'MIS DESTACADOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen_rounded, color: Colors.white70, size: 26),
                      onPressed: () => _openFullView(context),
                    ),
                  ],
                ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const _PulsingInstructionText(text: 'Desliza a la izquierda para eliminar'),
                ],
                const SizedBox(height: 14),
                if (favorites.isEmpty)
                  const _EmptyBlock()
                else
                  Flexible(
                    child: _CompactList(items: favorites),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('SEGUIR EXPLORANDO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openFullView(BuildContext context) {
    final bloc = context.read<GalleryBloc>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const GalleryFavoritesFullView(),
        ),
      ),
    );
  }
}

class _PulsingInstructionText extends StatefulWidget {
  final String text;
  const _PulsingInstructionText({required this.text});

  @override
  State<_PulsingInstructionText> createState() => _PulsingInstructionTextState();
}

class _PulsingInstructionTextState extends State<_PulsingInstructionText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.primaryGold, 
          fontSize: 9, 
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_border_rounded, color: Colors.white24, size: 34),
            const SizedBox(height: 10),
            const Text(
              'AUN NO TIENES DESTACADOS',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Toca la estrella en cualquier corte para marcarlo.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactList extends StatelessWidget {
  const _CompactList({required this.items});
  final List<GalleryItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          Divider(color: Colors.white.withValues(alpha: 0.04), height: 14),
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = item.id;
        return Dismissible(
          key: ValueKey('fav_compact_${itemId ?? item.externalId}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star_border_rounded, color: Colors.white54),
          ),
          onDismissed: (_) {
            if (itemId != null) {
              context.read<GalleryBloc>().add(GalleryEvent.itemToggledFeatured(itemId));
            }
          },
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<GalleryBloc>(),
                    child: GalleryFullscreenViewer(
                      items: items,
                      initialIndex: index,
                    ),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                child: SafeImage(
                  url: item.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorWidget: const _FallbackBox(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item.barberFullName ?? 'Tu portafolio').toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.categoryLabel.toUpperCase(),
                      style: TextStyle(
                        color: context.primaryGold,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.star_rounded,
                  color: context.primaryGold,
                  size: 22,
                ),
                onPressed: () {
                  if (itemId != null) {
                    context.read<GalleryBloc>().add(GalleryEvent.itemToggledFeatured(itemId));
                  }
                },
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

class _FallbackBox extends StatelessWidget {
  const _FallbackBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFF1A1A1A),
      child: const Center(
        child: FaIcon(FontAwesomeIcons.scissors, color: Colors.white24, size: 14),
      ),
    );
  }
}

class GalleryFavoritesActionIcon extends StatelessWidget {
  const GalleryFavoritesActionIcon({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.star_border_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.primaryGold,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
