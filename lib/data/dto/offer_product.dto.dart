class OfferProductDto {
  final String id;
  final String offerId;
  final String productId;
  final DateTime createdAt;

  const OfferProductDto({
    required this.id,
    required this.offerId,
    required this.productId,
    required this.createdAt,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory OfferProductDto.fromMap(Map<String, dynamic> map, String documentId) {
    return OfferProductDto(
      id: documentId,
      offerId: map['offerId'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      createdAt: _toDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offerId': offerId,
      'productId': productId,
      'createdAt': createdAt,
    };
  }

  OfferProductDto copyWith({
    String? id,
    String? offerId,
    String? productId,
    DateTime? createdAt,
  }) {
    return OfferProductDto(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
