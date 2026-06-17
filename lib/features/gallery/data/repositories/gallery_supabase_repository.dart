import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/catalog/domain/models/tenant_catalog.dart';
import 'package:trim_flow/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_barber.dart';
import 'package:trim_flow/features/gallery/domain/models/gallery_item.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';

/// Galería conectada al backend (RPCs del socio, ADR-0015).
///
/// - Cliente: junta el portafolio de TODOS los barberos del tenant
///   (`get_barber_gallery` por barbero, opción B; no hay RPC de tenant aún).
/// - Barbero: ve y gestiona solo el suyo (lo detecta por `auth.uid()` en el
///   equipo del tenant).
///
/// Como `get_barber_gallery` no devuelve `service_id`, al subir guardamos el
/// nombre del servicio en `caption` para poder mostrarlo y filtrarlo. El
/// `service_id` real igual viaja en `add_gallery_item`.
@LazySingleton(as: GalleryRepository)
class GallerySupabaseRepository implements GalleryRepository {
  GallerySupabaseRepository(this._client, this._tenantTheme, this._catalog);

  final SupabaseClient _client;
  final TenantThemeBloc _tenantTheme;
  final CatalogRepository _catalog;

  static const String _bucket = 'media';

  static final RegExp _uuidRe = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  TenantCatalog? _catalogCache;
  String? _catalogTenant;
  final Map<int, String> _idToRemote = {};

  Future<TenantCatalog?> _catalogFor(String tenantId) async {
    if (tenantId.isEmpty || tenantId == kDefaultTenantId) return null;
    if (_catalogCache != null && _catalogTenant == tenantId) {
      return _catalogCache;
    }
    final c = await _catalog.fetchCatalog(tenantId: tenantId);
    _catalogCache = c;
    _catalogTenant = tenantId;
    return c;
  }

  @override
  Future<void> ensureSeeded() async {}

  @override
  Future<List<GalleryItem>> loadAll() async {
    final tenantId = _tenantTheme.state.tenantId;
    final catalog = await _catalogFor(tenantId);
    _idToRemote.clear();
    if (catalog == null) return [];

    final authUid = _client.auth.currentUser?.id;
    TeamMember? self;
    if (authUid != null) {
      for (final b in catalog.team) {
        if (b.id == authUid) {
          self = b;
          break;
        }
      }
      self ??= await _selfAsTeamMember(authUid, tenantId);
    }
    final isStaff = self != null;

    final serviceName = {for (final s in catalog.services) s.id: s.name};
    final servicePrice = {for (final s in catalog.services) s.id: s.price};
    final barberById = {for (final b in catalog.team) b.id: b};

    // Lectura directa de gallery_items (policy gallery_select_public). Cliente ve
    // toda la barbería; staff (barbero/admin) ve solo lo suyo para gestionarlo.
    final base = _client
        .from('gallery_items')
        .select('id, image_path, caption, service_id, is_featured, barber_id')
        .eq('tenant_id', tenantId);
    final filtered =
        (isStaff && authUid != null) ? base.eq('barber_id', authUid) : base;
    final rows = await filtered
        .order('is_featured', ascending: false)
        .order('created_at', ascending: false);

    final list = (rows as List).whereType<Map<String, dynamic>>().toList();
    final now = DateTime.now();
    final items = <GalleryItem>[];
    for (var i = 0; i < list.length; i++) {
      final r = list[i];
      final remoteId = r['id'] as String? ?? '';
      if (remoteId.isEmpty) continue;
      final barberId = r['barber_id'] as String?;
      final b = barberId == null ? null : barberById[barberId];
      final name = b?.fullName ??
          (barberId == authUid ? self?.fullName : null) ??
          'Estilista';
      final specialty =
          b?.specialty ?? (barberId == authUid ? self?.specialty : null);
      final svcId = r['service_id'] as String?;
      final caption = (r['caption'] as String?)?.trim();
      final label = (svcId != null ? serviceName[svcId] : null) ??
          (caption != null && caption.isNotEmpty
              ? caption
              : (specialty ?? 'Corte'));
      final imagePath = r['image_path'] as String? ?? '';
      _idToRemote[i] = remoteId;
      items.add(GalleryItem(
        id: i,
        externalId: remoteId,
        imageUrl: imagePath.isEmpty
            ? ''
            : _client.storage.from(_bucket).getPublicUrl(imagePath),
        categorySlug: svcId ?? '',
        categoryLabel: label,
        description: caption,
        barberProfileId: barberId,
        barberFullName: name,
        barberSpecialty: specialty,
        createdAt: now,
        displayOrder: i,
        isFeatured: r['is_featured'] as bool? ?? false,
        price: svcId != null ? servicePrice[svcId] : null,
      ));
    }
    return items;
  }

  Future<TeamMember?> _selfAsTeamMember(String uid, String tenantId) async {
    try {
      final row = await _client
          .from('profiles')
          .select('id, full_name, specialty')
          .eq('id', uid)
          .eq('tenant_id', tenantId)
          .maybeSingle();
      if (row == null) return null;
      return TeamMember(
        tenantId: tenantId,
        id: row['id'] as String,
        fullName: (row['full_name'] as String?) ?? 'Mis fotos',
        specialty: row['specialty'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GalleryCategory>> loadCategories() async {
    final tenantId = _tenantTheme.state.tenantId;
    final c = await _catalogFor(tenantId);
    if (c == null) return [];
    return c.services
        .map((s) => GalleryCategory(slug: s.id, label: s.name))
        .toList();
  }

  @override
  Future<void> addItem(GalleryItem item) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('unauthenticated');
    // Solo se suben archivos locales recién elegidos; las URLs remotas se ignoran.
    if (item.imageUrl.isEmpty || item.imageUrl.startsWith('http')) return;

    final bytes = await File(item.imageUrl).readAsBytes();
    final ext = _ext(item.imageUrl);
    final path = 'gallery/$uid/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _mime(ext), upsert: false),
        );

    final caption =
        item.categoryLabel.trim().isEmpty ? null : item.categoryLabel.trim();
    final serviceId = _uuidRe.hasMatch(item.categorySlug) ? item.categorySlug : null;
    await _client.rpc('add_gallery_item', params: {
      'p_image_path': path,
      'p_caption': caption,
      'p_service_id': serviceId,
    });
  }

  @override
  Future<void> updateItem(GalleryItem item) async {
    final remote = item.externalId;
    if (!_uuidRe.hasMatch(remote)) return;
    await _client.rpc('toggle_gallery_featured',
        params: {'p_item_id': remote, 'p_featured': item.isFeatured});
  }

  @override
  Future<void> deleteItem(int isarId) async {
    final remote = _idToRemote[isarId];
    if (remote == null) return;
    await _client.rpc('delete_gallery_item', params: {'p_item_id': remote});
  }

  @override
  Future<void> reorderItems(List<int> orderedIsarIds) async {}

  // Categorías = servicios reales del catálogo (solo lectura desde la app).
  @override
  Future<void> addCategory(GalleryCategory category) async {}

  @override
  Future<void> updateCategory(String oldSlug, GalleryCategory newCategory) async {}

  @override
  Future<void> deleteCategory(String slug) async {}

  // Staff lo gestiona el panel web; la app no lo edita.
  @override
  Future<List<GalleryBarber>> loadStaff() async => const [];

  @override
  Future<void> addStaff(GalleryBarber barber) async {}

  @override
  Future<void> updateStaff(String id, GalleryBarber newBarber) async {}

  @override
  Future<void> deleteStaff(String id) async {}

  String _ext(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    return ext.length > 4 ? 'jpg' : ext;
  }

  String _mime(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
