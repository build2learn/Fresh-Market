import '../dto/purchase_order.dto.dart';
import '../../domain/entities/purchase_order.entity.dart';

class PurchaseOrderModel extends PurchaseOrderDto {
  const PurchaseOrderModel({
    required super.id,
    required super.supplierId,
    required super.supplierName,
    required super.status,
    required super.items,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PurchaseOrderModel.fromDto(PurchaseOrderDto dto) {
    return PurchaseOrderModel(
      id: dto.id,
      supplierId: dto.supplierId,
      supplierName: dto.supplierName,
      status: dto.status,
      items: dto.items.map((e) => _itemFromDto(e)).toList(),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory PurchaseOrderModel.fromEntity(PurchaseOrderEntity entity) {
    return PurchaseOrderModel(
      id: entity.id,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      status: entity.status,
      items: entity.items.map((e) => _itemFromEntity(e)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PurchaseOrderEntity toEntity() {
    return PurchaseOrderEntity(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      status: status,
      items: items.map((e) => _itemToEntity(e)).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static PurchaseOrderItemEntity _itemToEntity(PurchaseOrderItemDto dto) {
    return PurchaseOrderItemEntity(
      productId: dto.productId,
      productName: dto.productName,
      quantityOrdered: dto.quantityOrdered,
      quantityReceived: dto.quantityReceived,
      unitCost: dto.unitCost,
      batchCode: dto.batchCode,
      expiryDate: dto.expiryDate != null ? DateTime.tryParse(dto.expiryDate!) : null,
    );
  }

  static PurchaseOrderItemDto _itemFromDto(PurchaseOrderItemDto dto) {
    return PurchaseOrderItemDto(
      productId: dto.productId,
      productName: dto.productName,
      quantityOrdered: dto.quantityOrdered,
      quantityReceived: dto.quantityReceived,
      unitCost: dto.unitCost,
      batchCode: dto.batchCode,
      expiryDate: dto.expiryDate,
    );
  }

  static PurchaseOrderItemDto _itemFromEntity(PurchaseOrderItemEntity entity) {
    return PurchaseOrderItemDto(
      productId: entity.productId,
      productName: entity.productName,
      quantityOrdered: entity.quantityOrdered,
      quantityReceived: entity.quantityReceived,
      unitCost: entity.unitCost,
      batchCode: entity.batchCode,
      expiryDate: entity.expiryDate?.toIso8601String(),
    );
  }
}
