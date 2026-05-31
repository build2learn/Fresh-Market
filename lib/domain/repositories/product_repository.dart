import 'dart:async';
import '../entities/product.entity.dart';
import '../../core/utils/result.dart';

abstract interface class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts({
    required int limit,
    dynamic lastDoc,
    String? categoryId,
  });
  Future<Result<ProductEntity>> getProduct(String id);
  Future<Result<List<ProductEntity>>> getFeaturedProducts({int limit = 20});
  Stream<List<ProductEntity>> watchProducts({int limit = 20});
  Stream<List<ProductEntity>> watchFeaturedProducts({int limit = 20});
  Future<Result<ProductEntity>> createProduct(ProductEntity product, {String? imagePath});
  Future<Result<ProductEntity>> updateProduct(ProductEntity product, {String? imagePath});
  Future<Result<void>> deleteProduct(String productId);
  Future<Result<void>> toggleFeatured(String productId, bool isFeatured);
  Future<Result<void>> toggleAvailability(String productId, bool isAvailable);
}
