import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trim_flow/core/storage/local_storage_provider.dart';
import 'package:trim_flow/features/gallery/data/seed/gallery_seed.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_barber.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';

/// Bumpear este número limpia el box localmente la próxima vez que se abra.
/// Útil cuando se cambia el seed o se elimina demo data legacy.
const String _kGallerySchemaVersionKey = 'gallery_schema_version';
const int _kGallerySchemaVersion = 2;

@LazySingleton(as: GalleryRepository)
class GalleryHiveRepository implements GalleryRepository {
  Future<Box<Map>> get _box => LocalStorageProvider.openGalleryBox();

  @override
  Future<void> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_kGallerySchemaVersionKey) ?? 1;
    final box = await _box;

    if (currentVersion < _kGallerySchemaVersion) {
      await box.clear();
      await prefs.setInt(_kGallerySchemaVersionKey, _kGallerySchemaVersion);
    }

    if (box.isNotEmpty) return;
    final seed = GallerySeed.initial();
    for (final item in seed) {
      await box.add(item.toMap());
    }
  }

  @override
  Future<List<GalleryItem>> loadAll() async {
    final box = await _box;
    final items = <GalleryItem>[];
    for (final key in box.keys) {
      if (key is! int) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      items.add(GalleryItem.fromMap(key, raw));
    }
    items.sort((a, b) {
      final byOrder = a.displayOrder.compareTo(b.displayOrder);
      if (byOrder != 0) return byOrder;
      return b.createdAt.compareTo(a.createdAt);
    });
    return items;
  }

  @override
  Future<List<GalleryCategory>> loadCategories() async {
    final box = await _box;
    final explicitCatsMap = box.get('_categories');
    final explicitCats = <GalleryCategory>[];
    
    if (explicitCatsMap != null) {
      final list = explicitCatsMap['list'] as List?;
      if (list != null) {
        for (final item in list) {
          if (item is Map) {
            explicitCats.add(GalleryCategory(
              slug: item['slug'] ?? '',
              label: item['label'] ?? '',
            ));
          }
        }
      }
    }

    final items = await loadAll();
    final seen = <String, GalleryCategory>{};
    for (final cat in explicitCats) {
      seen[cat.slug] = cat;
    }
    for (final item in items) {
      seen.putIfAbsent(item.categorySlug, () => GalleryCategory(slug: item.categorySlug, label: item.categoryLabel));
    }
    
    return seen.values.toList()..sort((a, b) => a.label.compareTo(b.label));
  }

  Future<void> _saveExplicitCategories(List<GalleryCategory> cats) async {
    final box = await _box;
    final list = cats.map((c) => {'slug': c.slug, 'label': c.label}).toList();
    await box.put('_categories', {'list': list});
  }

  @override
  Future<void> addCategory(GalleryCategory category) async {
    final cats = await loadCategories();
    if (!cats.any((c) => c.slug == category.slug)) {
      cats.add(category);
      await _saveExplicitCategories(cats);
    }
  }

  @override
  Future<void> updateCategory(String oldSlug, GalleryCategory newCategory) async {
    final cats = await loadCategories();
    final idx = cats.indexWhere((c) => c.slug == oldSlug);
    if (idx >= 0) {
      cats[idx] = newCategory;
    } else {
      cats.add(newCategory);
    }
    await _saveExplicitCategories(cats);

    final items = await loadAll();
    for (final item in items) {
      if (item.categorySlug == oldSlug) {
        final updated = item.copyWith(
          categorySlug: newCategory.slug,
          categoryLabel: newCategory.label,
        );
        await updateItem(updated);
      }
    }
  }

  @override
  Future<void> deleteCategory(String slug) async {
    final cats = await loadCategories();
    cats.removeWhere((c) => c.slug == slug);
    await _saveExplicitCategories(cats);

    final items = await loadAll();
    for (final item in items) {
      if (item.categorySlug == slug) {
        final updated = item.copyWith(
          categorySlug: 'general',
          categoryLabel: 'General',
        );
        await updateItem(updated);
      }
    }
  }

  @override
  Future<List<GalleryBarber>> loadStaff() async {
    final box = await _box;
    final explicitStaffMap = box.get('_staff');
    final explicitStaff = <GalleryBarber>[];
    
    if (explicitStaffMap != null) {
      final list = explicitStaffMap['list'] as List?;
      if (list != null) {
        for (final item in list) {
          if (item is Map) {
            explicitStaff.add(GalleryBarber.fromMap(item));
          }
        }
      }
    }
    
    return explicitStaff..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _saveExplicitStaff(List<GalleryBarber> staff) async {
    final box = await _box;
    final list = staff.map((s) => s.toMap()).toList();
    await box.put('_staff', {'list': list});
  }

  @override
  Future<void> addStaff(GalleryBarber barber) async {
    final staff = await loadStaff();
    if (!staff.any((s) => s.id == barber.id)) {
      staff.add(barber);
      await _saveExplicitStaff(staff);
    }
  }

  @override
  Future<void> updateStaff(String id, GalleryBarber newBarber) async {
    final staff = await loadStaff();
    final idx = staff.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      staff[idx] = newBarber;
    } else {
      staff.add(newBarber);
    }
    await _saveExplicitStaff(staff);

    // Actualizar también los ítems de la galería para que reflejen el cambio de nombre/especialidad si es necesario.
    // Esto asegura coherencia aunque en base de datos idealmente se relacionen por ID.
    final items = await loadAll();
    for (final item in items) {
      if (item.barberProfileId == id || item.barberFullName == staff[idx].name) {
        final updated = item.copyWith(
          barberProfileId: id,
          barberFullName: newBarber.name,
        );
        await updateItem(updated);
      }
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    final staff = await loadStaff();
    staff.removeWhere((s) => s.id == id);
    await _saveExplicitStaff(staff);
  }

  @override
  Future<void> addItem(GalleryItem item) async {
    final box = await _box;
    await box.add(item.toMap());
  }

  @override
  Future<void> updateItem(GalleryItem item) async {
    final box = await _box;
    final id = item.id;
    if (id == null) {
      await box.add(item.toMap());
      return;
    }
    await box.put(id, item.toMap());
  }

  @override
  Future<void> deleteItem(int isarId) async {
    final box = await _box;
    await box.delete(isarId);
  }

  @override
  Future<void> reorderItems(List<int> orderedIsarIds) async {
    final box = await _box;
    for (var i = 0; i < orderedIsarIds.length; i++) {
      final id = orderedIsarIds[i];
      final raw = box.get(id);
      if (raw == null) continue;
      final map = raw.cast<String, dynamic>();
      map['displayOrder'] = i;
      await box.put(id, map);
    }
  }
}
