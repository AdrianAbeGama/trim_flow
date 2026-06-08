import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_mosaic_card.dart';
import 'package:trim_flow/features/gallery/presentation/widgets/gallery_primitives.dart';

/// Grid 2 cols con drag-to-reorder usado en modo edición de barbero.
/// Cada card es uniforme (3:4) — no Pinterest masonry.
class GalleryReorderableGrid extends StatelessWidget {
  const GalleryReorderableGrid({super.key, required this.items});
  final List<GalleryItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ReorderableGridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
        itemCount: items.length,
        onReorder: (oldIndex, newIndex) {
          HapticFeedback.mediumImpact();
          final reordered = List<GalleryItem>.from(items);
          final item = reordered.removeAt(oldIndex);
          reordered.insert(newIndex, item);
          final orderedIds = reordered
              .map((it) => it.id)
              .whereType<int>()
              .toList(growable: false);
          context
              .read<GalleryBloc>()
              .add(GalleryEvent.itemsReordered(orderedIds));
        },
        itemBuilder: (context, index) {
          final item = items[index];
          return GalleryMosaicCard(
            key: ValueKey('gallery-item-${item.id ?? item.externalId}'),
            item: item,
            height: 260,
            isBarberMode: true,
            isEditing: true,
            onTap: () {},
            onToggleFav: () {
              if (item.id == null) return;
              HapticFeedback.lightImpact();
              context
                  .read<GalleryBloc>()
                  .add(GalleryEvent.itemToggledFeatured(item.id!));
            },
            onDelete: item.id == null
                ? null
                : () => _confirmDelete(context, item.id!),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int boxKey) async {
    final ok = await GalleryConfirmDelete.show(
      context,
      title: 'Eliminar foto',
      message:
          '¿Seguro que quieres eliminar esta foto del portafolio? Esta acción no se puede deshacer.',
    );
    if (ok && context.mounted) {
      context.read<GalleryBloc>().add(GalleryEvent.itemDeleted(boxKey));
    }
  }
}
