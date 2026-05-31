import 'dart:async';
import 'dart:math';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/category.entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/firebase/category_firebase_datasource.dart';
import '../datasources/local/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryFirebaseDataSource _firebaseDataSource;
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl({
    required CategoryFirebaseDataSource firebaseDataSource,
    required CategoryLocalDataSource localDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    try {
      final dtos = await _firebaseDataSource.getCategories();
      final entities = dtos.map((dto) => CategoryModel.fromDto(dto).toEntity()).toList();
      await _localDataSource.cacheAll(dtos);
      return Success(entities);
    } on AppException catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached
            .where((dto) => !dto.isDeleted)
            .map((dto) => CategoryModel.fromDto(dto).toEntity())
            .toList();
        return Success(entities);
      }
      return Failure(e);
    } catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached
            .where((dto) => !dto.isDeleted)
            .map((dto) => CategoryModel.fromDto(dto).toEntity())
            .toList();
        return Success(entities);
      }
      return Failure(FirestoreException(message: 'Failed to load categories'));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getVisibleCategories() async {
    try {
      final dtos = await _firebaseDataSource.getVisibleCategories();
      final entities = dtos.map((dto) => CategoryModel.fromDto(dto).toEntity()).toList();
      return Success(entities);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to load visible categories'));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getDeletedCategories() async {
    try {
      final dtos = await _firebaseDataSource.getDeletedCategories();
      final entities = dtos.map((dto) => CategoryModel.fromDto(dto).toEntity()).toList();
      return Success(entities);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to load deleted categories'));
    }
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _firebaseDataSource.watchCategories().map(
      (dtos) => dtos.map((dto) => CategoryModel.fromDto(dto).toEntity()).toList(),
    );
  }

  @override
  Future<Result<CategoryEntity>> createCategory(CategoryEntity category) async {
    try {
      final id = category.id.isEmpty ? _generateId() : category.id;
      final dto = CategoryModel.fromEntity(category.copyWith(id: id));
      final created = await _firebaseDataSource.createCategory(dto);
      return Success(CategoryModel.fromDto(created).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to create category'));
    }
  }

  @override
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category) async {
    try {
      final dto = CategoryModel.fromEntity(category);
      final updated = await _firebaseDataSource.updateCategory(dto);
      return Success(CategoryModel.fromDto(updated).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to update category'));
    }
  }

  @override
  Future<Result<void>> toggleVisibility(String categoryId, bool isVisible) async {
    try {
      await _firebaseDataSource.toggleVisibility(categoryId, isVisible);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to toggle visibility'));
    }
  }

  @override
  Future<Result<void>> reorderCategories(List<String> categoryIds) async {
    try {
      await _firebaseDataSource.reorderCategories(categoryIds);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to reorder categories'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String categoryId) async {
    try {
      await _firebaseDataSource.softDeleteCategory(categoryId);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to delete category'));
    }
  }

  @override
  Future<Result<void>> restoreCategory(String categoryId) async {
    try {
      await _firebaseDataSource.restoreCategory(categoryId);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to restore category'));
    }
  }

  String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
