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
  final int loyaltyPoints;
  final int lifetimePoints;
  final String membershipLevel;

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
    this.loyaltyPoints = 0,
    this.lifetimePoints = 0,
    this.membershipLevel = 'Bronze',
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
    loyaltyPoints,
    lifetimePoints,
    membershipLevel,
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
    int? loyaltyPoints,
    int? lifetimePoints,
    String? membershipLevel,
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
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      membershipLevel: membershipLevel ?? this.membershipLevel,
    );
  }
}
