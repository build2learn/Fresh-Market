import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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
      var userData = await _firebaseDataSource.getUserData(uid);
      if (userData == null) {
        // Auto-create missing Firestore user document (e.g. if Auth signup succeeded but database was disabled/empty)
        final now = DateTime.now();
        final isAdminEmail = email.trim().toLowerCase().contains('admin');
        userData = {
          'email': email,
          'displayName': email.split('@')[0],
          'role': isAdminEmail ? 'admin' : 'customer',
          FirestoreConstants.isActive: true,
          FirestoreConstants.createdAt: now,
          FirestoreConstants.updatedAt: now,
        };
        await _firebaseDataSource.createUserDocument(uid, userData);
      }
      // Proactively enforce admin role and seed database for any admin email in production Firebase
      if (email.trim().toLowerCase().contains('admin')) {
        if (userData['role'] != 'admin') {
          final mutableData = Map<String, dynamic>.from(userData);
          mutableData['role'] = 'admin';
          userData = mutableData;
          await _firebaseDataSource.createUserDocument(uid, userData);
        }
        unawaited(_checkAndSeedDatabase());
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
      final isAdminEmail = email.trim().toLowerCase().contains('admin');
      final userData = {
        'email': email,
        'displayName': displayName,
        'role': isAdminEmail ? 'admin' : 'customer',
        FirestoreConstants.isActive: true,
        FirestoreConstants.createdAt: now,
        FirestoreConstants.updatedAt: now,
      };
      await _firebaseDataSource.createUserDocument(uid, userData);
      if (isAdminEmail) {
        unawaited(_checkAndSeedDatabase());
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
  Future<void> signOut() async {
    await _firebaseDataSource.signOut();
    await _localDataSource.clearCache();
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final authUser = _firebaseDataSource.currentUser;
      debugPrint('[AUTH] AuthRepo.getCurrentUser: authUser=${authUser?.uid ?? "null"}');
      if (authUser == null) {
        await _localDataSource.clearCache();
        debugPrint('[AUTH] AuthRepo.getCurrentUser: no user -> Success(null)');
        return const Success(null);
      }
      debugPrint('[AUTH] AuthRepo.getCurrentUser: fetching Firestore doc for ${authUser.uid}');
      final userData = await _firebaseDataSource.getUserData(authUser.uid);
      if (userData != null) {
        // Automatically enforce admin role and seed database for any admin email in production Firebase
        final email = userData['email'] as String?;
        if (email != null && email.trim().toLowerCase().contains('admin')) {
          unawaited(_checkAndSeedDatabase());
        }
        final dto = UserDto.fromMap(userData, authUser.uid);
        debugPrint('[AUTH] AuthRepo.getCurrentUser: user doc found');
        return Success(UserModel.fromDto(dto).toEntity());
      }
      debugPrint('[AUTH] AuthRepo.getCurrentUser: no Firestore doc -> Success(null)');
      return const Success(null);
    } catch (e, st) {
      debugPrint('[AUTH] AuthRepo.getCurrentUser error: $e\n$st');
      return Failure(AuthException(message: 'Failed to get current user'));
    }
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    return _firebaseDataSource.watchAuthState().asyncMap((authUser) async {
      try {
        if (authUser == null) {
          debugPrint('[AUTH] AuthRepo.watchAuthState: no user');
          await _localDataSource.clearCache();
          return null;
        }
        debugPrint('[AUTH] AuthRepo.watchAuthState: user=${authUser.uid}');
        final userData = await _firebaseDataSource.getUserData(authUser.uid);
        if (userData != null) {
          final dto = UserDto.fromMap(userData, authUser.uid);
          final entity = UserModel.fromDto(dto).toEntity();
          debugPrint('[AUTH] AuthRepo.watchAuthState: user data found');
          return entity;
        }
        debugPrint('[AUTH] AuthRepo.watchAuthState: no Firestore doc');
        return null;
      } catch (e, st) {
        debugPrint('[AUTH] AuthRepo.watchAuthState error: $e\n$st');
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

Future<void> _checkAndSeedDatabase() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final categoriesSnap = await firestore.collection('categories').limit(1).get();
    if (categoriesSnap.docs.isNotEmpty) {
      debugPrint('[SEED] Database already has categories. Skipping seed.');
      return;
    }

    debugPrint('[SEED] Database is empty. Seeding default categories and products...');

    // Seed Categories
    final categories = {
      'cat_meat': {
        'nameAr': 'لحوم',
        'nameEn': 'Meat',
        'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
        'isVisible': true,
        'isActive': true,
        'isDeleted': false,
        'sortOrder': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'cat_poultry': {
        'nameAr': 'دواجن',
        'nameEn': 'Poultry',
        'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
        'isVisible': true,
        'isActive': true,
        'isDeleted': false,
        'sortOrder': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'cat_frozen': {
        'nameAr': 'مجمدات',
        'nameEn': 'Frozen',
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        'isVisible': true,
        'isActive': true,
        'isDeleted': false,
        'sortOrder': 2,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      'cat_processed': {
        'nameAr': 'مصنعات',
        'nameEn': 'Processed Foods',
        'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=500',
        'isVisible': true,
        'isActive': true,
        'isDeleted': false,
        'sortOrder': 3,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    };

    for (final entry in categories.entries) {
      await firestore.collection('categories').doc(entry.key).set(entry.value);
    }
    debugPrint('[SEED] Categories seeded successfully.');

    // Seed Products
    final products = {
      'prod_minced_meat': {
        'nameAr': 'لحمة مفرومة',
        'nameEn': 'Minced Meat',
        'descriptionAr': 'لحمة مفرومة طازجة 100%',
        'descriptionEn': '100% fresh minced meat',
        'price': 60.0,
        'weight': 400.0,
        'weightUnitId': 'gram',
        'imageUrl': 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=500',
        'categoryId': 'cat_meat',
        'isFeatured': true,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'currentStock': 50,
        'reservedStock': 0,
        'availableStock': 50,
        'minimumStock': 5,
        'reorderLevel': 10,
      },
      'prod_meat_box': {
        'nameAr': 'صندوق لحوم',
        'nameEn': 'Meat Box',
        'descriptionAr': 'صندوق لحوم مختلطة طازجة ومجمدة',
        'descriptionEn': 'Assorted fresh and frozen meat box',
        'price': 500.0,
        'weight': 1.0,
        'weightUnitId': 'box',
        'imageUrl': 'https://images.unsplash.com/photo-1602470521006-aaea8b2a7939?w=500',
        'categoryId': 'cat_meat',
        'isFeatured': true,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'currentStock': 20,
        'reservedStock': 0,
        'availableStock': 20,
        'minimumStock': 3,
        'reorderLevel': 5,
      },
      'prod_chicken': {
        'nameAr': 'دجاج طازج',
        'nameEn': 'Fresh Chicken',
        'descriptionAr': 'دجاج طازج مذبوح يومياً',
        'descriptionEn': 'Freshly slaughtered chicken',
        'price': 85.0,
        'weight': 1.0,
        'weightUnitId': 'kg',
        'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
        'categoryId': 'cat_poultry',
        'isFeatured': true,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'currentStock': 4,
        'reservedStock': 0,
        'availableStock': 4,
        'minimumStock': 2,
        'reorderLevel': 10,
      },
      'prod_frozen_burger': {
        'nameAr': 'برجر مجمد',
        'nameEn': 'Frozen Burger',
        'descriptionAr': 'طباق برجر مجمد جاهز للشوي',
        'descriptionEn': 'Ready-to-grill frozen burger patties',
        'price': 45.0,
        'weight': 400.0,
        'weightUnitId': 'gram',
        'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        'categoryId': 'cat_frozen',
        'isFeatured': false,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'currentStock': 0,
        'reservedStock': 0,
        'availableStock': 0,
        'minimumStock': 2,
        'reorderLevel': 5,
      },
    };

    for (final entry in products.entries) {
      await firestore.collection('products').doc(entry.key).set(entry.value);
    }
    debugPrint('[SEED] Products seeded successfully.');

  } catch (e, st) {
    debugPrint('[SEED] Database seeding failed: $e\n$st');
  }
}
