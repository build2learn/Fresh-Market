import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';

class ToggleActiveUseCase {
  final OfferRepository _repository;

  ToggleActiveUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String offerId, bool isActive) {
    return _repository.toggleActive(offerId, isActive);
  }
}
