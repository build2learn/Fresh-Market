import '../dto/batch.dto.dart';
import '../../domain/entities/batch.entity.dart';

class BatchModel extends BatchDto {
  const BatchModel({
    required super.id,
    required super.productId,
    required super.batchCode,
    required super.initialQuantity,
    required super.currentQuantity,
    required super.availableQuantity,
    required super.reservedQuantity,
    required super.unitCost,
    required super.manufactureDate,
    required super.expiryDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BatchModel.fromDto(BatchDto dto) {
    return BatchModel(
      id: dto.id,
      productId: dto.productId,
      batchCode: dto.batchCode,
      initialQuantity: dto.initialQuantity,
      currentQuantity: dto.currentQuantity,
      availableQuantity: dto.availableQuantity,
      reservedQuantity: dto.reservedQuantity,
      unitCost: dto.unitCost,
      manufactureDate: dto.manufactureDate,
      expiryDate: dto.expiryDate,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory BatchModel.fromEntity(BatchEntity entity) {
    return BatchModel(
      id: entity.id,
      productId: entity.productId,
      batchCode: entity.batchCode,
      initialQuantity: entity.initialQuantity,
      currentQuantity: entity.currentQuantity,
      availableQuantity: entity.availableQuantity,
      reservedQuantity: entity.reservedQuantity,
      unitCost: entity.unitCost,
      manufactureDate: entity.manufactureDate,
      expiryDate: entity.expiryDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BatchEntity toEntity() {
    return BatchEntity(
      id: id,
      productId: productId,
      batchCode: batchCode,
      initialQuantity: initialQuantity,
      currentQuantity: currentQuantity,
      availableQuantity: availableQuantity,
      reservedQuantity: reservedQuantity,
      unitCost: unitCost,
      manufactureDate: manufactureDate,
      expiryDate: expiryDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
