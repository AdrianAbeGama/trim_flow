import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc(this._homeRepository) : super(const HomeState()) {
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
  }

  Future<void> _onLoad(LoadHomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final content = await _homeRepository.getHomeContent();
      emit(state.copyWith(status: HomeStatus.loaded, content: content));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error));
    }
  }

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
