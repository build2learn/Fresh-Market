import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/domain/usecases/category/get_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/category/watch_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/category/toggle_visibility.usecase.dart';
import 'package:fresh_market/domain/usecases/category/reorder_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/category/delete_category.usecase.dart';
import 'package:fresh_market/domain/usecases/category/restore_category.usecase.dart';
import 'category_list_provider.dart';

final _getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository: repo);
});

final _watchCategoriesUseCaseProvider = Provider<WatchCategoriesUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return WatchCategoriesUseCase(repository: repo);
});

final _deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return DeleteCategoryUseCase(repository: repo);
});

final _restoreCategoryUseCaseProvider = Provider<RestoreCategoryUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return RestoreCategoryUseCase(repository: repo);
});

final _toggleVisibilityUseCaseProvider = Provider<ToggleVisibilityUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return ToggleVisibilityUseCase(repository: repo);
});

final _reorderCategoriesUseCaseProvider = Provider<ReorderCategoriesUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return ReorderCategoriesUseCase(repository: repo);
});

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, CategoryListState>((ref) {
  return CategoryListNotifier(
    getCategories: ref.watch(_getCategoriesUseCaseProvider),
    watchCategories: ref.watch(_watchCategoriesUseCaseProvider),
    toggleVisibility: ref.watch(_toggleVisibilityUseCaseProvider),
    reorderCategories: ref.watch(_reorderCategoriesUseCaseProvider),
    deleteCategory: ref.watch(_deleteCategoryUseCaseProvider),
    restoreCategory: ref.watch(_restoreCategoryUseCaseProvider),
  );
});
