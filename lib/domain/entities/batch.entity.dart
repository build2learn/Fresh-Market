import 'package:equatable/equatable.dart';

class BatchEntity extends Equatable {
  final String id;
  final String productId;
  final String batchCode;
  final int initialQuantity;
  final int currentQuantity;
  final int availableQuantity;
  final int reservedQuantity;
  final double unitCost;
  final DateTime manufactureDate;
  final DateTime expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BatchEntity({
    required this.id,
    required this.productId,
    required this.batchCode,
    required this.initialQuantity,
    required this.currentQuantity,
    required this.availableQuantity,
    required this.reservedQuantity,
    required this.unitCost,
    required this.manufactureDate,
    required this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        batchCode,
        initialQuantity,
        currentQuantity,
        availableQuantity,
        reservedQuantity,
        unitCost,
        manufactureDate,
        expiryDate,
        createdAt,
        updatedAt,
      ];

  BatchEntity copyWith({
    String? id,
    String? productId,
    String? batchCode,
    int? initialQuantity,
    int? currentQuantity,
    int? availableQuantity,
    int? reservedQuantity,
    double? unitCost,
    DateTime? manufactureDate,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BatchEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchCode: batchCode ?? this.batchCode,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      unitCost: unitCost ?? this.unitCost,
      manufactureDate: manufactureDate ?? this.manufactureDate,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
