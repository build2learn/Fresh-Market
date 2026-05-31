import 'dart:async';
import '../entities/category.entity.dart';
import '../../core/utils/result.dart';

abstract interface class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getCategories();
  Future<Result<List<CategoryEntity>>> getVisibleCategories();
  Future<Result<List<CategoryEntity>>> getDeletedCategories();
  Stream<List<CategoryEntity>> watchCategories();
  Future<Result<CategoryEntity>> createCategory(CategoryEntity category);
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category);
  Future<Result<void>> toggleVisibility(String categoryId, bool isVisible);
  Future<Result<void>> reorderCategories(List<String> categoryIds);
  Future<Result<void>> deleteCategory(String categoryId);
  Future<Result<void>> restoreCategory(String categoryId);
}
