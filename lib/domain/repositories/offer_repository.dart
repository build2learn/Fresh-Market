import 'dart:async';
import '../entities/offer.entity.dart';
import '../entities/product.entity.dart';
import '../../core/utils/result.dart';

abstract interface class OfferRepository {
  Future<Result<List<OfferEntity>>> getOffers();
  Future<Result<List<OfferEntity>>> getActiveOffers();
  Future<Result<OfferEntity>> getOffer(String id);
  Future<Result<List<ProductEntity>>> getOfferProducts(String offerId);
  Stream<List<OfferEntity>> watchActiveOffers();
  Future<Result<OfferEntity>> createOffer(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  });
  Future<Result<OfferEntity>> updateOffer(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  });
  Future<Result<void>> toggleActive(String offerId, bool isActive);
  Future<Result<void>> deleteOffer(String offerId);
}
