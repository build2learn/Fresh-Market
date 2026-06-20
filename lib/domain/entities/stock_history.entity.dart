import 'package:equatable/equatable.dart';

class StockHistoryEntity extends Equatable {
  final String id;
  final String productId;
  final String productNameAr;
  final String productNameEn;
  final String type; // e.g., 'adjustment', 'receipt', 'order_created', 'order_cancelled'
  final int quantityChanged;
  final int previousStock;
  final int newStock;
  final String reasonAr;
  final String reasonEn;
  final DateTime createdAt;
  final String createdBy;

  const StockHistoryEntity({
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

  @override
  List<Object?> get props => [
        id,
        productId,
        productNameAr,
        productNameEn,
        type,
        quantityChanged,
        previousStock,
        newStock,
        reasonAr,
        reasonEn,
        createdAt,
        createdBy,
      ];

  StockHistoryEntity copyWith({
    String? id,
    String? productId,
    String? productNameAr,
    String? productNameEn,
    String? type,
    int? quantityChanged,
    int? previousStock,
    int? newStock,
    String? reasonAr,
    String? reasonEn,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return StockHistoryEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productNameAr: productNameAr ?? this.productNameAr,
      productNameEn: productNameEn ?? this.productNameEn,
      type: type ?? this.type,
      quantityChanged: quantityChanged ?? this.quantityChanged,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      reasonAr: reasonAr ?? this.reasonAr,
      reasonEn: reasonEn ?? this.reasonEn,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
