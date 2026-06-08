import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

/// Card del mosaico Pinterest — imagen + overlay info + estrella fav +
/// flechita expandir con panel inferior.
class GalleryMosaicCard extends StatefulWidget {
  const GalleryMosaicCard({
    super.key,
    required this.item,
    required this.height,
    required this.isBarberMode,
    required this.isEditing,
    required this.onTap,
    required this.onToggleFav,
    this.onDelete,
    this.onEdit,
  });

  final GalleryItem item;
  final double height;
  final bool isBarberMode;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onToggleFav;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  State<GalleryMosaicCard> createState() => _GalleryMosaicCardState();
}

class _GalleryMosaicCardState extends State<GalleryMosaicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: _isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(19))
                : BorderRadius.circular(19),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: widget.onTap,
                    child: GalleryItemImage(item: widget.item),
                  ),
                  _GradientOverlay(visible: !_isExpanded),
                  _InfoOverlay(item: widget.item, visible: !_isExpanded),
                  // Estrella destacar SIEMPRE visible y tocable (cliente
                  // y barbero pueden marcar/desmarcar como destacado).
                  Positioned(
                    top: 8, right: 8,
                    child: _FavStarButton(
                      isFav: widget.item.isFeatured,
                      onTap: widget.onToggleFav,
                    ),
                  ),
                  if (widget.isEditing && widget.isBarberMode)
                    Positioned(
                      top: 8, left: 8,
                      child: Row(
                        children: [
                          if (widget.onEdit != null) ...[
                            PremiumEditCircleButton(onTap: widget.onEdit!),
                            const SizedBox(width: 8),
                          ],
                          if (widget.onDelete != null)
                            _DeleteCircleButton(onTap: widget.onDelete!),
                        ],
                      ),
                    ),
                  Positioned(
                    bottom: 8, right: 8,
                    child: _ExpandChevron(
                      isExpanded: _isExpanded,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isExpanded = !_isExpanded);
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _ExpandedPanel(item: widget.item),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// OVERLAYS
// ============================================================================

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: visible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.92),
              ],
              stops: const [0.5, 0.82, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoOverlay extends StatelessWidget {
  const _InfoOverlay({required this.item, required this.visible});
  final GalleryItem item;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Positioned(
      left: 12, right: 50, bottom: 12,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1.0 : 0.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (item.barberFullName ?? 'ESTILISTA').toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.4,
                  height: 1.15,
                  shadows: const [Shadow(blurRadius: 3, color: Color(0xAA000000))],
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
      ),
    );
  }
}



// ============================================================================
// EXPANDED PANEL
// ============================================================================

class _ExpandedPanel extends StatelessWidget {
  const _ExpandedPanel({required this.item});
  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 1.5, color: gold),
          const SizedBox(height: 10),
          Text(
            item.barberFullName ?? 'Estilista',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.categoryLabel.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: gold,
              letterSpacing: 1.2,
            ),
          ),
          if ((item.barberSpecialty ?? '').trim().isNotEmpty ||
              (item.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description ?? item.barberSpecialty ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          GalleryPressable(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).popUntil((r) => r.isFirst);
              HomePage.requestedTab.value = HomePage.reservationsTabIndex;
            },
            pressedScale: 0.96,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'RESERVAR',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BUTTONS
// ============================================================================

class _FavStarButton extends StatefulWidget {
  const _FavStarButton({
    required this.isFav,
    required this.onTap,
  });
  final bool isFav;
  final VoidCallback onTap;

  @override
  State<_FavStarButton> createState() => _FavStarButtonState();
}

class _FavStarButtonState extends State<_FavStarButton> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 32, height: 32,
          decoration: BoxDecoration(
            // Fondo SIEMPRE neutro (oscuro semi-transparente). El amarillo
            // SOLO va en el icono cuando está marcada — nunca en el contorno.
            color: Colors.black.withValues(alpha: widget.isFav ? 0.65 : 0.55),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: widget.isFav ? 0.45 : 0.35),
              width: 1.2,
            ),
          ),
          child: Icon(
            widget.isFav ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: widget.isFav ? context.primaryGold : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DeleteCircleButton extends StatefulWidget {
  const _DeleteCircleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DeleteCircleButton> createState() => _DeleteCircleButtonState();
}

class _DeleteCircleButtonState extends State<_DeleteCircleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFE53935);
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
            border: Border.all(color: danger.withValues(alpha: 0.8), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: danger.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.close_rounded, size: 17, color: danger),
        ),
      ),
    );
  }
}

class _ExpandChevron extends StatefulWidget {
  const _ExpandChevron({required this.isExpanded, required this.onTap});
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_ExpandChevron> createState() => _ExpandChevronState();
}

class _ExpandChevronState extends State<_ExpandChevron> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: gold.withValues(alpha: 0.4), width: 1),
          ),
          child: AnimatedRotation(
            turns: widget.isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: gold,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
