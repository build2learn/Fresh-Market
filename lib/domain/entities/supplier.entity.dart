import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierEntity({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    this.balance = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        contactPerson,
        phone,
        email,
        address,
        balance,
        createdAt,
        updatedAt,
      ];

  SupplierEntity copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
