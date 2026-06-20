import '../../core/constants/firestore_constants.dart';

class PurchaseOrderDto {
  final String id;
  final String supplierId;
  final String supplierName;
  final String status;
  final List<PurchaseOrderItemDto> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PurchaseOrderDto({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.items,
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

  factory PurchaseOrderDto.fromMap(Map<String, dynamic> map, String documentId) {
    final rawItems = map['items'] as List? ?? [];
    final itemsList = rawItems
        .map((e) => PurchaseOrderItemDto.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return PurchaseOrderDto(
      id: documentId,
      supplierId: map['supplierId'] as String? ?? '',
      supplierName: map['supplierName'] as String? ?? '',
      status: map['status'] as String? ?? 'Pending',
      items: itemsList,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status,
      'items': items.map((e) => e.toMap()).toList(),
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}

class PurchaseOrderItemDto {
  final String productId;
  final String productName;
  final int quantityOrdered;
  final int quantityReceived;
  final double unitCost;
  final String? batchCode;
  final String? expiryDate;

  const PurchaseOrderItemDto({
    required this.productId,
    required this.productName,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
    this.batchCode,
    this.expiryDate,
  });

  factory PurchaseOrderItemDto.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItemDto(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      quantityOrdered: map['quantityOrdered'] as int? ?? 0,
      quantityReceived: map['quantityReceived'] as int? ?? 0,
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0.0,
      batchCode: map['batchCode'] as String?,
      expiryDate: map['expiryDate'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantityOrdered': quantityOrdered,
      'quantityReceived': quantityReceived,
      'unitCost': unitCost,
      'batchCode': batchCode,
      'expiryDate': expiryDate,
    };
  }
}
