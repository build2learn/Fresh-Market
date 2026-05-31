import '../../core/constants/firestore_constants.dart';
import '../../core/enums/user_role.dart';

class UserDto {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String role;
  final bool isActive;
  final String? fcmToken;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserDto({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    required this.isActive,
    this.fcmToken,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime? _toDateTimeOrNull(dynamic value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory UserDto.fromMap(Map<String, dynamic> map, String documentId) {
    return UserDto(
      id: documentId,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? UserRole.customer.value,
      isActive: map[FirestoreConstants.isActive] as bool? ?? true,
      fcmToken: map['fcmToken'] as String?,
      lastLoginAt: _toDateTimeOrNull(map['lastLoginAt']),
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role,
      FirestoreConstants.isActive: isActive,
      'fcmToken': fcmToken,
      'lastLoginAt': lastLoginAt,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.updatedAt: updatedAt,
    };
  }

  UserDto copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? role,
    bool? isActive,
    String? fcmToken,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserDto(
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
