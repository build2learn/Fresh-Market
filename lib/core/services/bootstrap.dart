import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../config/env_config.dart';
import '../../config/firebase_options.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/product_local_datasource.dart';
import '../providers/firebase_providers.dart';

final class Bootstrap {
  Bootstrap._();

  static Future<void> run({Flavor flavor = Flavor.development}) async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[Bootstrap] run() started with flavor: $flavor');

    EnvConfig.init(flavor);
    debugPrint('[Bootstrap] EnvConfig initialized');

    final initResult = await _initFirebaseWithTimeout();
    debugPrint('[Bootstrap] Firebase status: ${initResult.isSuccess}');

    debugPrint('[Bootstrap] Launching app...');
    runApp(
      ProviderScope(
        overrides: [
          firebaseInitResultProvider.overrideWithValue(initResult),
        ],
        child: const FreshMarketApp(),
      ),
    );
    debugPrint('[Bootstrap] App launched');
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
      debugPrint('[Bootstrap] Initializing Firebase...');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('[Bootstrap] Firebase initialized successfully');

      debugPrint('[Bootstrap] Initializing AuthLocalDataSource...');
      await AuthLocalDataSourceImpl.init();
      debugPrint('[Bootstrap] AuthLocalDataSource initialized');

      debugPrint('[Bootstrap] Initializing ProductLocalDataSource...');
      await ProductLocalDataSourceImpl.init();
      debugPrint('[Bootstrap] ProductLocalDataSource initialized');

      return FirebaseInitResult.initialized;
    } catch (e, st) {
      debugPrint('[Bootstrap] Firebase init FAILED: $e\n$st');
      return FirebaseInitResult.failed(e.toString());
    }
  }
}
