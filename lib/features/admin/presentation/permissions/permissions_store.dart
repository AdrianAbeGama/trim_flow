import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Capacidad asignable a un barbero (clave + etiqueta + grupo + icono).
class PermCap {
  const PermCap(this.key, this.label, this.group, this.icon);

  final String key;
  final String label;
  final String group;
  final IconData icon;
}

/// Catalogo de capacidades. Las `admin_*` reflejan las tarjetas del panel.
const List<PermCap> kPermCaps = [
  PermCap('home_edit', 'Editar Inicio', 'Acciones',
      Icons.dashboard_customize_outlined),
  PermCap('products_manage', 'Gestionar productos', 'Acciones',
      Icons.inventory_2_outlined),
  PermCap('gallery_manage', 'Gestionar galería', 'Acciones',
      Icons.photo_library_outlined),
  PermCap('orders_manage', 'Gestionar pedidos', 'Acciones',
      Icons.shopping_bag_outlined),
  PermCap('own_earnings', 'Ver sus ganancias', 'Acciones',
      Icons.payments_outlined),
  PermCap('admin_summary', 'Resumen', 'Administración', Icons.show_chart_rounded),
  PermCap('admin_cash', 'Caja', 'Administración', Icons.point_of_sale_rounded),
  PermCap('admin_hours', 'Horarios', 'Administración', Icons.schedule_rounded),
  PermCap('admin_promos', 'Promociones', 'Administración',
      Icons.local_offer_rounded),
  PermCap('admin_commissions', 'Comisiones', 'Administración',
      Icons.percent_rounded),
  PermCap('admin_customers', 'Clientes', 'Administración', Icons.groups_rounded),
  PermCap('admin_business', 'Mi barbería', 'Administración',
      Icons.storefront_rounded),
];

class PreviewRole {
  const PreviewRole({required this.id, required this.name, required this.caps});

  final String id;
  final String name;
  final Set<String> caps;
}

/// Almacen LOCAL (provisional, sin backend) de permisos por barbero, mas un modo
/// "ver como" para demostrar el control de acceso. Persistido en
/// SharedPreferences. Cuando el socio entregue la tabla real, se reemplaza esta
/// fuente sin tocar la UI.
class PermissionsStore {
  PermissionsStore._();
  static final PermissionsStore instance = PermissionsStore._();

  static const String _key = 'barber_perms_v1';
  static const Set<String> defaultCaps = {'own_earnings', 'orders_manage'};

  final Map<String, Set<String>> _perms = {};
  bool _loaded = false;

  /// Rol que se esta previsualizando. null = admin normal (ve todo).
  final ValueNotifier<PreviewRole?> preview = ValueNotifier<PreviewRole?>(null);

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        map.forEach((k, v) =>
            _perms[k] = (v as List).map((e) => e.toString()).toSet());
      }
    } catch (_) {}
    _loaded = true;
  }

  Set<String> permsFor(String barberId) =>
      _perms[barberId] ?? Set<String>.from(defaultCaps);

  Future<void> setPermsFor(String barberId, Set<String> caps) async {
    _perms[barberId] = caps;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_perms.map((k, v) => MapEntry(k, v.toList()))),
      );
    } catch (_) {}
  }

  /// En modo preview respeta los permisos del rol; como admin normal, todo.
  bool can(String cap) {
    final p = preview.value;
    if (p == null) return true;
    return p.caps.contains(cap);
  }

  bool get isPreviewing => preview.value != null;

  void startPreview(String id, String name, Set<String> caps) =>
      preview.value = PreviewRole(id: id, name: name, caps: Set.from(caps));

  void stopPreview() => preview.value = null;
}
