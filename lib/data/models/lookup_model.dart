import '../dto/lookup.dto.dart';
import '../../domain/entities/lookup.entity.dart';

class LookupModel extends LookupDto {
  const LookupModel({
    required super.id,
    required super.lookupType,
    required super.code,
    required super.nameAr,
    required super.nameEn,
    required super.isActive,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
  });

  factory LookupModel.fromDto(LookupDto dto) {
    return LookupModel(
      id: dto.id,
      lookupType: dto.lookupType,
      code: dto.code,
      nameAr: dto.nameAr,
      nameEn: dto.nameEn,
      isActive: dto.isActive,
      sortOrder: dto.sortOrder,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      imageUrl: dto.imageUrl,
    );
  }

  factory LookupModel.fromEntity(LookupEntity entity) {
    return LookupModel(
      id: entity.id,
      lookupType: entity.lookupType,
      code: entity.code,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      imageUrl: entity.imageUrl,
    );
  }

  LookupEntity toEntity() {
    return LookupEntity(
      id: id,
      lookupType: lookupType,
      code: code,
      nameAr: nameAr,
      nameEn: nameEn,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imageUrl: imageUrl,
    );
  }
}
