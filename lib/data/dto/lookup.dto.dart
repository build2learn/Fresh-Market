class LookupDto {
  final int id;
  final String lookupType;
  final String code;
  final String nameAr;
  final String nameEn;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  const LookupDto({
    required this.id,
    required this.lookupType,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      try {
        if (value is String) {
          return DateTime.parse(value);
        }
      } catch (_) {}
      return DateTime.now();
    }
  }

  factory LookupDto.fromMap(Map<String, dynamic> map, String documentId) {
    return LookupDto(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? '') ?? int.tryParse(documentId) ?? 0,
      lookupType: map['lookupType'] as String? ?? '',
      code: map['code'] as String? ?? '',
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lookupType': lookupType,
      'code': code,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  LookupDto copyWith({
    int? id,
    String? lookupType,
    String? code,
    String? nameAr,
    String? nameEn,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return LookupDto(
      id: id ?? this.id,
      lookupType: lookupType ?? this.lookupType,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
