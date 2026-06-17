import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_favorites_full_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Sheet de destacados — layout original (centrado, estrella, SEGUIR EXPLORANDO)
/// pero con tokens del nuevo design language: Inter typography, dark cards,
/// dorado #D4AF37, sin opacity deprecated.
class GalleryFavoritesSheet extends StatelessWidget {
  const GalleryFavoritesSheet({super.key});

  static void show(BuildContext context) {
    final bloc = context.read<GalleryBloc>();
    showModalBottomSheet<void>(
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
    final gold = context.primaryGold;
    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.78),
      child: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          final favorites = state.allItems.where((p) => p.isFeatured).toList();
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grab handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                // === Header centrado: spacer | título | fullscreen icon ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 44), // spacer simétrico
                    Text(
                      'MIS DESTACADOS',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    _IconBtn(
                      icon: Icons.fullscreen_rounded,
                      onTap: () => _openFullView(context),
                    ),
                  ],
                ),
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _PulsingInstruction(
                    text: 'Desliza a la izquierda para eliminar',
                    color: gold,
                  ),
                ],
                const SizedBox(height: 16),
                // === Contenido ===
                if (favorites.isEmpty)
                  _EmptyBlock(gold: gold)
                else
                  Flexible(
                    child: _CompactList(items: favorites),
                  ),
                const SizedBox(height: 22),
                // === CTA SEGUIR EXPLORANDO ===
                _SeguirExplorandoButton(
                  onTap: () => Navigator.pop(context),
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
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const GalleryFavoritesFullView(),
        ),
      ),
    );
  }
}

// ============================================================================
// COMPACT LIST — thumb + barber + categoria + estrella, swipe to remove
// ============================================================================

class _CompactList extends StatelessWidget {
  const _CompactList({required this.items});
  final List<GalleryItem> items;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(
        color: Colors.white.withValues(alpha: 0.04),
        height: 14,
      ),
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
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.star_border_rounded,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          onDismissed: (_) {
            if (itemId != null) {
              HapticFeedback.lightImpact();
              context.read<GalleryBloc>().add(
                    GalleryEvent.itemToggledFeatured(itemId),
                  );
            }
          },
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
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
                  child: GalleryItemImage(item: item, width: 48, height: 48),
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
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.categoryLabel.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: gold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.star_rounded, color: Color(0xFFFFC93C), size: 22),
                  onPressed: () {
                    if (itemId != null) {
                      HapticFeedback.lightImpact();
                      context
                          .read<GalleryBloc>()
                          .add(GalleryEvent.itemToggledFeatured(itemId));
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

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.gold});
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border_rounded,
            color: Colors.white.withValues(alpha: 0.22),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'AÚN NO TIENES DESTACADOS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca la estrella en cualquier corte para marcarlo.',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PULSING INSTRUCTION TEXT (centrada con dorado)
// ============================================================================

class _PulsingInstruction extends StatefulWidget {
  const _PulsingInstruction({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  State<_PulsingInstruction> createState() => _PulsingInstructionState();
}

class _PulsingInstructionState extends State<_PulsingInstruction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _op;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _op = Tween<double>(begin: 0.25, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _op,
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: widget.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ============================================================================
// CTA SEGUIR EXPLORANDO — outline blanco, premium
// ============================================================================

class _SeguirExplorandoButton extends StatefulWidget {
  const _SeguirExplorandoButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SeguirExplorandoButton> createState() => _SeguirExplorandoButtonState();
}

class _SeguirExplorandoButtonState extends State<_SeguirExplorandoButton> {
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
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Text(
            'SEGUIR EXPLORANDO',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ICON BUTTON minimal (fullscreen icon)
// ============================================================================

class _IconBtn extends StatefulWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
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
        scale: _pressed ? 0.85 : 1,
        duration: const Duration(milliseconds: 140),
        child: SizedBox(
          width: 44, height: 44,
          child: Icon(
            widget.icon,
            color: Colors.white.withValues(alpha: 0.72),
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Botón legacy usado por imports antiguos — preservar API
// ============================================================================

class GalleryFavoritesActionIcon extends StatelessWidget {
  const GalleryFavoritesActionIcon({
    super.key,
    required this.count,
    required this.onTap,
  });

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
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Icon(
              Icons.star_rounded,
              size: 17,
              color: count > 0 ? const Color(0xFFFFC93C) : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -2, right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: context.primaryGold,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF0A0A0A), width: 1.5),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
