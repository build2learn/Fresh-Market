import 'package:equatable/equatable.dart';
import '../../core/enums/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final bool isActive;
  final String? fcmToken;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.role = UserRole.customer,
    this.isActive = true,
    this.fcmToken,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role.isAdmin;
  bool get isCustomer => role.isCustomer;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    phoneNumber,
    photoUrl,
    role,
    isActive,
    fcmToken,
    lastLoginAt,
    createdAt,
    updatedAt,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    bool? isActive,
    String? fcmToken,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
