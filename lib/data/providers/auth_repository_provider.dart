import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/data/datasources/firebase/auth_firebase_datasource.dart';
import 'package:fresh_market/data/datasources/local/auth_local_datasource.dart';
import 'package:fresh_market/data/repositories/auth_repository_impl.dart';
import 'package:fresh_market/domain/repositories/auth_repository.dart';

final authFirebaseDataSourceProvider = Provider<AuthFirebaseDataSource>((ref) {
  return AuthFirebaseDataSourceImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebase = ref.watch(authFirebaseDataSourceProvider);
  final local = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(
    firebaseDataSource: firebase,
    localDataSource: local,
  );
});
