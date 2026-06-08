import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_favorites_sheet.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Top bar premium de la galería: pill + favs icon + edit toggle (barber) +
/// greeting BIG con line accent.
class GalleryTopBar extends StatelessWidget {
  const GalleryTopBar({
    super.key,
    required this.isBarberMode,
    required this.state,
  });

  final bool isBarberMode;
  final GalleryState state;

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
              Row(
                children: [
                  Expanded(
                    child: state.isEditing
                        ? const GalleryEditingBadge()
                        : const GalleryPill(
                            icon: Icons.photo_library_outlined,
                            label: 'GALERÍA · PORTAFOLIO',
                          ),
                  ),
                  const SizedBox(width: 8),
                  _FavoritesIconButton(
                    count: state.allItems.where((it) => it.isFeatured).length,
                    onTap: () => GalleryFavoritesSheet.show(context),
                  ),
                  if (isBarberMode) ...[
                    const SizedBox(width: 8),
                    _EditToggleButton(
                      isEditing: state.isEditing,
                      onTap: () => context
                          .read<GalleryBloc>()
                          .add(const GalleryEvent.editModeToggled()),
                    ),
                  ],
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(
                    begin: -0.4, end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 22),
              Text(
                'Nuestra',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: -0.2,
                ),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.3, end: 0,
                    delay: 120.ms, duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 4),
              Text(
                'Galería',
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
                  .slideY(
                    begin: 0.2, end: 0,
                    delay: 200.ms, duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(width: 16, height: 1.5, color: gold),
                  const SizedBox(width: 8),
                  Text(
                    'Nuestro portafolio premium',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditToggleButton extends StatefulWidget {
  const _EditToggleButton({required this.isEditing, required this.onTap});
  final bool isEditing;
  final VoidCallback onTap;

  @override
  State<_EditToggleButton> createState() => _EditToggleButtonState();
}

class _EditToggleButtonState extends State<_EditToggleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    final active = widget.isEditing;
    final color = active ? const Color(0xFFFF8A95) : gold;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.12)
                : const Color(0xFF161616),
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? color.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Icon(
            active ? Icons.check_rounded : Icons.edit_rounded,
            size: 17,
            color: active ? color : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _FavoritesIconButton extends StatefulWidget {
  const _FavoritesIconButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  State<_FavoritesIconButton> createState() => _FavoritesIconButtonState();
}

class _FavoritesIconButtonState extends State<_FavoritesIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final starYellow = context.primaryGold;
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
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 140),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Icon(
                Icons.star_rounded,
                size: 18,
                color: widget.count > 0
                    ? starYellow
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            if (widget.count > 0)
              Positioned(
                top: -2, right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: starYellow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF0A0A0A), width: 1.5),
                  ),
                  child: Text(
                    '${widget.count}',
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
        ),
      ),
    );
  }
}
