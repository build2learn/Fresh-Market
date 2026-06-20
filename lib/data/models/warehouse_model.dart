import '../dto/warehouse.dto.dart';
import '../../domain/entities/warehouse.entity.dart';

class WarehouseModel extends WarehouseDto {
  const WarehouseModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.locationAr,
    required super.locationEn,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WarehouseModel.fromDto(WarehouseDto dto) {
    return WarehouseModel(
      id: dto.id,
      nameAr: dto.nameAr,
      nameEn: dto.nameEn,
      locationAr: dto.locationAr,
      locationEn: dto.locationEn,
      isActive: dto.isActive,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory WarehouseModel.fromEntity(WarehouseEntity entity) {
    return WarehouseModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      locationAr: entity.locationAr,
      locationEn: entity.locationEn,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  WarehouseEntity toEntity() {
    return WarehouseEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      locationAr: locationAr,
      locationEn: locationEn,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
