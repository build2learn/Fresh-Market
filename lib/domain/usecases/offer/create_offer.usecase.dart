import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';

class CreateOfferUseCase {
  final OfferRepository _repository;

  CreateOfferUseCase({required OfferRepository repository})
      : _repository = repository;

  Future<Result<OfferEntity>> call(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  }) {
    if (offer.titleAr.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Arabic title is required', code: 'validation'),
      ));
    }
    if (offer.titleEn.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'English title is required', code: 'validation'),
      ));
    }
    if (offer.endDate.isBefore(offer.startDate)) {
      return Future.value(Failure(
        ValidationException(message: 'End date must be after start date', code: 'validation'),
      ));
    }
    return _repository.createOffer(offer, productIds, imagePath: imagePath);
  }
}
