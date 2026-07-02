import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/expense.entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../dto/expense.dto.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExpenseRepositoryImpl({
    required FirebaseFirestore firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _expensesCol => _firestore.collection('expenses');

  String get _currentUserId => _auth.currentUser?.uid ?? 'system';
  String get _currentUserEmail => _auth.currentUser?.email ?? 'system@freshmarket.com';

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
    if (expense.amount <= 0) {
      return Failure(const FirestoreException(message: 'Expense amount must be greater than zero'));
    }
    try {
      final docRef = _expensesCol.doc();
      final finalExpense = expense.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        final expenseMap = ExpenseModel.fromEntity(finalExpense).toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp();

        transaction.set(docRef, expenseMap);

        // Audit Trail entry
        final logRef = _firestore.collection('audit_logs').doc();
        transaction.set(logRef, {
          'id': logRef.id,
          'userId': _currentUserId,
          'userEmail': _currentUserEmail,
          'action': 'Create Expense',
          'details': 'Created expense ${finalExpense.category} of ${finalExpense.amount} ${finalExpense.currency} (${finalExpense.description})',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return Success(finalExpense);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    if (expense.amount <= 0) {
      return Failure(const FirestoreException(message: 'Expense amount must be greater than zero'));
    }
    try {
      final docRef = _expensesCol.doc(expense.id);

      await _firestore.runTransaction((transaction) async {
        final docSnap = await transaction.get(docRef);
        if (!docSnap.exists) {
          throw const FirestoreException(message: 'Expense not found');
        }

        final expenseMap = ExpenseModel.fromEntity(expense).toMap()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp();

        transaction.update(docRef, expenseMap);

        // Audit Trail entry
        final logRef = _firestore.collection('audit_logs').doc();
        transaction.set(logRef, {
          'id': logRef.id,
          'userId': _currentUserId,
          'userEmail': _currentUserEmail,
          'action': 'Update Expense',
          'details': 'Updated expense ${expense.id}: ${expense.category} of ${expense.amount} ${expense.currency}',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return Success(expense);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteExpense(String expenseId) async {
    try {
      final docRef = _expensesCol.doc(expenseId);

      await _firestore.runTransaction((transaction) async {
        final docSnap = await transaction.get(docRef);
        if (!docSnap.exists) {
          throw const FirestoreException(message: 'Expense not found');
        }

        final data = docSnap.data() as Map<String, dynamic>;
        final category = data['category'] as String? ?? '';
        final amount = data['amount'] as num? ?? 0.0;
        final currency = data['currency'] as String? ?? '';

        transaction.delete(docRef);

        // Audit Trail entry
        final logRef = _firestore.collection('audit_logs').doc();
        transaction.set(logRef, {
          'id': logRef.id,
          'userId': _currentUserId,
          'userEmail': _currentUserEmail,
          'action': 'Delete Expense',
          'details': 'Deleted expense $expenseId: $category of $amount $currency',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
