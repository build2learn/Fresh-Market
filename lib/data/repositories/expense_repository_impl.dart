import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/expense.entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../dto/expense.dto.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _expensesCol => _firestore.collection('expenses');

  @override
  Future<Result<List<ExpenseEntity>>> getExpenses() async {
    try {
      final snapshot = await _expensesCol.orderBy('expenseDate', descending: true).get();
      final expenses = snapshot.docs.map((doc) {
        final dto = ExpenseDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return ExpenseModel.fromDto(dto).toEntity();
      }).toList();
      return Success(expenses);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<ExpenseEntity>> watchExpenses() {
    return _expensesCol
        .orderBy('expenseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = ExpenseDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return ExpenseModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<ExpenseEntity>> createExpense(ExpenseEntity expense) async {
    try {
      final docRef = await _expensesCol.add(
        ExpenseModel.fromEntity(expense).toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      final doc = await docRef.get();
      final dto = ExpenseDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(ExpenseModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    try {
      await _expensesCol.doc(expense.id).update(
        ExpenseModel.fromEntity(expense).toMap()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      return Success(expense);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteExpense(String expenseId) async {
    try {
      await _expensesCol.doc(expenseId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
