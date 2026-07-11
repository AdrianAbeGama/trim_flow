import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/home_content.dart';
import '../../domain/repositories/home_repository.dart';

/// Persistencia local del Home vía SharedPreferences (JSON serializado).
/// Hasta que el backend del socio entregue la tabla `tenant_branding` o
/// similar, los cambios de edición del Home viven en el dispositivo. Sobrevive
/// al cierre de la app y a hot-restarts.
///
/// La version de la clave se sube cuando hay que invalidar contenido viejo
/// cacheado en dispositivos (ej. al quitar el contenido mock): v2 ignora el
/// `_v1` que algunos celulares tenian guardado.
const String _kHomeContentKey = 'home_content_json_v2';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  static const HomeContent _seed = HomeContent();

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
