import 'package:equatable/equatable.dart';

class StockTransferEntity extends Equatable {
  final String id;
  final String fromWarehouseId;
  final String toWarehouseId;
  final String productId;
  final int quantity;
  final DateTime transferDate;
  final String? notes;
  final String status;
  final String? createdById;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockTransferEntity({
    required this.id,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.productId,
    required this.quantity,
    required this.transferDate,
    this.notes,
    this.status = 'Completed',
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        fromWarehouseId,
        toWarehouseId,
        productId,
        quantity,
        transferDate,
        notes,
        status,
        createdById,
        createdAt,
        updatedAt,
      ];

  StockTransferEntity copyWith({
    String? id,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? productId,
    int? quantity,
    DateTime? transferDate,
    String? notes,
    String? status,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockTransferEntity(
      id: id ?? this.id,
      fromWarehouseId: fromWarehouseId ?? this.fromWarehouseId,
      toWarehouseId: toWarehouseId ?? this.toWarehouseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      transferDate: transferDate ?? this.transferDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
