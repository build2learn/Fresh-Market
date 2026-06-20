class CouponDto {
  final String id;
  final String code;
  final String type;
  final double discountValue;
  final double minOrderAmount;
  final bool isActive;
  final DateTime? expiryDate;
  final int? usageLimit;
  final int usedCount;

  const CouponDto({
    required this.id,
    required this.code,
    required this.type,
    required this.discountValue,
    required this.minOrderAmount,
    required this.isActive,
    this.expiryDate,
    this.usageLimit,
    this.usedCount = 0,
  });

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  factory CouponDto.fromMap(Map<String, dynamic> map, String documentId) {
    return CouponDto(
      id: documentId,
      code: map['code'] as String? ?? '',
      type: map['type'] as String? ?? 'Percentage',
      discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (map['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      isActive: map['isActive'] as bool? ?? true,
      expiryDate: _toDateTime(map['expiryDate']),
      usageLimit: map['usageLimit'] as int?,
      usedCount: map['usedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'discountValue': discountValue,
      'minOrderAmount': minOrderAmount,
      'isActive': isActive,
      'expiryDate': expiryDate?.toIso8601String(),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
    };
  }
}
