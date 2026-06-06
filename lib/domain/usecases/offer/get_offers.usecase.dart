import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';

class GetOffersUseCase {
  final OfferRepository _repository;

  GetOffersUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<List<OfferEntity>>> call() {
    return _repository.getOffers();
  }
}

class GetActiveOffersUseCase {
  final OfferRepository _repository;

  GetActiveOffersUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<List<OfferEntity>>> call() {
    return _repository.getActiveOffers();
  }
}

class GetOfferUseCase {
  final OfferRepository _repository;

  GetOfferUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<OfferEntity>> call(String id) {
    return _repository.getOffer(id);
  }
}

class GetOfferProductsUseCase {
  final OfferRepository _repository;

  GetOfferProductsUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<List<ProductEntity>>> call(String offerId) {
    return _repository.getOfferProducts(offerId);
  }
}
