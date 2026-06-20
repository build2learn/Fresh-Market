import '../dto/warehouse_inventory.dto.dart';
import '../../domain/entities/warehouse_inventory.entity.dart';

class WarehouseInventoryModel extends WarehouseInventoryDto {
  const WarehouseInventoryModel({
    required super.id,
    required super.warehouseId,
    required super.productId,
    required super.quantity,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WarehouseInventoryModel.fromDto(WarehouseInventoryDto dto) {
    return WarehouseInventoryModel(
      id: dto.id,
      warehouseId: dto.warehouseId,
      productId: dto.productId,
      quantity: dto.quantity,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory WarehouseInventoryModel.fromEntity(WarehouseInventoryEntity entity) {
    return WarehouseInventoryModel(
      id: entity.id,
      warehouseId: entity.warehouseId,
      productId: entity.productId,
      quantity: entity.quantity,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  WarehouseInventoryEntity toEntity() {
    return WarehouseInventoryEntity(
      id: id,
      warehouseId: warehouseId,
      productId: productId,
      quantity: quantity,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
