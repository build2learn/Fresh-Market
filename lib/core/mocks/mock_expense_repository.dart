import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/enums/user_role.dart';
import 'package:fresh_market/core/enums/setting_type.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/entities/setting.entity.dart';
import 'package:fresh_market/domain/entities/coupon.entity.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/repositories/auth_repository.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';
import 'package:fresh_market/domain/repositories/weight_unit_repository.dart';
import 'package:fresh_market/domain/repositories/settings_repository.dart';
import 'package:fresh_market/domain/repositories/user_repository.dart';
import 'package:fresh_market/domain/repositories/notification_repository.dart';
import 'package:fresh_market/domain/repositories/coupon_repository.dart';
import 'package:fresh_market/domain/repositories/audit_log_repository.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import 'package:fresh_market/data/dto/user.dto.dart';
import 'package:fresh_market/data/models/user_model.dart';
import 'package:fresh_market/data/dto/category.dto.dart';
import 'package:fresh_market/data/models/category_model.dart';
import 'package:fresh_market/data/dto/product.dto.dart';
import 'package:fresh_market/data/models/product_model.dart';
import 'package:fresh_market/data/dto/offer.dto.dart';
import 'package:fresh_market/data/models/offer_model.dart';
import 'package:fresh_market/data/dto/weight_unit.dto.dart';
import 'package:fresh_market/data/models/weight_unit_model.dart';
import 'package:fresh_market/data/dto/coupon.dto.dart';
import 'package:fresh_market/data/models/coupon_model.dart';
import 'package:fresh_market/data/dto/audit_log.dto.dart';
import 'package:fresh_market/data/models/audit_log_model.dart';
import 'package:fresh_market/domain/entities/lookup.entity.dart';
import 'package:fresh_market/domain/repositories/lookup_repository.dart';
import 'package:fresh_market/data/dto/lookup.dto.dart';
import 'package:fresh_market/data/models/lookup_model.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/repositories/order_repository.dart';
import 'package:fresh_market/data/dto/order.dto.dart';
import 'package:fresh_market/data/models/order_model.dart';
import 'package:fresh_market/domain/entities/address.entity.dart';
import 'package:fresh_market/domain/repositories/address_repository.dart';
import 'package:fresh_market/data/dto/address.dto.dart';
import 'package:fresh_market/data/models/address_model.dart';
import 'package:fresh_market/domain/entities/supplier.entity.dart';
import 'package:fresh_market/domain/repositories/supplier_repository.dart';
import 'package:fresh_market/data/dto/supplier.dto.dart';
import 'package:fresh_market/data/models/supplier_model.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/repositories/purchase_order_repository.dart';
import 'package:fresh_market/data/dto/purchase_order.dto.dart';
import 'package:fresh_market/data/models/purchase_order_model.dart';
import 'package:fresh_market/domain/entities/stock_history.entity.dart';
import 'package:fresh_market/domain/repositories/stock_history_repository.dart';
import 'package:fresh_market/data/dto/stock_history.dto.dart';
import 'package:fresh_market/domain/entities/supplier_payment.entity.dart';
import 'package:fresh_market/domain/repositories/supplier_payment_repository.dart';
import 'package:fresh_market/data/dto/supplier_payment.dto.dart';
import 'package:fresh_market/data/models/supplier_payment_model.dart';
import 'package:fresh_market/domain/entities/batch.entity.dart';
import 'package:fresh_market/domain/repositories/batch_repository.dart';
import 'package:fresh_market/data/dto/batch.dto.dart';
import 'package:fresh_market/data/models/batch_model.dart';
import 'package:fresh_market/domain/entities/expense.entity.dart';
import 'package:fresh_market/domain/repositories/expense_repository.dart';
import 'package:fresh_market/data/dto/expense.dto.dart';
import 'package:fresh_market/data/models/expense_model.dart';
import 'package:fresh_market/domain/entities/warehouse.entity.dart';
import 'package:fresh_market/domain/entities/warehouse_inventory.entity.dart';
import 'package:fresh_market/domain/entities/stock_transfer.entity.dart';
import 'package:fresh_market/domain/repositories/warehouse_repository.dart';
import 'package:fresh_market/data/dto/warehouse.dto.dart';
import 'package:fresh_market/data/dto/warehouse_inventory.dto.dart';
import 'package:fresh_market/data/dto/stock_transfer.dto.dart';
import 'package:fresh_market/data/models/warehouse_model.dart';
import 'package:fresh_market/data/models/warehouse_inventory_model.dart';
import 'package:fresh_market/data/models/stock_transfer_model.dart';
import 'package:fresh_market/core/mocks/mock_helpers.dart';
import 'package:fresh_market/core/services/notification_service.dart';

