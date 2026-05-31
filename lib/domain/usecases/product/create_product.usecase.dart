import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository _repository;

  CreateProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<ProductEntity>> call(ProductEntity product, {String? imagePath}) {
    if (product.nameAr.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Arabic name is required', code: 'validation'),
      ));
    }
    if (product.nameEn.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'English name is required', code: 'validation'),
      ));
    }
    if (product.price <= 0) {
      return Future.value(Failure(
        ValidationException(message: 'Price must be greater than zero', code: 'validation'),
      ));
    }
    if (product.weight <= 0) {
      return Future.value(Failure(
        ValidationException(message: 'Weight must be greater than zero', code: 'validation'),
      ));
    }
    if (product.weightUnitId.isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Weight unit is required', code: 'validation'),
      ));
    }
    if (product.categoryId.isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Category is required', code: 'validation'),
      ));
    }
    return _repository.createProduct(product, imagePath: imagePath);
  }
}
