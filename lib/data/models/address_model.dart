import '../../domain/entities/address.entity.dart';
import '../dto/address.dto.dart';

class AddressModel {
  static AddressEntity fromDto(AddressDto dto) {
    return AddressEntity(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      phone: dto.phone,
      address: dto.address,
      city: dto.city,
      notes: dto.notes,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static AddressDto fromEntity(AddressEntity entity) {
    return AddressDto(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      city: entity.city,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
