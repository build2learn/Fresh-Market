import 'dart:async';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';

class WatchActiveOffersUseCase {
  final OfferRepository _repository;

  WatchActiveOffersUseCase({required OfferRepository repository})
      : _repository = repository;

  Stream<List<OfferEntity>> call() {
    return _repository.watchActiveOffers();
  }
}
