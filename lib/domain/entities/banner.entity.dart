import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String? titleAr;
  final String? titleEn;
  final String imageUrl;
  final String? linkUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    this.titleAr,
    this.titleEn,
    required this.imageUrl,
    this.linkUrl,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    titleAr,
    titleEn,
    imageUrl,
    linkUrl,
    sortOrder,
    isActive,
    createdAt,
    updatedAt,
  ];

  BannerEntity copyWith({
    String? id,
    String? titleAr,
    String? titleEn,
    String? imageUrl,
    String? linkUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerEntity(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
