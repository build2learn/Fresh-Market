import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final bool isVisible;
  final bool isDeleted;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.isVisible = true,
    this.isDeleted = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  CategoryEntity get asDeleted => copyWith(isDeleted: true, isVisible: false);

  CategoryEntity get asRestored => copyWith(isDeleted: false);

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    imageUrl,
    isVisible,
    isDeleted,
    sortOrder,
    createdAt,
    updatedAt,
  ];

  CategoryEntity copyWith({
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
    return CategoryEntity(
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
