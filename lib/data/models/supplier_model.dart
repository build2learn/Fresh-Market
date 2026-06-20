import '../dto/supplier.dto.dart';
import '../../domain/entities/supplier.entity.dart';

class SupplierModel extends SupplierDto {
  const SupplierModel({
    required super.id,
    required super.name,
    required super.contactPerson,
    required super.phone,
    required super.email,
    required super.address,
    required super.balance,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SupplierModel.fromDto(SupplierDto dto) {
    return SupplierModel(
      id: dto.id,
      name: dto.name,
      contactPerson: dto.contactPerson,
      phone: dto.phone,
      email: dto.email,
      address: dto.address,
      balance: dto.balance,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory SupplierModel.fromEntity(SupplierEntity entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      contactPerson: entity.contactPerson,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      balance: entity.balance,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id,
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      address: address,
      balance: balance,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
