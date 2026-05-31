import '../../core/constants/firestore_constants.dart';

class CategoryDto {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final bool isVisible;
  final bool isDeleted;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryDto({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    required this.isVisible,
    this.isDeleted = false,
    required this.sortOrder,
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

  factory CategoryDto.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryDto(
      id: documentId,
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      isVisible: map[FirestoreConstants.isVisible] as bool? ?? true,
      isDeleted: map[FirestoreConstants.isDeleted] as bool? ?? false,
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
      'imageUrl': imageUrl,
      FirestoreConstants.isVisible: isVisible,
      FirestoreConstants.isDeleted: isDeleted,
      FirestoreConstants.sortOrder: sortOrder,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.updatedAt: updatedAt,
    };
  }

  CategoryDto copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    bool? isVisible,
    bool? isDeleted,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryDto(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      isDeleted: isDeleted ?? this.isDeleted,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
