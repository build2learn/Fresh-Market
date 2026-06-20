import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../repositories/purchase_order_repository_impl.dart';

final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return PurchaseOrderRepositoryImpl(firestore: firestore);
});
