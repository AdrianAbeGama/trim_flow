import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_state.dart';

@injectable
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepository _repository;

  GalleryBloc(this._repository) : super(const GalleryState()) {
    on<GalleryLoadRequested>(_onLoad);
    on<GalleryCategoryChanged>(_onCategoryChanged);
    on<GallerySearchChanged>(_onSearchChanged);
    on<GalleryEditModeToggled>(_onToggleEdit);
    on<GalleryItemAdded>(_onItemAdded);
    on<GalleryItemDeleted>(_onItemDeleted);
    on<GalleryShowFeaturedToggled>(_onToggleShowFeatured);
    on<GalleryItemToggledFeatured>(_onItemToggledFeatured);
    on<GalleryCategoryAdded>(_onCategoryAdded);
    on<GalleryCategoryUpdated>(_onCategoryUpdated);
    on<GalleryCategoryDeleted>(_onCategoryDeleted);
    on<GalleryFilterModeChanged>(_onFilterModeChanged);
    on<GalleryBarberSelected>(_onBarberSelected);
  }

  void _onFilterModeChanged(GalleryFilterModeChanged event, Emitter<GalleryState> emit) {
    if (event.mode == state.filterMode) return;
    emit(state.copyWith(
      filterMode: event.mode,
      selectedCategorySlug: null,
      selectedBarberName: null,
    ));
  }

  void _onBarberSelected(GalleryBarberSelected event, Emitter<GalleryState> emit) {
    final next = event.barberName == state.selectedBarberName ? null : event.barberName;
    emit(state.copyWith(selectedBarberName: next));
  }

  Future<void> _onLoad(GalleryLoadRequested event, Emitter<GalleryState> emit) async {
    emit(state.copyWith(status: GalleryStatus.loading, errorMessage: null));
    try {
      await _repository.ensureSeeded();
      final items = await _repository.loadAll();
      final cats = await _repository.loadCategories();
      emit(state.copyWith(
        status: GalleryStatus.loaded,
        allItems: items,
        categories: cats,
      ));
    } catch (e, stack) {
      debugPrint('GalleryBloc.load error: $e\n$stack');
      emit(state.copyWith(
        status: GalleryStatus.error,
        errorMessage: 'No pudimos cargar la galeria.',
      ));
    }
  }

  void _onCategoryChanged(GalleryCategoryChanged event, Emitter<GalleryState> emit) {
    final next = event.slug == state.selectedCategorySlug ? null : event.slug;
    emit(state.copyWith(selectedCategorySlug: next));
  }

  void _onSearchChanged(GallerySearchChanged event, Emitter<GalleryState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onToggleEdit(GalleryEditModeToggled event, Emitter<GalleryState> emit) {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  Future<void> _onItemAdded(GalleryItemAdded event, Emitter<GalleryState> emit) async {
    try {
      await _repository.addItem(event.item);
      final items = await _repository.loadAll();
      final cats = await _repository.loadCategories();
      emit(state.copyWith(allItems: items, categories: cats));
    } catch (e) {
      debugPrint('GalleryBloc.add error: $e');
    }
  }

  Future<void> _onItemDeleted(GalleryItemDeleted event, Emitter<GalleryState> emit) async {
    try {
      await _repository.deleteItem(event.boxKey);
      final items = await _repository.loadAll();
      final cats = await _repository.loadCategories();
      emit(state.copyWith(allItems: items, categories: cats));
    } catch (e) {
      debugPrint('GalleryBloc.delete error: $e');
    }
  }

  void _onToggleShowFeatured(GalleryShowFeaturedToggled event, Emitter<GalleryState> emit) {
    emit(state.copyWith(showOnlyFeatured: !state.showOnlyFeatured));
  }

  Future<void> _onItemToggledFeatured(GalleryItemToggledFeatured event, Emitter<GalleryState> emit) async {
    try {
      final index = state.allItems.indexWhere((it) => it.id == event.boxKey);
      if (index == -1) return;
      
      final current = state.allItems[index];
      final updated = current.copyWith(isFeatured: !current.isFeatured);
      
      await _repository.updateItem(updated);
      
      final items = await _repository.loadAll();
      emit(state.copyWith(allItems: items));
    } catch (e) {
      debugPrint('GalleryBloc.toggleFeatured error: $e');
    }
  }

  Future<void> _onCategoryAdded(GalleryCategoryAdded event, Emitter<GalleryState> emit) async {
    try {
      final newCat = GalleryCategory(
        slug: event.label.toLowerCase().replaceAll(' ', '_'),
        label: event.label,
      );
      await _repository.addCategory(newCat);
      final cats = await _repository.loadCategories();
      emit(state.copyWith(categories: cats));
    } catch (e) {
      debugPrint('GalleryBloc.addCategory error: $e');
    }
  }

  Future<void> _onCategoryUpdated(GalleryCategoryUpdated event, Emitter<GalleryState> emit) async {
    try {
      final newCat = GalleryCategory(
        slug: event.newLabel.toLowerCase().replaceAll(' ', '_'),
        label: event.newLabel,
      );
      await _repository.updateCategory(event.oldSlug, newCat);
      final items = await _repository.loadAll();
      final cats = await _repository.loadCategories();
      emit(state.copyWith(allItems: items, categories: cats));
    } catch (e) {
      debugPrint('GalleryBloc.updateCategory error: $e');
    }
  }

  Future<void> _onCategoryDeleted(GalleryCategoryDeleted event, Emitter<GalleryState> emit) async {
    try {
      await _repository.deleteCategory(event.slug);
      final items = await _repository.loadAll();
      final cats = await _repository.loadCategories();
      emit(state.copyWith(allItems: items, categories: cats));
    } catch (e) {
      debugPrint('GalleryBloc.deleteCategory error: $e');
    }
  }
}
