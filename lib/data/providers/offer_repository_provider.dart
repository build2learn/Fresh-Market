import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/app_exception.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/firebase/offer_firebase_datasource.dart';
import '../datasources/local/offer_local_datasource.dart';
import '../repositories/offer_repository_impl.dart';

final _offerFirebaseDataSourceProvider = Provider<OfferFirebaseDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  return OfferFirebaseDataSourceImpl(firestore: firestore, storage: storage);
});

final _offerLocalDataSourceProvider = Provider<OfferLocalDataSource>((ref) {
  final prefsAsync = ref.watch(_sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  if (prefs == null) {
    throw FirestoreException(message: 'SharedPreferences not initialized');
  }
  return OfferLocalDataSourceImpl(prefs: prefs);
});

final _sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  final firebase = ref.watch(_offerFirebaseDataSourceProvider);
  final local = ref.watch(_offerLocalDataSourceProvider);
  return OfferRepositoryImpl(
    firebaseDataSource: firebase,
    localDataSource: local,
  );
});
