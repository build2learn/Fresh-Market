import 'package:equatable/equatable.dart';

class CouponEntity extends Equatable {
  final String id;
  final String code; // e.g., SAVE10, EID50
  final String type; // 'Percentage' or 'FixedAmount'
  final double discountValue;
  final double minOrderAmount;
  final bool isActive;
  final DateTime? expiryDate;
  final int? usageLimit;
  final int usedCount;

  const CouponEntity({
    required this.id,
    required this.code,
    required this.type,
    required this.discountValue,
    required this.minOrderAmount,
    this.isActive = true,
    this.expiryDate,
    this.usageLimit,
    this.usedCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        type,
        discountValue,
        minOrderAmount,
        isActive,
        expiryDate,
        usageLimit,
        usedCount,
      ];

  CouponEntity copyWith({
    String? id,
    String? code,
    String? type,
    double? discountValue,
    double? minOrderAmount,
    bool? isActive,
    DateTime? expiryDate,
    int? usageLimit,
    int? usedCount,
  }) {
    return CouponEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
    );
  }
}
