import 'package:equatable/equatable.dart';

class WeightUnitEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final String abbr;
  final int sortOrder;

  const WeightUnitEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.abbr,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, nameAr, nameEn, abbr, sortOrder];

  WeightUnitEntity copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? abbr,
    int? sortOrder,
  }) {
    return WeightUnitEntity(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      abbr: abbr ?? this.abbr,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
