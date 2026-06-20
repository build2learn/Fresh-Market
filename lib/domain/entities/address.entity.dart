import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        phone,
        address,
        city,
        notes,
        createdAt,
        updatedAt,
      ];

  AddressEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
