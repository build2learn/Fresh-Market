import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<List<ProductEntity>>> call({
    int limit = 20,
    dynamic lastDoc,
    String? categoryId,
  }) {
    return _repository.getProducts(limit: limit, lastDoc: lastDoc, categoryId: categoryId);
  }
}

class GetProductUseCase {
  final ProductRepository _repository;

  GetProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<ProductEntity>> call(String id) {
    return _repository.getProduct(id);
  }
}

class GetFeaturedProductsUseCase {
  final ProductRepository _repository;

  GetFeaturedProductsUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<List<ProductEntity>>> call({int limit = 20}) {
    return _repository.getFeaturedProducts(limit: limit);
  }
}
