import '../../core/constants/firestore_constants.dart';

class WarehouseDto {
  final String id;
  final String nameAr;
  final String nameEn;
  final String locationAr;
  final String locationEn;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarehouseDto({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.locationAr,
    required this.locationEn,
    required this.isActive,
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

  factory WarehouseDto.fromMap(Map<String, dynamic> map, String documentId) {
    return WarehouseDto(
      id: documentId,
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      locationAr: map['locationAr'] as String? ?? '',
      locationEn: map['locationEn'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'locationAr': locationAr,
      'locationEn': locationEn,
      'isActive': isActive,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