class MockExpenseRepository implements ExpenseRepository {
  static const String _expensesKey = 'mock_expenses';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<ExpenseEntity>>.broadcast();

  MockExpenseRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_expensesKey) ?? [];
    if (list.isEmpty) {
      final now = DateTime.now();
      final seedExpenses = [
        {
          'id': 'expense_seed_1',
          'category': 'Rent',
          'amount': 12000.0,
          'currency': 'EGP',
          'expenseDate': now.subtract(const Duration(days: 10)).toIso8601String(),
          'description': 'Store monthly rent',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_2',
          'category': 'Salaries',
          'amount': 35000.0,
          'currency': 'E£',
          'expenseDate': now.subtract(const Duration(days: 5)).toIso8601String(),
          'description': 'June salaries layout',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_3',
          'category': 'Electricity',
          'amount': 2200.0,
          'currency': 'EGP',
          'expenseDate': now.subtract(const Duration(days: 3)).toIso8601String(),
          'description': 'Main warehouse bill',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_4',
          'category': 'Internet',
          'amount': 600.0,
          'currency': 'EGP',
          'expenseDate': now.subtract(const Duration(days: 2)).toIso8601String(),
          'description': 'Fiber internet subscription',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_5',
          'category': 'Fuel',
          'amount': 1500.0,
          'currency': 'E£',
          'expenseDate': now.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'Delivery bikes fuel allowance',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_6',
          'category': 'Maintenance',
          'amount': 1800.0,
          'currency': 'EGP',
          'expenseDate': now.toIso8601String(),
          'description': 'Fridge repair works',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
      _prefs.setStringList(_expensesKey, seedExpenses.map((e) => jsonEncode(e)).toList());
    }
  }

  List<ExpenseDto> _getExpenses() {
    final list = _prefs.getStringList(_expensesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return ExpenseDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<ExpenseDto> list) {
    _prefs.setStringList(_expensesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => ExpenseModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<ExpenseEntity>>> getExpenses() async {
    final all = _getExpenses()
        .map((dto) => ExpenseModel.fromDto(dto).toEntity())
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return Success(all);
  }

  @override
  Stream<List<ExpenseEntity>> watchExpenses() {
    Timer.run(() {
      final all = _getExpenses()
          .map((dto) => ExpenseModel.fromDto(dto).toEntity())
          .toList()
        ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      _controller.add(all);
    });
    return _controller.stream;
  }

  @override
  Future<Result<ExpenseEntity>> createExpense(ExpenseEntity expense) async {
    final all = _getExpenses();
    final newId = expense.id.isEmpty ? 'expense_${DateTime.now().millisecondsSinceEpoch}' : expense.id;
    final finalExpense = expense.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(ExpenseModel.fromEntity(finalExpense));
    _saveAll(all);
    return Success(finalExpense);
  }

  @override
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    final all = _getExpenses();
    final idx = all.indexWhere((e) => e.id == expense.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Expense not found'));
    final finalExpense = expense.copyWith(updatedAt: DateTime.now());
    all[idx] = ExpenseModel.fromEntity(finalExpense);
    _saveAll(all);
    return Success(finalExpense);
  }

  @override
  Future<Result<void>> deleteExpense(String expenseId) async {
    final all = _getExpenses();
    all.removeWhere((e) => e.id == expenseId);
    _saveAll(all);
    return const Success(null);
  }
}
