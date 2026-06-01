import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/datasources/firebase/auth_firebase_datasource.dart';
import 'package:fresh_market/data/datasources/local/auth_local_datasource.dart';
import 'package:fresh_market/data/dto/user.dto.dart';
import 'package:fresh_market/data/models/user_model.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/repositories/auth_repository.dart';
import '../../core/constants/firestore_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _firebaseDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthFirebaseDataSource firebaseDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<UserEntity>> signIn(String email, String password) async {
    try {
      final credential = await _firebaseDataSource.signIn(email, password);
      final uid = credential.user!.uid;
      final userData = await _firebaseDataSource.getUserData(uid);
      if (userData == null) {
        return Failure(AuthException(message: 'User not found'));
      }
      final dto = UserDto.fromMap(userData, uid);
      final entity = UserModel.fromDto(dto).toEntity();
      await _localDataSource.cacheUserId(uid);
      return Success(entity);
    } on auth.FirebaseAuthException catch (e) {
      return Failure(_mapAuthError(e));
    } catch (e) {
      return Failure(AuthException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUp(
      String email, String password, String? displayName) async {
    try {
      final credential = await _firebaseDataSource.signUp(email, password);
      final uid = credential.user!.uid;
      final now = DateTime.now();
      final userData = {
        'email': email,
        'displayName': displayName,
        'role': 'customer',
        FirestoreConstants.isActive: true,
        FirestoreConstants.createdAt: now,
        FirestoreConstants.updatedAt: now,
      };
      await _firebaseDataSource.createUserDocument(uid, userData);
      final dto = UserDto.fromMap(userData, uid);
      final entity = UserModel.fromDto(dto).toEntity();
      await _localDataSource.cacheUserId(uid);
      return Success(entity);
    } on auth.FirebaseAuthException catch (e) {
      return Failure(_mapAuthError(e));
    } catch (e) {
      return Failure(AuthException(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseDataSource.signOut();
    await _localDataSource.clearCache();
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final authUser = _firebaseDataSource.currentUser;
      debugPrint('[AuthRepo] getCurrentUser: authUser=${authUser?.uid ?? "null"}');
      if (authUser == null) {
        await _localDataSource.clearCache();
        debugPrint('[AuthRepo] getCurrentUser: no user cached');
        return const Success(null);
      }
      debugPrint('[AuthRepo] getCurrentUser: fetching Firestore doc for ${authUser.uid}');
      final userData = await _firebaseDataSource.getUserData(authUser.uid);
      if (userData != null) {
        final dto = UserDto.fromMap(userData, authUser.uid);
        debugPrint('[AuthRepo] getCurrentUser: user doc found');
        return Success(UserModel.fromDto(dto).toEntity());
      }
      debugPrint('[AuthRepo] getCurrentUser: no Firestore doc for ${authUser.uid}');
      return const Success(null);
    } catch (e, st) {
      debugPrint('[AuthRepo] getCurrentUser error: $e\n$st');
      return Failure(AuthException(message: 'Failed to get current user'));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return _firebaseDataSource.watchAuthState().asyncMap((authUser) async {
      try {
        if (authUser == null) {
          debugPrint('[AuthRepo] watchAuthState: no user, clearing cache');
          await _localDataSource.clearCache();
          return null;
        }
        debugPrint('[AuthRepo] watchAuthState: user=${authUser.uid}, fetching user data');
        final userData = await _firebaseDataSource.getUserData(authUser.uid);
        if (userData != null) {
          final dto = UserDto.fromMap(userData, authUser.uid);
          final entity = UserModel.fromDto(dto).toEntity();
          debugPrint('[AuthRepo] watchAuthState: user data found for ${authUser.uid}');
          return entity;
        }
        debugPrint('[AuthRepo] watchAuthState: no user document for ${authUser.uid}');
        return null;
      } catch (e, st) {
        debugPrint('[AuthRepo] watchAuthState error: $e\n$st');
        return null;
      }
    });
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseDataSource.sendPasswordReset(email);
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  AuthException _mapAuthError(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          message: 'No user found with this email',
          code: e.code,
        );
      case 'wrong-password':
        return AuthException(
          message: 'Incorrect password',
          code: e.code,
        );
      case 'invalid-email':
        return AuthException(
          message: 'Invalid email address',
          code: e.code,
        );
      case 'user-disabled':
        return AuthException(
          message: 'This account has been disabled',
          code: e.code,
        );
      case 'email-already-in-use':
        return AuthException(
          message: 'An account with this email already exists',
          code: e.code,
        );
      case 'operation-not-allowed':
        return AuthException(
          message: 'Email/password sign in is not enabled',
          code: e.code,
        );
      case 'weak-password':
        return AuthException(
          message: 'Password is too weak',
          code: e.code,
        );
      case 'too-many-requests':
        return AuthException(
          message: 'Too many attempts. Please try again later',
          code: e.code,
        );
      case 'network-request-failed':
        return AuthException(
          message: 'Network error. Please check your connection',
          code: e.code,
        );
      default:
        return AuthException(
          message: e.message ?? 'An authentication error occurred',
          code: e.code,
        );
    }
  }
}
