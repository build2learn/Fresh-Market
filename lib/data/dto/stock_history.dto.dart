import '../../domain/entities/stock_history.entity.dart';

class StockHistoryDto {
  final String id;
  final String productId;
  final String productNameAr;
  final String productNameEn;
  final String type;
  final int quantityChanged;
  final int previousStock;
  final int newStock;
  final String reasonAr;
  final String reasonEn;
  final DateTime createdAt;
  final String createdBy;

  const StockHistoryDto({
    required this.id,
    required this.productId,
    required this.productNameAr,
    required this.productNameEn,
    required this.type,
    required this.quantityChanged,
    required this.previousStock,
    required this.newStock,
    required this.reasonAr,
    required this.reasonEn,
    required this.createdAt,
    required this.createdBy,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory StockHistoryDto.fromMap(Map<String, dynamic> map, String documentId) {
    return StockHistoryDto(
      id: documentId,
      productId: map['productId'] as String? ?? '',
      productNameAr: map['productNameAr'] as String? ?? '',
      productNameEn: map['productNameEn'] as String? ?? '',
      type: map['type'] as String? ?? 'adjustment',
      quantityChanged: map['quantityChanged'] as int? ?? 0,
      previousStock: map['previousStock'] as int? ?? 0,
      newStock: map['newStock'] as int? ?? 0,
      reasonAr: map['reasonAr'] as String? ?? '',
      reasonEn: map['reasonEn'] as String? ?? '',
      createdAt: _toDateTime(map['createdAt']),
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productNameAr': productNameAr,
      'productNameEn': productNameEn,
      'type': type,
      'quantityChanged': quantityChanged,
      'previousStock': previousStock,
      'newStock': newStock,
      'reasonAr': reasonAr,
      'reasonEn': reasonEn,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory StockHistoryDto.fromEntity(StockHistoryEntity entity) {
    return StockHistoryDto(
      id: entity.id,
      productId: entity.productId,
      productNameAr: entity.productNameAr,
      productNameEn: entity.productNameEn,
      type: entity.type,
      quantityChanged: entity.quantityChanged,
      previousStock: entity.previousStock,
      newStock: entity.newStock,
      reasonAr: entity.reasonAr,
      reasonEn: entity.reasonEn,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
    );
  }

  StockHistoryEntity toEntity() {
    return StockHistoryEntity(
      id: id,
      productId: productId,
      productNameAr: productNameAr,
      productNameEn: productNameEn,
      type: type,
      quantityChanged: quantityChanged,
      previousStock: previousStock,
      newStock: newStock,
      reasonAr: reasonAr,
      reasonEn: reasonEn,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
