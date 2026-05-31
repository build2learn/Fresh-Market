import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/app_exception.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/weight_unit_repository.dart';
import '../datasources/firebase/weight_unit_firebase_datasource.dart';
import '../datasources/local/weight_unit_local_datasource.dart';
import '../repositories/weight_unit_repository_impl.dart';

final _weightUnitFirebaseDataSourceProvider = Provider<WeightUnitFirebaseDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return WeightUnitFirebaseDataSourceImpl(firestore: firestore);
});

final _weightUnitLocalDataSourceProvider = Provider<WeightUnitLocalDataSource>((ref) {
  final prefsAsync = ref.watch(_sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  if (prefs == null) {
    throw FirestoreException(message: 'SharedPreferences not initialized');
  }
  return WeightUnitLocalDataSourceImpl(prefs: prefs);
});

final _sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final weightUnitRepositoryProvider = Provider<WeightUnitRepository>((ref) {
  final firebase = ref.watch(_weightUnitFirebaseDataSourceProvider);
  final local = ref.watch(_weightUnitLocalDataSourceProvider);
  return WeightUnitRepositoryImpl(
    firebaseDataSource: firebase,
    localDataSource: local,
  );
});
