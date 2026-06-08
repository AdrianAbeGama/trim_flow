import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/catalog/domain/repositories/catalog_repository.dart';
import '../../domain/models/home_content.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  final CatalogRepository _catalogRepository;
  final TenantThemeBloc _tenantThemeBloc;
  StreamSubscription<TenantThemeState>? _tenantSub;
  String _lastTenantId = '';

  HomeBloc(this._homeRepository, this._catalogRepository, this._tenantThemeBloc)
      : super(const HomeState()) {
    on<LoadHomeEvent>(_onLoad);
    on<ToggleHomeEditMode>(_onToggleEditMode);
    on<UpdateHomeContent>(_onUpdateContent);
    on<UpdateHomeHero>(_onUpdateHero);
    on<UpdateHomeAboutUs>(_onUpdateAboutUs);
    on<UpdateHomeSocialLink>(_onUpdateSocialLink);
    on<UpdateHomeLocation>(_onUpdateLocation);
    on<AddHomeStory>(_onAddStory);
    on<RemoveHomeStory>(_onRemoveStory);
    on<AddHomeService>(_onAddService);
    on<UpdateHomeService>(_onUpdateService);
    on<RemoveHomeService>(_onRemoveService);
    on<AddHomeProduct>(_onAddProduct);
    on<UpdateHomeProduct>(_onUpdateProduct);
    on<RemoveHomeProduct>(_onRemoveProduct);

    _lastTenantId = _tenantThemeBloc.state.tenantId;
    _tenantSub = _tenantThemeBloc.stream.listen((s) {
      if (s.tenantId.isNotEmpty && s.tenantId != _lastTenantId) {
        _lastTenantId = s.tenantId;
        add(const LoadHomeEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _tenantSub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadHomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final content = await _homeRepository.getHomeContent();
      final merged = await _mergeRealCatalog(content);
      emit(state.copyWith(status: HomeStatus.loaded, content: merged));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error));
    }
  }

  /// Sustituye servicios y sedes del Home por los reales del tenant (tablas
  /// `services` y `branches`). Hero, productos, looks y "sobre nosotros" siguen
  /// viniendo del contenido local hasta que el socio entregue esas tablas.
  Future<HomeContent> _mergeRealCatalog(HomeContent content) async {
    final tenantId = _tenantThemeBloc.state.tenantId;
    if (tenantId.isEmpty || tenantId == kDefaultTenantId) return content;
    try {
      final catalog = await _catalogRepository.fetchCatalog(tenantId: tenantId);
      final services = catalog.services.map(_serviceToMap).toList();
      final locations = catalog.centers.map(_centerToMap).toList();
      return content.copyWith(
        services: services.isNotEmpty ? services : content.services,
        locations: locations.isNotEmpty ? locations : content.locations,
      );
    } catch (_) {
      return content;
    }
  }

  Map<String, String> _serviceToMap(Service s) {
    final p = s.price;
    final priceStr =
        p == p.roundToDouble() ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
    return {
      'title': s.name,
      'desc': '',
      'price': 'S/ $priceStr',
      'time': '${s.durationInMinutes} min',
      'img': '',
      'featured': s.isFeatured ? 'true' : '',
    };
  }

  Map<String, String> _centerToMap(BarberCenter c) => {
        'label': c.name,
        'address': c.location,
        'mapUrl': '',
        'img': '',
      };

  void _onToggleEditMode(ToggleHomeEditMode event, Emitter<HomeState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void _onUpdateContent(UpdateHomeContent event, Emitter<HomeState> emit) {
    emit(state.copyWith(content: event.content));
  }

  Future<void> _onUpdateHero(UpdateHomeHero event, Emitter<HomeState> emit) async {
    final updatedContent = state.content.copyWith(
      heroTitle: event.title ?? state.content.heroTitle,
      heroSubtitle: event.subtitle ?? state.content.heroSubtitle,
      heroImageUrl: event.imageUrl ?? state.content.heroImageUrl,
      heroTag1: event.tag1 ?? state.content.heroTag1,
      heroTag2: event.tag2 ?? state.content.heroTag2,
    );
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onUpdateAboutUs(UpdateHomeAboutUs event, Emitter<HomeState> emit) async {
    final updatedContent = state.content.copyWith(
      aboutUsTitle: event.title ?? state.content.aboutUsTitle,
      aboutUsText: event.text ?? state.content.aboutUsText,
      aboutUsImageUrl: event.imageUrl ?? state.content.aboutUsImageUrl,
      aboutUsVideoUrl: event.videoUrl ?? state.content.aboutUsVideoUrl,
    );
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onUpdateSocialLink(UpdateHomeSocialLink event, Emitter<HomeState> emit) async {
    final updatedSocial = Map<String, String>.from(state.content.socialLinks)..[event.platform] = event.url;
    final updatedContent = state.content.copyWith(socialLinks: updatedSocial);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onUpdateLocation(UpdateHomeLocation event, Emitter<HomeState> emit) async {
    final updatedLocations = List<Map<String, String>>.from(state.content.locations)..[event.index] = event.location;
    final updatedContent = state.content.copyWith(locations: updatedLocations);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onAddStory(AddHomeStory event, Emitter<HomeState> emit) async {
    final updatedStories = List<Map<String, String>>.from(state.content.stories)..add(event.story);
    final updatedContent = state.content.copyWith(stories: updatedStories);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onRemoveStory(RemoveHomeStory event, Emitter<HomeState> emit) async {
    final updatedStories = List<Map<String, String>>.from(state.content.stories)..removeAt(event.index);
    final updatedContent = state.content.copyWith(stories: updatedStories);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onAddService(AddHomeService event, Emitter<HomeState> emit) async {
    final updatedServices = List<Map<String, String>>.from(state.content.services)..add(event.service);
    final updatedContent = state.content.copyWith(services: updatedServices);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onUpdateService(UpdateHomeService event, Emitter<HomeState> emit) async {
    final updatedServices = List<Map<String, String>>.from(state.content.services)..[event.index] = event.service;
    final updatedContent = state.content.copyWith(services: updatedServices);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onRemoveService(RemoveHomeService event, Emitter<HomeState> emit) async {
    final updatedServices = List<Map<String, String>>.from(state.content.services)..removeAt(event.index);
    final updatedContent = state.content.copyWith(services: updatedServices);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onAddProduct(AddHomeProduct event, Emitter<HomeState> emit) async {
    final updatedProducts = List<Map<String, String>>.from(state.content.products)..add(event.product);
    final updatedContent = state.content.copyWith(products: updatedProducts);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onUpdateProduct(UpdateHomeProduct event, Emitter<HomeState> emit) async {
    final updatedProducts = List<Map<String, String>>.from(state.content.products)..[event.index] = event.product;
    final updatedContent = state.content.copyWith(products: updatedProducts);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }

  Future<void> _onRemoveProduct(RemoveHomeProduct event, Emitter<HomeState> emit) async {
    final updatedProducts = List<Map<String, String>>.from(state.content.products)..removeAt(event.index);
    final updatedContent = state.content.copyWith(products: updatedProducts);
    emit(state.copyWith(content: updatedContent));
    await _homeRepository.saveHomeContent(updatedContent);
  }
}
