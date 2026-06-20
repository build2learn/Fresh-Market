import 'package:equatable/equatable.dart';

class PurchaseOrderEntity extends Equatable {
  final String id;
  final String supplierId;
  final String supplierName;
  final String status; // Pending, Ordered, Received, Cancelled
  final List<PurchaseOrderItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PurchaseOrderEntity({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        supplierId,
        supplierName,
        status,
        items,
        createdAt,
        updatedAt,
      ];

  PurchaseOrderEntity copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? status,
    List<PurchaseOrderItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderEntity(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PurchaseOrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantityOrdered;
  final int quantityReceived;
  final double unitCost;
  final String? batchCode;
  final DateTime? expiryDate;

  const PurchaseOrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantityOrdered,
    required this.quantityReceived,
    this.unitCost = 0.0,
    this.batchCode,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantityOrdered,
        quantityReceived,
        unitCost,
        batchCode,
        expiryDate,
      ];

  PurchaseOrderItemEntity copyWith({
    String? productId,
    String? productName,
    int? quantityOrdered,
    int? quantityReceived,
    double? unitCost,
    String? batchCode,
    DateTime? expiryDate,
  }) {
    return PurchaseOrderItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantityOrdered: quantityOrdered ?? this.quantityOrdered,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      unitCost: unitCost ?? this.unitCost,
      batchCode: batchCode ?? this.batchCode,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
