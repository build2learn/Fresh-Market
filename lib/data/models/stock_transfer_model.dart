import '../dto/stock_transfer.dto.dart';
import '../../domain/entities/stock_transfer.entity.dart';

class StockTransferModel extends StockTransferDto {
  const StockTransferModel({
    required super.id,
    required super.fromWarehouseId,
    required super.toWarehouseId,
    required super.productId,
    required super.quantity,
    required super.transferDate,
    super.notes,
    required super.status,
    super.createdById,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StockTransferModel.fromDto(StockTransferDto dto) {
    return StockTransferModel(
      id: dto.id,
      fromWarehouseId: dto.fromWarehouseId,
      toWarehouseId: dto.toWarehouseId,
      productId: dto.productId,
      quantity: dto.quantity,
      transferDate: dto.transferDate,
      notes: dto.notes,
      status: dto.status,
      createdById: dto.createdById,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory StockTransferModel.fromEntity(StockTransferEntity entity) {
    return StockTransferModel(
      id: entity.id,
      fromWarehouseId: entity.fromWarehouseId,
      toWarehouseId: entity.toWarehouseId,
      productId: entity.productId,
      quantity: entity.quantity,
      transferDate: entity.transferDate,
      notes: entity.notes,
      status: entity.status,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  StockTransferEntity toEntity() {
    return StockTransferEntity(
      id: id,
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      productId: productId,
      quantity: quantity,
      transferDate: transferDate,
      notes: notes,
      status: status,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
