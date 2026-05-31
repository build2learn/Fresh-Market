import '../dto/weight_unit.dto.dart';
import '../../domain/entities/weight_unit.entity.dart';

class WeightUnitModel extends WeightUnitDto {
  const WeightUnitModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.abbr,
    super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WeightUnitModel.fromDto(WeightUnitDto dto) {
    return WeightUnitModel(
      id: dto.id,
      nameAr: dto.nameAr,
      nameEn: dto.nameEn,
      abbr: dto.abbr,
      sortOrder: dto.sortOrder,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory WeightUnitModel.fromEntity(WeightUnitEntity entity) {
    return WeightUnitModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      abbr: entity.abbr,
      sortOrder: entity.sortOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  WeightUnitEntity toEntity() {
    return WeightUnitEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      abbr: abbr,
      sortOrder: sortOrder,
    );
  }
}
