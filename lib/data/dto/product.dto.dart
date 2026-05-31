import '../../core/constants/firestore_constants.dart';

class ProductDto {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final double weight;
  final String weightUnitId;
  final String? imageUrl;
  final String? imageThumbUrl;
  final String categoryId;
  final bool isFeatured;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductDto({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    required this.weight,
    required this.weightUnitId,
    this.imageUrl,
    this.imageThumbUrl,
    required this.categoryId,
    required this.isFeatured,
    required this.isAvailable,
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

  factory ProductDto.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductDto(
      id: documentId,
      nameAr: map['nameAr'] as String? ?? '',
      nameEn: map['nameEn'] as String? ?? '',
      descriptionAr: map['descriptionAr'] as String?,
      descriptionEn: map['descriptionEn'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      weightUnitId: map['weightUnitId'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      imageThumbUrl: map['imageThumbUrl'] as String?,
      categoryId: map['categoryId'] as String? ?? '',
      isFeatured: map[FirestoreConstants.isFeatured] as bool? ?? false,
      isAvailable: map[FirestoreConstants.isAvailable] as bool? ?? true,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'price': price,
      'weight': weight,
      'weightUnitId': weightUnitId,
      'imageUrl': imageUrl,
      'imageThumbUrl': imageThumbUrl,
      'categoryId': categoryId,
      FirestoreConstants.isFeatured: isFeatured,
      FirestoreConstants.isAvailable: isAvailable,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.updatedAt: updatedAt,
    };
  }

  ProductDto copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? weight,
    String? weightUnitId,
    String? imageUrl,
    String? imageThumbUrl,
    String? categoryId,
    bool? isFeatured,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductDto(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      imageUrl: imageUrl ?? this.imageUrl,
      imageThumbUrl: imageThumbUrl ?? this.imageThumbUrl,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
