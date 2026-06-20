import '../../core/constants/firestore_constants.dart';

class BatchDto {
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

  const BatchDto({
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

  factory BatchDto.fromMap(Map<String, dynamic> map, String documentId) {
    return BatchDto(
      id: documentId,
      productId: map['productId'] as String? ?? '',
      batchCode: map['batchCode'] as String? ?? '',
      initialQuantity: map['initialQuantity'] as int? ?? 0,
      currentQuantity: map['currentQuantity'] as int? ?? 0,
      availableQuantity: map['availableQuantity'] as int? ?? 0,
      reservedQuantity: map['reservedQuantity'] as int? ?? 0,
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0.0,
      manufactureDate: _toDateTime(map['manufactureDate']),
      expiryDate: _toDateTime(map['expiryDate']),
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'batchCode': batchCode,
      'initialQuantity': initialQuantity,
      'currentQuantity': currentQuantity,
      'availableQuantity': availableQuantity,
      'reservedQuantity': reservedQuantity,
      'unitCost': unitCost,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
