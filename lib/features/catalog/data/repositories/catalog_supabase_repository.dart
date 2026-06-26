import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trim_flow/features/catalog/data/mappers/catalog_mappers.dart';
import 'package:trim_flow/features/catalog/domain/models/tenant_catalog.dart';
import 'package:trim_flow/features/catalog/domain/repositories/catalog_repository.dart';

@LazySingleton(as: CatalogRepository)
class CatalogSupabaseRepository implements CatalogRepository {
  final SupabaseClient _client;

  CatalogSupabaseRepository(this._client);

  @override
  Future<TenantCatalog> fetchCatalog({required String tenantId}) async {
    // Branches, services y el equipo (SELECT directo) en paralelo: la latencia
    // total es la de la lectura mas lenta, no la suma.
    final results = await Future.wait([
      _client
          .from('branches')
          .select('id, name, address_line, slug, display_order')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .filter('deleted_at', 'is', null)
          .order('display_order', ascending: true),
      _client
          .from('services')
          .select('id, name, description, duration_minutes, price_pen, is_featured, display_order, categories(name)')
          .eq('tenant_id', tenantId)
          .eq('is_active', true)
          .filter('deleted_at', 'is', null)
          .order('is_featured', ascending: false)
          .order('display_order', ascending: true),
      _client
          .from('profiles')
          .select('id, full_name, avatar_url, branch_id, specialty, hired_at')
          .eq('tenant_id', tenantId)
          .or('role.eq.barber,is_acting_barber.eq.true')
          .eq('is_active', true)
          .filter('deleted_at', 'is', null)
          .order('full_name', ascending: true),
    ]);

    final branchRows = results[0];
    final serviceRows = results[1];
    var barberRows = results[2] as List<dynamic>;

    // El SELECT directo trae el equipo con specialty/hired_at para el staff. Un
    // cliente B2C (no staff del tenant) recibe lista vacia por RLS: caemos a la
    // RPC publica get_public_barbers para no quedarnos sin barberos.
    if (barberRows.isEmpty) {
      barberRows = await _fetchPublicBarbers(tenantId, branchRows);
    }

    return CatalogMappers.fromRows(
      tenantId: tenantId,
      branchRows: branchRows,
      serviceRows: serviceRows,
      barberRows: barberRows,
    );
  }

  // Fallback para clientes B2C: get_public_barbers es SECURITY DEFINER y exige
  // p_branch_id, asi que llamamos una vez por sucursal activa en paralelo y
  // mergeamos; cada fila trae branchId, dato que reservation_view usa para
  // filtrar el equipo por sede. (No devuelve specialty ni hired_at.)
  Future<List<dynamic>> _fetchPublicBarbers(
    String tenantId,
    List<dynamic> branchRows,
  ) async {
    final branchIds = branchRows
        .whereType<Map<String, dynamic>>()
        .map((b) => b['id'])
        .whereType<String>()
        .toList();
    if (branchIds.isEmpty) return const [];

    final perBranch = await Future.wait(
      branchIds.map(
        (branchId) => _client.rpc('get_public_barbers', params: {
          'p_tenant_id': tenantId,
          'p_branch_id': branchId,
        }),
      ),
    );

    final seen = <String>{};
    final merged = <dynamic>[];
    for (final result in perBranch) {
      if (result is! List) continue;
      for (final row in result) {
        if (row is! Map) continue;
        final id = row['id'];
        if (id is String && !seen.add(id)) continue;
        merged.add(row);
      }
    }
    return merged;
  }
}
