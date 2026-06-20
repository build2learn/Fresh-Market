import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/expense.entity.dart';
import 'package:fresh_market/domain/repositories/expense_repository.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/expense_repository_provider.dart';
import 'package:fresh_market/presentation/features/admin/pages/admin_analytics_page.dart';
import 'package:fresh_market/core/providers/locale_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class TestLocaleNotifier extends LocaleNotifier {
  TestLocaleNotifier(Locale locale) {
    state = locale;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('ar', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Expense Repository CRUD & Category Tests', () {
    test('Verify Expense CRUD operations', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = MockExpenseRepository(prefs);

      // 1. Initial seeds (MockExpenseRepository creates 6 seeds)
      final initialRes = await repo.getExpenses();
      expect(initialRes, isA<Success<List<ExpenseEntity>>>());
      final initialList = (initialRes as Success<List<ExpenseEntity>>).data;
      expect(initialList.length, 6);

      // 2. Create new expense
      final newExpense = ExpenseEntity(
        id: '',
        category: 'Rent',
        amount: 8000.0,
        currency: 'EGP',
        expenseDate: DateTime.now(),
        description: 'Office sublease cost',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createRes = await repo.createExpense(newExpense);
      expect(createRes, isA<Success<ExpenseEntity>>());
      final created = (createRes as Success<ExpenseEntity>).data;
      expect(created.id.isNotEmpty, true);
      expect(created.amount, 8000.0);

      // 3. Update expense details
      final updatedExpense = created.copyWith(amount: 8500.0, description: 'Office sublease cost - adjusted');
      final updateRes = await repo.updateExpense(updatedExpense);
      expect(updateRes, isA<Success<ExpenseEntity>>());
      final updated = (updateRes as Success<ExpenseEntity>).data;
      expect(updated.amount, 8500.0);
      expect(updated.description, 'Office sublease cost - adjusted');

      // 4. Verify in list
      final listRes = await repo.getExpenses();
      final listData = (listRes as Success<List<ExpenseEntity>>).data;
      expect(listData.length, 7);
      expect(listData.any((e) => e.id == created.id && e.amount == 8500.0), true);

      // 5. Delete expense
      final deleteRes = await repo.deleteExpense(created.id);
      expect(deleteRes, isA<Success<void>>());

      // 6. Verify deleted
      final listAfterDeleteRes = await repo.getExpenses();
      final listAfterDelete = (listAfterDeleteRes as Success<List<ExpenseEntity>>).data;
      expect(listAfterDelete.length, 6);
      expect(listAfterDelete.any((e) => e.id == created.id), false);
    });

    test('Verify valid expense categories', () async {
      final validCategories = [
        'Rent',
        'Salaries',
        'Fuel',
        'Electricity',
        'Internet',
        'Maintenance',
      ];

      final expense = ExpenseEntity(
        id: 'test_exp',
        category: 'Salaries',
        amount: 300.0,
        currency: 'E£',
        expenseDate: DateTime.now(),
        description: 'Bilingual helper payment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(validCategories.contains(expense.category), true);
    });
  });

  group('Expense & Net Profit Analytics Integration Tests', () {
    test('Verify Revenue, Expenses and Net Profit calculations', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // 1. Mock 50,000 EGP in Revenue (Seed a Delivered order this month)
      final ordersList = [
        {
          'id': 'ord_rev_1',
          'userId': 'customer_1',
          'userEmail': 'c1@test.com',
          'status': 'Delivered',
          'totalAmount': 50000.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'items': [
            {
              'productId': 'prod_chicken',
              'productNameAr': 'دجاج طازج',
              'productNameEn': 'Fresh Chicken',
              'price': 50000.0,
              'quantity': 1,
            }
          ],
        }
      ];
      await prefs.setStringList('mock_orders', ordersList.map((e) => jsonEncode(e)).toList());

      // 2. Mock 15,000 EGP in Expenses (Rent = 12000, salaries = 3000)
      final expensesList = [
        {
          'id': 'exp_1',
          'category': 'Rent',
          'amount': 12000.0,
          'currency': 'EGP',
          'expenseDate': now.toIso8601String(),
          'description': 'Rent cost',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'exp_2',
          'category': 'Salaries',
          'amount': 3000.0,
          'currency': 'E£',
          'expenseDate': now.toIso8601String(),
          'description': 'Salaries cost',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }
      ];
      await prefs.setStringList('mock_expenses', expensesList.map((e) => jsonEncode(e)).toList());

      // 3. Initialize Repositories
      final orderRepo = MockOrderRepository(prefs);
      final productRepo = MockProductRepository(prefs);
      final userRepo = MockUserRepository(prefs);
      final categoryRepo = MockCategoryRepository(prefs);
      final expenseRepo = MockExpenseRepository(prefs);

      // 4. Setup ProviderContainer
      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(orderRepo),
          productRepositoryProvider.overrideWithValue(productRepo),
          userRepositoryProvider.overrideWithValue(userRepo),
          categoryRepositoryProvider.overrideWithValue(categoryRepo),
          expenseRepositoryProvider.overrideWithValue(expenseRepo),
          localeProvider.overrideWith((ref) => TestLocaleNotifier(const Locale('en'))),
          analyticsFilterProvider.overrideWith((ref) => 'This Month'),
        ],
      );
      addTearDown(container.dispose);

      // 5. Read Analytics Stats
      final stats = await container.read(adminAnalyticsProvider.future);

      // 6. Assertions
      expect(stats.revenueThisMonth, 50000.0);
      expect(stats.expensesThisMonth, 15000.0);
      expect(stats.netProfitThisMonth, 35000.0); // 50,000 - 15,000 = 35,000
    });
  });
}
