import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/supplier_payment_repository.dart';
import '../repositories/supplier_payment_repository_impl.dart';

final supplierPaymentRepositoryProvider = Provider<SupplierPaymentRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return SupplierPaymentRepositoryImpl(firestore: firestore);
});
