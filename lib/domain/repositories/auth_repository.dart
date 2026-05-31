import 'dart:async';
import '../entities/user.entity.dart';
import '../../core/utils/result.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> signIn(String email, String password);
  Future<Result<UserEntity>> signUp(String email, String password, String? displayName);
  Future<void> signOut();
  Future<Result<UserEntity?>> getCurrentUser();
  Stream<UserEntity?> watchAuthState();
  Future<void> sendPasswordReset(String email);
}
