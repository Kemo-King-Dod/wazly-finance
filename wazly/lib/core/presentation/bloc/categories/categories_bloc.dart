import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wazly/core/domain/usecases/category_usecases.dart';
import 'package:wazly/core/domain/entities/category_entity.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryUseCases _useCases;
  StreamSubscription? _categoriesSubscription;

  CategoriesBloc({required CategoryUseCases useCases})
    : _useCases = useCases,
      super(CategoriesInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<_CategoriesUpdatedEvent>(_onCategoriesUpdated);
    on<_CategoriesErrorEvent>(_onCategoriesError);
  }

  void _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoriesState> emit,
  ) {
    emit(CategoriesLoading());
    _categoriesSubscription?.cancel();

    _categoriesSubscription = _useCases
        .watchCategories(event.type)
        .listen(
          (categories) {
            add(
              _CategoriesUpdatedEvent(categories: categories, type: event.type),
            );
          },
          onError: (error) {
            add(_CategoriesErrorEvent(error.toString()));
          },
        );
  }

  void _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await _useCases.addCategory(event.category);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  void _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await _useCases.updateCategory(event.category);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  void _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      await _useCases.deleteCategory(event.id);
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }

  // Handle internal events from the stream
  void _onCategoriesUpdated(
    _CategoriesUpdatedEvent event,
    Emitter<CategoriesState> emit,
  ) {
    emit(CategoriesLoaded(categories: event.categories, type: event.type));
  }

  void _onCategoriesError(
    _CategoriesErrorEvent event,
    Emitter<CategoriesState> emit,
  ) {
    emit(CategoriesError(event.message));
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream handling
class _CategoriesUpdatedEvent extends CategoriesEvent {
  final List<CategoryEntity> categories;
  final int type;

  const _CategoriesUpdatedEvent({required this.categories, required this.type});

  @override
  List<Object?> get props => [categories, type];
}

class _CategoriesErrorEvent extends CategoriesEvent {
  final String message;

  const _CategoriesErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
