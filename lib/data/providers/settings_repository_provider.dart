import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/data/datasources/firebase/settings_firebase_datasource.dart';
import 'package:fresh_market/data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsFirebaseDataSourceProvider = Provider<SettingsFirebaseDataSource>((ref) {
  return SettingsFirebaseDataSourceImpl(firestore: ref.watch(firebaseFirestoreProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    firebaseDataSource: ref.watch(settingsFirebaseDataSourceProvider),
  );
});
