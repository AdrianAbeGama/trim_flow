import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';

part 'gallery_event.freezed.dart';

@freezed
abstract class GalleryEvent with _$GalleryEvent {
  const factory GalleryEvent.loadRequested() = GalleryLoadRequested;
  const factory GalleryEvent.categoryChanged(String? slug) = GalleryCategoryChanged;
  const factory GalleryEvent.searchChanged(String query) = GallerySearchChanged;
  const factory GalleryEvent.editModeToggled() = GalleryEditModeToggled;
  const factory GalleryEvent.itemAdded(GalleryItem item) = GalleryItemAdded;
  const factory GalleryEvent.itemDeleted(int boxKey) = GalleryItemDeleted;
  const factory GalleryEvent.showFeaturedToggled() = GalleryShowFeaturedToggled;
  const factory GalleryEvent.itemToggledFeatured(int boxKey) = GalleryItemToggledFeatured;
  const factory GalleryEvent.categoryAdded(String label) = GalleryCategoryAdded;
  const factory GalleryEvent.categoryUpdated(String oldSlug, String newLabel) = GalleryCategoryUpdated;
  const factory GalleryEvent.categoryDeleted(String slug) = GalleryCategoryDeleted;
  const factory GalleryEvent.filterModeChanged(GalleryFilterMode mode) = GalleryFilterModeChanged;
  const factory GalleryEvent.barberSelected(String? barberName) = GalleryBarberSelected;
  const factory GalleryEvent.itemsReordered(List<int> orderedBoxKeys) = GalleryItemsReordered;
}
