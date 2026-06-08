import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../config/env_config.dart';
import '../../core/utils/result.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../../data/providers/auth_repository_provider.dart';
import '../../domain/entities/user.entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/firebase_providers.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Result<UserEntity>> signIn(String email, String password) async {
    return Future.error('Mock: signIn not available');
  }

  @override
  Future<Result<UserEntity>> signUp(String email, String password, String? displayName) async {
    return Future.error('Mock: signUp not available');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    debugPrint('[MOCK] AuthRepo.getCurrentUser: returning null');
    return const Success(null);
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    debugPrint('[MOCK] AuthRepo.watchAuthState: returning null stream');
    return Stream.value(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    return Future.error('Mock: sendPasswordReset not available');
  }
}

final class Bootstrap {
  Bootstrap._();

  static Future<void> run({Flavor flavor = Flavor.development}) async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[BOOT] Bootstrap.run() started with flavor: $flavor');

    EnvConfig.init(flavor);
    debugPrint('[BOOT] EnvConfig initialized');

    final initResult = await _initFirebaseWithTimeout();
    debugPrint('[BOOT] Firebase status: ${initResult.isSuccess}');

    debugPrint('[BOOT] Launching app...');
    runApp(
      ProviderScope(
        overrides: [
          firebaseInitResultProvider.overrideWithValue(initResult),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
        child: const FreshMarketApp(),
      ),
    );
    debugPrint('[BOOT] App launched');
  }

  static Future<FirebaseInitResult> _initFirebaseWithTimeout() async {
    try {
      final result = await _initFirebase().timeout(const Duration(seconds: 15));
      return result;
    } on TimeoutException {
      debugPrint('[Bootstrap] Firebase init TIMEOUT after 15s');
      return FirebaseInitResult.failed('Firebase initialization timed out after 15s');
    }
  }

  static Future<FirebaseInitResult> _initFirebase() async {
    try {
      debugPrint('[BOOT] SKIPPING Firebase.initializeApp() — mock startup');
      // Firebase.initializeApp is disabled for testing
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('[BOOT] Firebase init skipped (mock)');

      debugPrint('[BOOT] Initializing AuthLocalDataSource (SharedPreferences)...');
      await AuthLocalDataSourceImpl.init();
      debugPrint('[BOOT] AuthLocalDataSource initialized');

      debugPrint('[BOOT] Initializing ProductLocalDataSource (SharedPreferences)...');
      await ProductLocalDataSourceImpl.init();
      debugPrint('[BOOT] ProductLocalDataSource initialized');

      return FirebaseInitResult.initialized;
    } catch (e, st) {
      debugPrint('[BOOT] Firebase init FAILED: $e\n$st');
      return FirebaseInitResult.failed(e.toString());
    }
  }
}
