import '../dto/user.dto.dart';
import '../../domain/entities/user.entity.dart';
import '../../core/enums/user_role.dart';

class UserModel extends UserDto {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.photoUrl,
    required super.role,
    required super.isActive,
    super.fcmToken,
    super.lastLoginAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromDto(UserDto dto) {
    return UserModel(
      id: dto.id,
      email: dto.email,
      displayName: dto.displayName,
      phoneNumber: dto.phoneNumber,
      photoUrl: dto.photoUrl,
      role: dto.role,
      isActive: dto.isActive,
      fcmToken: dto.fcmToken,
      lastLoginAt: dto.lastLoginAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      role: entity.role.value,
      isActive: entity.isActive,
      fcmToken: entity.fcmToken,
      lastLoginAt: entity.lastLoginAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      role: UserRole.fromString(role),
      isActive: isActive,
      fcmToken: fcmToken,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
