import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/providers/firebase_providers.dart';
import 'package:fresh_market/data/datasources/firebase/product_firebase_datasource.dart';
import 'package:fresh_market/data/datasources/local/product_local_datasource.dart';
import 'package:fresh_market/data/repositories/product_repository_impl.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

final productFirebaseDataSourceProvider = Provider<ProductFirebaseDataSource>((ref) {
  return ProductFirebaseDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSourceImpl();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final firebase = ref.watch(productFirebaseDataSourceProvider);
  final local = ref.watch(productLocalDataSourceProvider);
  return ProductRepositoryImpl(
    firebaseDataSource: firebase,
    localDataSource: local,
  );
});
