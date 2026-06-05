import 'package:trim_flow/features/catalog/domain/models/tenant_catalog.dart';

abstract class CatalogRepository {
  Future<TenantCatalog> fetchCatalog({required String tenantId});
}
