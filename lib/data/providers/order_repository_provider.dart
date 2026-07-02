import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/order_repository.dart';
import '../repositories/order_repository_impl.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return OrderRepositoryImpl(firestore: firestore, auth: auth);
});
