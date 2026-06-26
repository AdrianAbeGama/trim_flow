import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favoritos locales del cliente, separados de los destacados (is_featured) del
/// barbero. Singleton simple basado en ValueNotifier persistido en
/// SharedPreferences. Guarda el identificador estable del item como String.
class GalleryFavoritesStore {
  GalleryFavoritesStore._();
  static final GalleryFavoritesStore instance = GalleryFavoritesStore._();

  static const String _prefsKey = 'gallery_favs_v1';

  final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>(
    <String>{},
  );

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_prefsKey) ?? const [];
      favorites.value = stored.toSet();
    } catch (_) {
      favorites.value = <String>{};
    }
  }

  bool isFavorite(String id) => favorites.value.contains(id);

  Future<void> toggle(String id) async {
    final next = Set<String>.from(favorites.value);
    if (!next.remove(id)) next.add(id);
    favorites.value = next;
    await _persist(next);
  }

  Future<void> _persist(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, ids.toList());
    } catch (_) {}
  }
}
