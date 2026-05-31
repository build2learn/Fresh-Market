import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/usecases/category/delete_category.usecase.dart';
import 'package:fresh_market/domain/usecases/category/get_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/category/restore_category.usecase.dart';
import 'package:fresh_market/domain/usecases/category/toggle_visibility.usecase.dart';
import 'package:fresh_market/domain/usecases/category/reorder_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/category/watch_categories.usecase.dart';

class CategoryListState {
  final List<CategoryEntity> categories;
  final RequestState requestState;
  final String? errorMessage;
  final bool isReordering;

  const CategoryListState({
    this.categories = const [],
    this.requestState = RequestState.idle,
    this.errorMessage,
    this.isReordering = false,
  });

  CategoryListState copyWith({
    List<CategoryEntity>? categories,
    RequestState? requestState,
    String? errorMessage,
    bool? isReordering,
  }) {
    return CategoryListState(
      categories: categories ?? this.categories,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,
      isReordering: isReordering ?? this.isReordering,
    );
  }
}

class CategoryListNotifier extends StateNotifier<CategoryListState> {
  final GetCategoriesUseCase _getCategories;
  final WatchCategoriesUseCase _watchCategories;
  final ToggleVisibilityUseCase _toggleVisibility;
  final ReorderCategoriesUseCase _reorderCategories;
  final DeleteCategoryUseCase _deleteCategory;
  final RestoreCategoryUseCase _restoreCategory;

  StreamSubscription<List<CategoryEntity>>? _realtimeSubscription;

  CategoryListNotifier({
    required GetCategoriesUseCase getCategories,
    required WatchCategoriesUseCase watchCategories,
    required ToggleVisibilityUseCase toggleVisibility,
    required ReorderCategoriesUseCase reorderCategories,
    required DeleteCategoryUseCase deleteCategory,
    required RestoreCategoryUseCase restoreCategory,
  })  : _getCategories = getCategories,
        _watchCategories = watchCategories,
        _toggleVisibility = toggleVisibility,
        _reorderCategories = reorderCategories,
        _deleteCategory = deleteCategory,
        _restoreCategory = restoreCategory,
        super(const CategoryListState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getCategories();
    if (result is Success<List<CategoryEntity>>) {
      state = state.copyWith(
        categories: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<CategoryEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  void startRealtimeSync() {
    _realtimeSubscription = _watchCategories().listen((categories) {
      if (mounted) {
        state = state.copyWith(
          categories: categories,
          requestState: RequestState.success,
        );
      }
    });
  }

  void stopRealtimeSync() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  Future<void> refresh() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getCategories();
    if (result is Success<List<CategoryEntity>>) {
      state = state.copyWith(
        categories: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<CategoryEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> toggleVisibility(String categoryId, bool currentVisible) async {
    final result = await _toggleVisibility(categoryId, !currentVisible);
    if (result is Success<void>) {
      return null;
    } else if (result is Failure<void>) {
      return result.error.message;
    }
    return null;
  }

  Future<String?> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final updated = List<CategoryEntity>.from(state.categories);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    state = state.copyWith(categories: updated, isReordering: true);

    final ids = updated.map((c) => c.id).toList();
    final result = await _reorderCategories(ids);
    if (result is Success<void>) {
      state = state.copyWith(isReordering: false);
      return null;
    } else {
      refresh();
      if (result is Failure<void>) {
        return result.error.message;
      }
      return 'Reorder failed';
    }
  }

  Future<String?> deleteCategory(String categoryId) async {
    final result = await _deleteCategory(categoryId);
    if (result is Success<void>) {
      state = state.copyWith(
        categories: state.categories.where((c) => c.id != categoryId).toList(),
      );
      return null;
    } else if (result is Failure<void>) {
      return result.error.message;
    }
    return null;
  }

  Future<String?> restoreCategory(String categoryId) async {
    final result = await _restoreCategory(categoryId);
    if (result is Success<void>) {
      return null;
    } else if (result is Failure<void>) {
      return result.error.message;
    }
    return null;
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
