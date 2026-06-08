import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/catalog/domain/repositories/catalog_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

export 'catalog_event.dart';
export 'catalog_state.dart';

@injectable
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final CatalogRepository _repository;
  final TenantThemeBloc _tenantThemeBloc;

  CatalogBloc(this._repository, this._tenantThemeBloc)
      : super(const CatalogState()) {
    on<CatalogLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(CatalogLoadEvent event, Emitter<CatalogState> emit) async {
    if (state.status == CatalogStatus.loading ||
        state.status == CatalogStatus.loaded) {
      return;
    }
    final tenantId = _tenantThemeBloc.state.tenantId;
    if (tenantId.isEmpty || tenantId == kDefaultTenantId) {
      emit(state.copyWith(status: CatalogStatus.error));
      return;
    }
    emit(state.copyWith(status: CatalogStatus.loading));
    try {
      final catalog = await _repository.fetchCatalog(tenantId: tenantId);
      emit(state.copyWith(
        status: CatalogStatus.loaded,
        centers: catalog.centers,
        services: catalog.services,
        team: catalog.team,
      ));
    } catch (_) {
      emit(state.copyWith(status: CatalogStatus.error));
    }
  }
}
