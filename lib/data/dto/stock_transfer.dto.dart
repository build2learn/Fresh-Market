import '../../core/constants/firestore_constants.dart';

class StockTransferDto {
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

  const StockTransferDto({
    required this.id,
    required this.fromWarehouseId,
    required this.toWarehouseId,
    required this.productId,
    required this.quantity,
    required this.transferDate,
    this.notes,
    required this.status,
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
  });

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

  factory StockTransferDto.fromMap(Map<String, dynamic> map, String documentId) {
    return StockTransferDto(
      id: documentId,
      fromWarehouseId: map['fromWarehouseId'] as String? ?? '',
      toWarehouseId: map['toWarehouseId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      transferDate: _toDateTime(map['transferDate']),
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'Completed',
      createdById: map['createdById'] as String?,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromWarehouseId': fromWarehouseId,
      'toWarehouseId': toWarehouseId,
      'productId': productId,
      'quantity': quantity,
      'transferDate': transferDate.toIso8601String(),
      'notes': notes,
      'status': status,
      'createdById': createdById,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
