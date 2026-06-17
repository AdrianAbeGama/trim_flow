import 'dart:async';

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
  StreamSubscription<dynamic>? _tenantSub;

  CatalogBloc(this._repository, this._tenantThemeBloc)
      : super(const CatalogState()) {
    on<CatalogLoadEvent>(_onLoad);
    // Recarga el catálogo cuando el usuario cambia de barbería (tenant), para
    // no reservar con datos de la barbería anterior.
    _tenantSub = _tenantThemeBloc.stream.listen((s) {
      if (s.tenantId.isNotEmpty &&
          s.tenantId != kDefaultTenantId &&
          s.tenantId != state.loadedTenantId) {
        add(const CatalogEvent.load());
      }
    });
  }

  Future<void> _onLoad(CatalogLoadEvent event, Emitter<CatalogState> emit) async {
    final tenantId = _tenantThemeBloc.state.tenantId;
    if (tenantId.isEmpty || tenantId == kDefaultTenantId) {
      emit(state.copyWith(status: CatalogStatus.error));
      return;
    }
    // Ya cargado para ESTE tenant → nada que hacer. (Si cambió el tenant, se
    // recarga.)
    if (state.status == CatalogStatus.loading) return;
    if (state.status == CatalogStatus.loaded &&
        state.loadedTenantId == tenantId) {
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
        loadedTenantId: tenantId,
      ));
    } catch (_) {
      emit(state.copyWith(status: CatalogStatus.error));
    }
  }

  @override
  Future<void> close() {
    _tenantSub?.cancel();
    return super.close();
  }
}
