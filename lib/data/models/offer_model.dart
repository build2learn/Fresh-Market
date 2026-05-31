import '../dto/offer.dto.dart';
import '../../domain/entities/offer.entity.dart';

class OfferModel extends OfferDto {
  const OfferModel({
    required super.id,
    required super.titleAr,
    required super.titleEn,
    super.descriptionAr,
    super.descriptionEn,
    super.imageUrl,
    super.isActive,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OfferModel.fromDto(OfferDto dto) {
    return OfferModel(
      id: dto.id,
      titleAr: dto.titleAr,
      titleEn: dto.titleEn,
      descriptionAr: dto.descriptionAr,
      descriptionEn: dto.descriptionEn,
      imageUrl: dto.imageUrl,
      isActive: dto.isActive,
      startDate: dto.startDate,
      endDate: dto.endDate,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  OfferEntity toEntity() {
    return OfferEntity(
      id: id,
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      imageUrl: imageUrl,
      isActive: isActive,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
