import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/app_exception.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/firebase/category_firebase_datasource.dart';
import '../datasources/local/category_local_datasource.dart';
import '../repositories/category_repository_impl.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final _categoryFirebaseDataSourceProvider = Provider<CategoryFirebaseDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CategoryFirebaseDataSourceImpl(firestore: firestore);
});

final _categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  if (prefs == null) {
    throw FirestoreException(message: 'SharedPreferences not initialized');
  }
  return CategoryLocalDataSourceImpl(prefs: prefs);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final firebase = ref.watch(_categoryFirebaseDataSourceProvider);
  final local = ref.watch(_categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(
    firebaseDataSource: firebase,
    localDataSource: local,
  );
});
