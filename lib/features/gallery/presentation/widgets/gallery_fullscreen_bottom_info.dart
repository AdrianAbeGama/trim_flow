import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/premium_primitives.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';

/// Info inferior del visor — limpia y premium. Etiqueta de servicio que resalta,
/// nombre del barbero grande, especialidad fina, y un botón Reservar a ancho
/// completo (color del tenant). El destacado vive en la esquina superior.
class GalleryFullscreenBottomInfo extends StatelessWidget {
  const GalleryFullscreenBottomInfo({
    super.key,
    required this.item,
    required this.onReserve,
    this.isBarberMode = false,
  });

  final GalleryItem item;
  final VoidCallback onReserve;
  final bool isBarberMode;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return BlocBuilder<GalleryBloc, GalleryState>(
      buildWhen: (a, b) => a.allItems != b.allItems,
      builder: (context, state) {
        final fresh = state.allItems.firstWhere(
          (it) => it.id == item.id,
          orElse: () => item,
        );
        return _Layout(
          item: fresh,
          gold: gold,
          onReserve: onReserve,
          isBarberMode: isBarberMode,
        );
      },
    );
  }
}

class _Layout extends StatelessWidget {
  const _Layout({
    required this.item,
    required this.gold,
    required this.onReserve,
    required this.isBarberMode,
  });

  final GalleryItem item;
  final Color gold;
  final VoidCallback onReserve;
  final bool isBarberMode;

  @override
  Widget build(BuildContext context) {
    final onAccent = premiumOnAccent(gold);
    final specialty = (item.barberSpecialty ?? '').trim();
    final name = item.barberFullName ?? 'Estilista';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.categoryLabel.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: onAccent,
                  letterSpacing: 1.3,
                ),
              ),
            ),
            if (item.price != null) ...[
              const SizedBox(width: 10),
              Text(
                'S/ ${item.price! % 1 == 0 ? item.price!.toStringAsFixed(0) : item.price!.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: const [Shadow(blurRadius: 6, color: Color(0xCC000000))],
                ),
              ),
            ],
          ],
        ).animate(key: ValueKey('tag-${item.imageUrl}')).fadeIn(duration: 320.ms),
        const SizedBox(height: 14),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.0,
            height: 1.02,
            shadows: const [Shadow(blurRadius: 8, color: Color(0xDD000000))],
          ),
        )
            .animate(key: ValueKey('name-${item.imageUrl}'))
            .fadeIn(delay: 80.ms, duration: 380.ms)
            .slideY(begin: 0.3, end: 0, duration: 420.ms, curve: Curves.easeOutCubic),
        if (specialty.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(
            specialty,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
              shadows: const [Shadow(blurRadius: 4, color: Color(0xAA000000))],
            ),
          ).animate(key: ValueKey('spec-${item.imageUrl}')).fadeIn(
              delay: 160.ms, duration: 380.ms),
        ],
        if (!isBarberMode) ...[
          const SizedBox(height: 22),
          _ReserveButton(gold: gold, onTap: onReserve),
        ],
      ],
    );
  }
}

class _ReserveButton extends StatelessWidget {
  const _ReserveButton({required this.gold, required this.onTap});
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumPressable(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gold,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Reservar corte',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: premiumOnAccent(gold),
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
