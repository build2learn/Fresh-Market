import 'dart:async';
import 'dart:math';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/product.entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firebase/product_firebase_datasource.dart';
import '../datasources/local/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductFirebaseDataSource _firebaseDataSource;
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl({
    required ProductFirebaseDataSource firebaseDataSource,
    required ProductLocalDataSource localDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    int limit = 20,
    dynamic lastDoc,
    String? categoryId,
  }) async {
    try {
      final dtos = await _firebaseDataSource.getProducts(
        limit: limit,
        lastDoc: lastDoc,
        categoryId: categoryId,
      );
      final entities = dtos.map((dto) => ProductModel.fromDto(dto).toEntity()).toList();
      if (categoryId == null) {
        await _localDataSource.cacheAll(dtos);
      }
      return Success(entities);
    } on AppException catch (e) {
      if (categoryId != null) return Failure(e);
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached.map((dto) => ProductModel.fromDto(dto).toEntity()).toList();
        return Success(entities);
      }
      return Failure(e);
    } catch (e) {
      if (categoryId != null) {
        return Failure(FirestoreException(message: e.toString()));
      }
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached.map((dto) => ProductModel.fromDto(dto).toEntity()).toList();
        return Success(entities);
      }
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> getProduct(String id) async {
    try {
      final dto = await _firebaseDataSource.getProduct(id);
      if (dto == null) {
        return Failure(FirestoreException(message: 'Product not found'));
      }
      return Success(ProductModel.fromDto(dto).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getFeaturedProducts({int limit = 20}) async {
    try {
      final dtos = await _firebaseDataSource.getFeaturedProducts(limit: limit);
      final entities = dtos.map((dto) => ProductModel.fromDto(dto).toEntity()).toList();
      return Success(entities);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<ProductEntity>> watchProducts({int limit = 20}) {
    return _firebaseDataSource.watchProducts(limit: limit).map(
      (dtos) => dtos.map((dto) => ProductModel.fromDto(dto).toEntity()).toList(),
    );
  }

  @override
  Stream<List<ProductEntity>> watchFeaturedProducts({int limit = 20}) {
    return _firebaseDataSource.watchFeaturedProducts(limit: limit).map(
      (dtos) => dtos.map((dto) => ProductModel.fromDto(dto).toEntity()).toList(),
    );
  }

  @override
  Future<Result<ProductEntity>> createProduct(ProductEntity product, {String? imagePath}) async {
    try {
      final id = product.id.isEmpty ? _generateId() : product.id;
      final dto = ProductModel.fromEntity(product.copyWith(id: id));
      final created = await _firebaseDataSource.createProduct(dto, imagePath: imagePath);
      return Success(ProductModel.fromDto(created).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<ProductEntity>> updateProduct(ProductEntity product, {String? imagePath}) async {
    try {
      final dto = ProductModel.fromEntity(product);
      final updated = await _firebaseDataSource.updateProduct(dto, imagePath: imagePath);
      return Success(ProductModel.fromDto(updated).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String productId) async {
    try {
      await _firebaseDataSource.deleteProduct(productId);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> toggleFeatured(String productId, bool isFeatured) async {
    try {
      await _firebaseDataSource.toggleFeatured(productId, isFeatured);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> toggleAvailability(String productId, bool isAvailable) async {
    try {
      await _firebaseDataSource.toggleAvailability(productId, isAvailable);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
