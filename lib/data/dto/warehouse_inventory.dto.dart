import '../../core/constants/firestore_constants.dart';

class WarehouseInventoryDto {
  final String id;
  final String warehouseId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarehouseInventoryDto({
    required this.id,
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  WarehouseInventoryDto copyWith({
    String? id,
    String? warehouseId,
    String? productId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseInventoryDto(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  factory WarehouseInventoryDto.fromMap(Map<String, dynamic> map, String documentId) {
    return WarehouseInventoryDto(
      id: documentId,
      warehouseId: map['warehouseId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'warehouseId': warehouseId,
      'productId': productId,
      'quantity': quantity,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
