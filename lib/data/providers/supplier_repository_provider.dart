import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../repositories/supplier_repository_impl.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return SupplierRepositoryImpl(firestore: firestore);
});
