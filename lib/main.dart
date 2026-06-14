import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/providers/firebase_providers.dart';

void main() async {
  print("[BOOT] main started");
  WidgetsFlutterBinding.ensureInitialized();
  print("[FIREBASE] initialize start");
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("[FIREBASE] initialize success");
  } catch (e) {
    print("[FIREBASE] initialize failed: $e");
  }
  print("[RUNAPP] runApp called");
  runApp(
    ProviderScope(
      overrides: [
        firebaseInitResultProvider.overrideWithValue(FirebaseInitResult.initialized),
      ],
      child: const FreshMarketApp(),
    ),
  );
}
