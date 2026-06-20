import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../repositories/warehouse_repository_impl.dart';

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return WarehouseRepositoryImpl(firestore: firestore);
});
