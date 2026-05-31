import '../../core/constants/firestore_constants.dart';

class OfferDto {
  final String id;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfferDto({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    this.isActive = false,
    required this.startDate,
    required this.endDate,
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

  factory OfferDto.fromMap(Map<String, dynamic> map, String documentId) {
    return OfferDto(
      id: documentId,
      titleAr: map['titleAr'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      descriptionAr: map['descriptionAr'] as String?,
      descriptionEn: map['descriptionEn'] as String?,
      imageUrl: map['imageUrl'] as String?,
      isActive: map[FirestoreConstants.isActive] as bool? ?? false,
      startDate: _toDateTime(map['startDate']),
      endDate: _toDateTime(map['endDate']),
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      FirestoreConstants.isActive: isActive,
      'startDate': startDate,
      'endDate': endDate,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.updatedAt: updatedAt,
    };
  }

  OfferDto copyWith({
    String? id,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfferDto(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
