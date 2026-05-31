import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';

class DeleteOfferUseCase {
  final OfferRepository _repository;

  DeleteOfferUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String offerId) {
    return _repository.deleteOffer(offerId);
  }
}
