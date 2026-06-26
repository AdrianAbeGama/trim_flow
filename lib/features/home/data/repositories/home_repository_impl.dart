import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/home_content.dart';
import '../../domain/repositories/home_repository.dart';

/// Persistencia local del Home vía SharedPreferences (JSON serializado).
/// Hasta que el backend del socio entregue la tabla `tenant_branding` o
/// similar, los cambios de edición del Home viven en el dispositivo. Sobrevive
/// al cierre de la app y a hot-restarts.
const String _kHomeContentKey = 'home_content_json_v1';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  static const HomeContent _seed = HomeContent(
    heroTitle: 'Barbería Ocean',
    heroSubtitle: 'Donde el estilo se encuentra con la precisión.',
    heroTag1: 'PREMIUM',
    heroTag2: 'STUDIO',
    stories: [
      {'label': 'Fade', 'image': 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=800'},
      {'label': 'Clásico', 'image': 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800'},
      {'label': 'Barba', 'image': 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800'},
      {'label': 'Diseño', 'image': 'https://images.unsplash.com/photo-1512690196252-741ef2ae7626?w=800'},
    ],
    aboutUsTitle: 'Sobre Nosotros',
    aboutUsText: 'Pasión por el detalle, respeto por la tradición y compromiso con tu estilo.',
  );

  @override
  Future<HomeContent> getHomeContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kHomeContentKey);
      if (raw == null || raw.isEmpty) {
        return _seed;
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HomeContent.fromJson(json);
    } catch (_) {
      return _seed;
    }
  }

  @override
  Future<void> saveHomeContent(HomeContent content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kHomeContentKey, jsonEncode(content.toJson()));
    } catch (_) {
      // Silenciar — siguiente save reintenta
    }
  }
}
