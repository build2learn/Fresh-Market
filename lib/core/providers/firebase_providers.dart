import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class FirebaseInitResult {
  final bool isSuccess;
  final String? error;
  const FirebaseInitResult._(this.isSuccess, this.error);
  static const initialized = FirebaseInitResult._(true, null);
  static const notInitialized = FirebaseInitResult._(false, 'Firebase not configured');
  factory FirebaseInitResult.failed(String message) => FirebaseInitResult._(false, message);
}

final firebaseInitResultProvider = Provider<FirebaseInitResult>((ref) {
  return FirebaseInitResult.notInitialized;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final firestoreSettingsProvider = Provider<void>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  firestore.settings = const Settings(persistenceEnabled: true);
});
