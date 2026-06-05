import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/core/widgets/premium/ripple_border_card.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_dual_filter_bar.dart';

/// Tira de stats compactos (fotos · barberos · estilos).
class GalleryStatsSliver extends StatelessWidget {
  const GalleryStatsSliver({super.key, required this.state});
  final GalleryState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != GalleryStatus.loaded || state.allItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final gold = context.primaryGold;
    final totalItems = state.allItems.length;
    final barberCount = state.availableBarbers.length;
    final stylesCount = state.categories.length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: RippleBorderCard(
          accent: gold,
          radius: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(child: _StatCell(icon: Icons.photo_library_rounded, value: totalItems, label: 'fotos', color: gold)),
                _StatDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.content_cut_rounded,
                    value: barberCount,
                    label: barberCount == 1 ? 'barbero' : 'barberos',
                    color: gold,
                  ),
                ),
                _StatDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.auto_awesome_rounded,
                    value: stylesCount,
                    label: stylesCount == 1 ? 'estilo' : 'estilos',
                    color: gold,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 380.ms, duration: 500.ms)
            .slideY(
              begin: 0.1, end: 0,
              delay: 380.ms, duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.85), size: 16),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Text(
            '${v.round()}',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.6,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

/// Sliver de search bar premium (icono + textfield).
class GallerySearchSliver extends StatelessWidget {
  const GallerySearchSliver({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final gold = context.primaryGold;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: controller,
            onChanged: (v) => context
                .read<GalleryBloc>()
                .add(GalleryEvent.searchChanged(v)),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            cursorColor: gold,
            decoration: InputDecoration(
              hintText: 'Buscar estilo, barbero o categoría…',
              hintStyle: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.30),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.search_rounded,
                  color: gold.withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sliver del filter dual (envuelve el widget existente).
class GalleryFilterSliver extends StatelessWidget {
  const GalleryFilterSliver({super.key, required this.state});
  final GalleryState state;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        child: GalleryDualFilterBar(
          filterMode: state.filterMode,
          categories: state.categories,
          selectedCategorySlug: state.selectedCategorySlug,
          barbers: state.availableBarbers,
          selectedBarberName: state.selectedBarberName,
          onModeChanged: (m) => context
              .read<GalleryBloc>()
              .add(GalleryEvent.filterModeChanged(m)),
          onCategorySelected: (s) => context
              .read<GalleryBloc>()
              .add(GalleryEvent.categoryChanged(s)),
          onBarberSelected: (n) => context
              .read<GalleryBloc>()
              .add(GalleryEvent.barberSelected(n)),
        ),
      ),
    );
  }
}
