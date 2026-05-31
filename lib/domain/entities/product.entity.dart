import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
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

  const ProductEntity({
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
    this.isFeatured = false,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    price,
    weight,
    weightUnitId,
    imageUrl,
    imageThumbUrl,
    categoryId,
    isFeatured,
    isAvailable,
    createdAt,
    updatedAt,
  ];

  ProductEntity copyWith({
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
    return ProductEntity(
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
