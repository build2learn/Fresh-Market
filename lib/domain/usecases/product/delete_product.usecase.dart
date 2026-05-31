import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String productId) {
    return _repository.deleteProduct(productId);
  }
}
