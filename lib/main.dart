import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/firebase_options.dart';
import 'core/providers/firebase_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      overrides: [
        firebaseInitResultProvider.overrideWithValue(FirebaseInitResult.initialized),
      ],
      child: const FreshMarketApp(),
    ),
  );
}
