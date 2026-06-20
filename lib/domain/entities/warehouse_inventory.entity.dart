import 'package:equatable/equatable.dart';

class WarehouseInventoryEntity extends Equatable {
  final String id;
  final String warehouseId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarehouseInventoryEntity({
    required this.id,
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        warehouseId,
        productId,
        quantity,
        createdAt,
        updatedAt,
      ];

  WarehouseInventoryEntity copyWith({
    String? id,
    String? warehouseId,
    String? productId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseInventoryEntity(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
