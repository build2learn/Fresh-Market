import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

class ToggleFeaturedUseCase {
  final ProductRepository _repository;

  ToggleFeaturedUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String productId, bool isFeatured) {
    return _repository.toggleFeatured(productId, isFeatured);
  }
}

class ToggleAvailabilityUseCase {
  final ProductRepository _repository;

  ToggleAvailabilityUseCase({required ProductRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String productId, bool isAvailable) {
    return _repository.toggleAvailability(productId, isAvailable);
  }
}
