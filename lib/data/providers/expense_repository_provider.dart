import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/expense_repository.dart';
import '../repositories/expense_repository_impl.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return ExpenseRepositoryImpl(firestore: firestore, auth: auth);
});
