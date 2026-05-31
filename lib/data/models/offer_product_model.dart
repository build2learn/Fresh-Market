import '../dto/offer_product.dto.dart';
import '../../domain/entities/offer_product.entity.dart';

class OfferProductModel extends OfferProductDto {
  const OfferProductModel({
    required super.id,
    required super.offerId,
    required super.productId,
    required super.createdAt,
  });

  factory OfferProductModel.fromDto(OfferProductDto dto) {
    return OfferProductModel(
      id: dto.id,
      offerId: dto.offerId,
      productId: dto.productId,
      createdAt: dto.createdAt,
    );
  }

  factory OfferProductModel.fromEntity(OfferProductEntity entity) {
    return OfferProductModel(
      id: entity.id,
      offerId: entity.offerId,
      productId: entity.productId,
      createdAt: entity.createdAt,
    );
  }

  OfferProductEntity toEntity() {
    return OfferProductEntity(
      id: id,
      offerId: offerId,
      productId: productId,
      createdAt: createdAt,
    );
  }
}
