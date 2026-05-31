import 'dart:async';
import '../entities/user.entity.dart';
import '../../core/utils/result.dart';

abstract interface class UserRepository {
  Future<Result<List<UserEntity>>> getUsers({required int limit, dynamic lastDoc});
  Future<Result<UserEntity>> getUser(String id);
  Future<Result<UserEntity>> updateUserRole(String userId, String role);
  Future<Result<UserEntity>> toggleUserActive(String userId, bool isActive);
  Future<Result<UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? fcmToken,
  });
  Future<Result<UserEntity>> updateFcmToken(String userId, String token);
}
