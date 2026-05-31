import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
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

  const OfferEntity({
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

  bool get isCurrentlyActive =>
      isActive &&
      startDate.isBefore(DateTime.now()) &&
      endDate.isAfter(DateTime.now());

  bool get isExpired => endDate.isBefore(DateTime.now());

  Duration get remainingTime => endDate.difference(DateTime.now());

  @override
  List<Object?> get props => [
    id,
    titleAr,
    titleEn,
    descriptionAr,
    descriptionEn,
    imageUrl,
    isActive,
    startDate,
    endDate,
    createdAt,
    updatedAt,
  ];

  OfferEntity copyWith({
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
    return OfferEntity(
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
