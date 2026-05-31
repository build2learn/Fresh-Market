import '../dto/product.dto.dart';
import '../../domain/entities/product.entity.dart';

class ProductModel extends ProductDto {
  const ProductModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.price,
    required super.weight,
    required super.weightUnitId,
    super.imageUrl,
    super.imageThumbUrl,
    required super.categoryId,
    required super.isFeatured,
    required super.isAvailable,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromDto(ProductDto dto) {
    return ProductModel(
      id: dto.id,
      nameAr: dto.nameAr,
      nameEn: dto.nameEn,
      descriptionAr: dto.descriptionAr,
      descriptionEn: dto.descriptionEn,
      price: dto.price,
      weight: dto.weight,
      weightUnitId: dto.weightUnitId,
      imageUrl: dto.imageUrl,
      imageThumbUrl: dto.imageThumbUrl,
      categoryId: dto.categoryId,
      isFeatured: dto.isFeatured,
      isAvailable: dto.isAvailable,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      price: entity.price,
      weight: entity.weight,
      weightUnitId: entity.weightUnitId,
      imageUrl: entity.imageUrl,
      imageThumbUrl: entity.imageThumbUrl,
      categoryId: entity.categoryId,
      isFeatured: entity.isFeatured,
      isAvailable: entity.isAvailable,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      price: price,
      weight: weight,
      weightUnitId: weightUnitId,
      imageUrl: imageUrl,
      imageThumbUrl: imageThumbUrl,
      categoryId: categoryId,
      isFeatured: isFeatured,
      isAvailable: isAvailable,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
