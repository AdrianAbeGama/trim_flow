import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_barber.dart';

class GalleryCategory {
  final String slug;
  final String label;

  const GalleryCategory({required this.slug, required this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GalleryCategory && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;
}

abstract class GalleryRepository {
  Future<void> ensureSeeded();
  Future<List<GalleryItem>> loadAll();
  Future<List<GalleryCategory>> loadCategories();
  Future<void> addItem(GalleryItem item);
  Future<void> updateItem(GalleryItem item);
  Future<void> deleteItem(int isarId);
  Future<void> reorderItems(List<int> orderedIsarIds);

  Future<void> addCategory(GalleryCategory category);
  Future<void> updateCategory(String oldSlug, GalleryCategory newCategory);
  Future<void> deleteCategory(String slug);

  Future<List<GalleryBarber>> loadStaff();
  Future<void> addStaff(GalleryBarber barber);
  Future<void> updateStaff(String id, GalleryBarber newBarber);
  Future<void> deleteStaff(String id);
}
