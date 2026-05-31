import 'dart:async';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

class WatchProductsUseCase {
  final ProductRepository _repository;

  WatchProductsUseCase({required ProductRepository repository})
      : _repository = repository;

  Stream<List<ProductEntity>> call({int limit = 20}) {
    return _repository.watchProducts(limit: limit);
  }
}

class WatchFeaturedProductsUseCase {
  final ProductRepository _repository;

  WatchFeaturedProductsUseCase({required ProductRepository repository})
      : _repository = repository;

  Stream<List<ProductEntity>> call({int limit = 20}) {
    return _repository.watchFeaturedProducts(limit: limit);
  }
}
