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
    final branchRows = await _client
        .from('branches')
        .select('id, name, address_line, slug, display_order')
        .eq('tenant_id', tenantId)
        .eq('is_active', true)
        .filter('deleted_at', 'is', null)
        .order('display_order', ascending: true);

    final serviceRows = await _client
        .from('services')
        .select('id, name, description, duration_minutes, price_pen, is_featured, display_order')
        .eq('tenant_id', tenantId)
        .eq('is_active', true)
        .filter('deleted_at', 'is', null)
        .order('is_featured', ascending: false)
        .order('display_order', ascending: true);

    final barberRows = await _client
        .from('profiles')
        .select('id, full_name, avatar_url, branch_id, specialty, hired_at')
        .eq('tenant_id', tenantId)
        .eq('role', 'barber')
        .eq('is_active', true)
        .filter('deleted_at', 'is', null)
        .order('full_name', ascending: true);

    return CatalogMappers.fromRows(
      tenantId: tenantId,
      branchRows: branchRows as List<dynamic>,
      serviceRows: serviceRows as List<dynamic>,
      barberRows: barberRows as List<dynamic>,
    );
  }
}
