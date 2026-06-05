import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_create_form_view.dart';
import 'package:trim_flow/features/gallery/presentation/views/gallery_fullscreen_viewer.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_empty_state.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_header_strips.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_mosaic_card.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_quick_actions.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_top_bar.dart';

/// Galería v9 — orquestador limpio. Toda la UI vive en widgets/.
/// Conserva: Bloc, Repo Hive, modelo, filtros, favoritos, fullscreen viewer.
class GalleryView extends StatelessWidget {
  const GalleryView({super.key, required this.isBarberMode});

  final bool isBarberMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<GalleryBloc>()..add(const GalleryEvent.loadRequested()),
      child: _GalleryScaffold(isBarberMode: isBarberMode),
    );
  }
}

class _GalleryScaffold extends StatefulWidget {
  const _GalleryScaffold({required this.isBarberMode});
  final bool isBarberMode;

  @override
  State<_GalleryScaffold> createState() => _GalleryScaffoldState();
}

class _GalleryScaffoldState extends State<_GalleryScaffold> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    context.read<GalleryBloc>().add(const GalleryEvent.loadRequested());
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0A),
      child: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: context.primaryGold,
            backgroundColor: const Color(0xFF0E0E0E),
            displacement: 60,
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                GalleryTopBar(isBarberMode: widget.isBarberMode, state: state),
                if (widget.isBarberMode && state.isEditing)
                  GalleryQuickActionsSliver(isBarberMode: widget.isBarberMode),
                GalleryStatsSliver(state: state),
                GallerySearchSliver(controller: _searchCtrl),
                GalleryFilterSliver(state: state),
                ..._buildContent(context, state),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, GalleryState state) {
    if (state.status == GalleryStatus.loading ||
        state.status == GalleryStatus.initial) {
      return [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: Center(
              child: CupertinoActivityIndicator(
                color: context.primaryGold,
                radius: 14,
              ),
            ),
          ),
        ),
      ];
    }

    final items = state.visibleItems;
    if (items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: GalleryEmptyState(
            isEditing: state.isEditing && widget.isBarberMode,
          ),
        ),
      ];
    }

    // Edit mode and view mode now use the exact same MasonryGrid
    // Reorder grid was explicitly removed by design.

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            const heights = <double>[280, 220, 260, 240, 290, 230];
            final h = heights[index % heights.length];
            return GalleryMosaicCard(
              item: item,
              height: h,
              isBarberMode: widget.isBarberMode,
              isEditing: state.isEditing && widget.isBarberMode,
              onTap: () => _openFullscreen(context, items, index),
              onDelete: item.id == null ? null : () => _confirmDelete(context, item.id!),
              onEdit: item.id == null ? null : () => _openEdit(context, item),
              onToggleFav: () {
                if (item.id == null) return;
                HapticFeedback.lightImpact();
                context
                    .read<GalleryBloc>()
                    .add(GalleryEvent.itemToggledFeatured(item.id!));
              },
            ).animate().fadeIn(
                  delay: (50 * index).clamp(0, 600).ms,
                  duration: 450.ms,
                  curve: Curves.easeOutCubic,
                ).slideY(
                  begin: 0.08,
                  end: 0,
                  delay: (50 * index).clamp(0, 600).ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                );
          },
        ),
      ),
    ];
  }

  void _openFullscreen(BuildContext context, List<GalleryItem> items, int index) {
    final bloc = context.read<GalleryBloc>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GalleryFullscreenViewer(
          items: items,
          initialIndex: index,
          isBarberMode: widget.isBarberMode,
        ),
      ),
    ));
  }

  void _openEdit(BuildContext context, GalleryItem item) {
    final bloc = context.read<GalleryBloc>();
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: GalleryCreateFormView(editingGroup: [item]),
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context, int boxKey) async {
    final ok = await GalleryConfirmDelete.show(
      context,
      title: 'Eliminar foto',
      message: '¿Seguro que quieres eliminar esta foto del portafolio? Esta acción no se puede deshacer.',
    );
    if (ok && context.mounted) {
      context.read<GalleryBloc>().add(GalleryEvent.itemDeleted(boxKey));
    }
  }
}
