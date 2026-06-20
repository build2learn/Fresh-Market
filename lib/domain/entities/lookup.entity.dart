import 'package:equatable/equatable.dart';

class LookupEntity extends Equatable {
  final int id;
  final String lookupType; // WeightUnit, Category, ProductStatus, ProductType, OfferType, UserRole
  final String code;
  final String nameAr;
  final String nameEn;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl; // optional, mainly for categories

  const LookupEntity({
    required this.id,
    required this.lookupType,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        lookupType,
        code,
        nameAr,
        nameEn,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
        imageUrl,
      ];

  LookupEntity copyWith({
    int? id,
    String? lookupType,
    String? code,
    String? nameAr,
    String? nameEn,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return LookupEntity(
      id: id ?? this.id,
      lookupType: lookupType ?? this.lookupType,
      code: code ?? this.code,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
