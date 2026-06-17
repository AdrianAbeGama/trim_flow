import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trim_flow/features/catalog/domain/models/tenant_catalog.dart';

part 'catalog_state.freezed.dart';

enum CatalogStatus { initial, loading, loaded, error }

@freezed
abstract class CatalogState with _$CatalogState {
  const factory CatalogState({
    @Default(CatalogStatus.initial) CatalogStatus status,
    @Default(<BarberCenter>[]) List<BarberCenter> centers,
    @Default(<Service>[]) List<Service> services,
    @Default(<TeamMember>[]) List<TeamMember> team,
    String? loadedTenantId,
  }) = _CatalogState;
}
