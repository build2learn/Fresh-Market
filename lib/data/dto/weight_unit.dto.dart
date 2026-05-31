import '../../core/constants/firestore_constants.dart';

class WeightUnitDto {
  final String id;
  final String nameAr;
  final String nameEn;
  final String abbr;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WeightUnitDto({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.abbr,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory WeightUnitDto.fromMap(Map<String, dynamic> map, String documentId) {
    return WeightUnitDto(
      id: documentId,
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      abbr: map['abbr'] as String? ?? '',
      sortOrder: map[FirestoreConstants.sortOrder] as int? ?? 0,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'abbr': abbr,
      FirestoreConstants.sortOrder: sortOrder,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.updatedAt: updatedAt,
    };
  }

  WeightUnitDto copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? abbr,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WeightUnitDto(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      abbr: abbr ?? this.abbr,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
