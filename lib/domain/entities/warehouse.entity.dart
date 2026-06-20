import 'package:equatable/equatable.dart';

class WarehouseEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String locationAr;
  final String locationEn;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarehouseEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.locationAr,
    required this.locationEn,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        locationAr,
        locationEn,
        isActive,
        createdAt,
        updatedAt,
      ];

  WarehouseEntity copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? locationAr,
    String? locationEn,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      locationAr: locationAr ?? this.locationAr,
      locationEn: locationEn ?? this.locationEn,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
