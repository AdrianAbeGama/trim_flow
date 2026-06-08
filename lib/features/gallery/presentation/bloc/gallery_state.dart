import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';

part 'gallery_state.freezed.dart';

enum GalleryStatus { initial, loading, loaded, error }
enum GalleryFilterMode { styles, barbers }

@freezed
abstract class GalleryState with _$GalleryState {
  const GalleryState._();

  const factory GalleryState({
    @Default(GalleryStatus.initial) GalleryStatus status,
    @Default(<GalleryItem>[]) List<GalleryItem> allItems,
    @Default(<GalleryCategory>[]) List<GalleryCategory> categories,
    String? selectedCategorySlug,
    @Default('') String searchQuery,
    @Default(false) bool isEditing,
    @Default(false) bool showOnlyFeatured,
    @Default(GalleryFilterMode.styles) GalleryFilterMode filterMode,
    String? selectedBarberName,
    String? errorMessage,
  }) = _GalleryState;

  List<GalleryBarberSummary> get availableBarbers {
    final byName = <String, GalleryBarberSummary>{};
    for (final item in allItems) {
      final name = item.barberFullName;
      if (name == null || name.trim().isEmpty) continue;
      byName.putIfAbsent(
        name,
        () => GalleryBarberSummary(
          name: name,
          specialty: item.barberSpecialty,
          avatarHint: item.imageUrl,
          isLocalAvatar: item.isLocalAsset,
          itemCount: 0,
        ),
      );
      final current = byName[name]!;
      byName[name] = current.copyWith(itemCount: current.itemCount + 1);
    }
    final list = byName.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<GalleryItem> get visibleItems {
    Iterable<GalleryItem> base = allItems;

    if (filterMode == GalleryFilterMode.barbers && selectedBarberName != null) {
      base = base.where((it) => it.barberFullName == selectedBarberName);
    } else if (filterMode == GalleryFilterMode.styles &&
        selectedCategorySlug != null) {
      base = base.where((it) => it.categorySlug == selectedCategorySlug);
    }

    if (showOnlyFeatured) {
      base = base.where((it) => it.isFeatured);
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return base.toList();

    return base.where((it) {
      final hay =
          '${it.categoryLabel} ${it.description ?? ''} ${it.barberFullName ?? ''} ${it.barberSpecialty ?? ''}';
      return hay.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<GalleryItem>> get itemsGroupedByBarber {
    final map = <String, List<GalleryItem>>{};
    for (final item in visibleItems) {
      final key = item.barberFullName ?? 'Sin asignar';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}

class GalleryBarberSummary {
  final String name;
  final String? specialty;
  final String avatarHint;
  final bool isLocalAvatar;
  final int itemCount;

  const GalleryBarberSummary({
    required this.name,
    required this.specialty,
    required this.avatarHint,
    required this.isLocalAvatar,
    required this.itemCount,
  });

  GalleryBarberSummary copyWith({int? itemCount}) {
    return GalleryBarberSummary(
      name: name,
      specialty: specialty,
      avatarHint: avatarHint,
      isLocalAvatar: isLocalAvatar,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
