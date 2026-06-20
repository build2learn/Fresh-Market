import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/expense.entity.dart';

abstract interface class ExpenseRepository {
  Future<Result<List<ExpenseEntity>>> getExpenses();
  Stream<List<ExpenseEntity>> watchExpenses();
  Future<Result<ExpenseEntity>> createExpense(ExpenseEntity expense);
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity expense);
  Future<Result<void>> deleteExpense(String expenseId);
}
