import 'package:core/core.dart';
import 'package:trim_flow/features/catalog/domain/models/tenant_catalog.dart';

class CatalogMappers {
  const CatalogMappers._();

  static TenantCatalog fromRows({
    required String tenantId,
    required List<dynamic> branchRows,
    required List<dynamic> serviceRows,
    required List<dynamic> barberRows,
  }) {
    final centers = branchRows
        .whereType<Map<String, dynamic>>()
        .map((r) => _center(r, tenantId))
        .toList();
    final services = serviceRows
        .whereType<Map<String, dynamic>>()
        .map((r) => _service(r, tenantId))
        .toList();
    final team = barberRows
        .whereType<Map<String, dynamic>>()
        .map((r) => _teamMember(r, tenantId))
        .toList();
    return TenantCatalog(centers: centers, services: services, team: team);
  }

  static BarberCenter _center(Map<String, dynamic> r, String tenantId) {
    return BarberCenter(
      tenantId: tenantId,
      id: r['id'] as String,
      name: (r['name'] as String?) ?? 'Sucursal',
      location: (r['address_line'] as String?)?.trim() ?? '',
      imageUrl: null,
    );
  }

  static Service _service(Map<String, dynamic> r, String tenantId) {
    return Service(
      tenantId: tenantId,
      id: r['id'] as String,
      name: (r['name'] as String?) ?? 'Servicio',
      price: (r['price_pen'] as num?)?.toDouble() ?? 0,
      durationInMinutes: (r['duration_minutes'] as num?)?.toInt() ?? 0,
      category: 'Servicios',
      isFeatured: (r['is_featured'] as bool?) ?? false,
    );
  }

  static TeamMember _teamMember(Map<String, dynamic> r, String tenantId) {
    return TeamMember(
      tenantId: tenantId,
      id: r['id'] as String,
      fullName: (r['full_name'] as String?) ?? 'Barbero',
      yearsOfExperience: _yearsFrom(r['hired_at'] as String?),
      specialty: r['specialty'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      branchId: r['branch_id'] as String?,
    );
  }

  static int _yearsFrom(String? hiredAt) {
    if (hiredAt == null || hiredAt.isEmpty) return 0;
    final parsed = DateTime.tryParse(hiredAt);
    if (parsed == null) return 0;
    final days = DateTime.now().difference(parsed).inDays;
    return days <= 0 ? 0 : days ~/ 365;
  }
}
