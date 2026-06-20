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
    super.productType = 'Fresh',
    super.status = 'Available',
    super.currentStock = 50,
    super.reservedStock = 0,
    super.availableStock = 50,
    super.minimumStock = 5,
    super.reorderLevel = 10,
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
      productType: dto.productType,
      status: dto.status,
      currentStock: dto.currentStock,
      reservedStock: dto.reservedStock,
      availableStock: dto.availableStock,
      minimumStock: dto.minimumStock,
      reorderLevel: dto.reorderLevel,
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
      productType: entity.productType,
      status: entity.status,
      currentStock: entity.currentStock,
      reservedStock: entity.reservedStock,
      availableStock: entity.availableStock,
      minimumStock: entity.minimumStock,
      reorderLevel: entity.reorderLevel,
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
      productType: productType,
      status: status,
      currentStock: currentStock,
      reservedStock: reservedStock,
      availableStock: availableStock,
      minimumStock: minimumStock,
      reorderLevel: reorderLevel,
    );
  }
}
