import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/expense.entity.dart';
import '../../../../data/providers/expense_repository_provider.dart';

final expensesListStreamProvider = StreamProvider.autoDispose<List<ExpenseEntity>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchExpenses();
});
