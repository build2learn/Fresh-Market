import '../dto/category.dto.dart';
import '../../domain/entities/category.entity.dart';

class CategoryModel extends CategoryDto {
  const CategoryModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.imageUrl,
    required super.isVisible,
    super.isDeleted = false,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromDto(CategoryDto dto) {
    return CategoryModel(
      id: dto.id,
      nameAr: dto.nameAr,
      nameEn: dto.nameEn,
      imageUrl: dto.imageUrl,
      isVisible: dto.isVisible,
      isDeleted: dto.isDeleted,
      sortOrder: dto.sortOrder,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      imageUrl: entity.imageUrl,
      isVisible: entity.isVisible,
      isDeleted: entity.isDeleted,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      imageUrl: imageUrl,
      isVisible: isVisible,
      isDeleted: isDeleted,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
