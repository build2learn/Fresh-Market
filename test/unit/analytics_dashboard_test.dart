import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/presentation/features/admin/pages/admin_analytics_page.dart';
import 'package:fresh_market/core/providers/locale_provider.dart';
import 'package:fresh_market/data/providers/expense_repository_provider.dart';

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

  group('Analytics Dashboard Unit Tests', () {
    test('Verify real-time analytics aggregation and status = Delivered revenue rule', () async {
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();
      
      // Seed Mock Orders with specific dates and statuses
      final ordersList = [
        // Today - Delivered (should count towards revenue today & month, orders count today & month)
        {
          'id': 'test_ord_1',
          'userId': 'customer_1',
          'userEmail': 'c1@test.com',
          'status': 'Delivered',
          'totalAmount': 200.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'items': [
            {
              'productId': 'prod_chicken',
              'productNameAr': 'دجاج طازج',
              'productNameEn': 'Fresh Chicken',
              'price': 100.0,
              'quantity': 2,
            }
          ],
        },
        // Today - Pending (should count towards orders today & month, but NOT revenue today & month)
        {
          'id': 'test_ord_2',
          'userId': 'customer_2',
          'userEmail': 'c2@test.com',
          'status': 'Pending',
          'totalAmount': 150.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'items': [
            {
              'productId': 'prod_minced_meat',
              'productNameAr': 'لحمة مفرومة',
              'productNameEn': 'Minced Meat',
              'price': 150.0,
              'quantity': 1,
            }
          ],
        },
        // 5 Days Ago - Delivered (should count towards orders month, revenue month, but NOT today)
        {
          'id': 'test_ord_3',
          'userId': 'customer_1',
          'userEmail': 'c1@test.com',
          'status': 'Delivered',
          'totalAmount': 300.0,
          'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          'items': [
            {
              'productId': 'prod_frozen_burger',
              'productNameAr': 'برجر مجمد',
              'productNameEn': 'Frozen Burger',
              'price': 100.0,
              'quantity': 3,
            }
          ],
        },
        // 45 Days Ago - Delivered (should NOT count towards today or this month orders/revenue)
        {
          'id': 'test_ord_4',
          'userId': 'customer_1',
          'userEmail': 'c1@test.com',
          'status': 'Delivered',
          'totalAmount': 500.0,
          'createdAt': now.subtract(const Duration(days: 45)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 45)).toIso8601String(),
          'items': [
            {
              'productId': 'prod_chicken',
              'productNameAr': 'دجاج طازج',
              'productNameEn': 'Fresh Chicken',
              'price': 100.0,
              'quantity': 5,
            }
          ],
        },
      ];

      await prefs.setStringList('mock_orders', ordersList.map((e) => jsonEncode(e)).toList());

      // Seed Mock Users
      final usersList = [
        {
          'id': 'customer_1',
          'email': 'c1@test.com',
          'displayName': 'Customer 1',
          'role': 'customer',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'customer_2',
          'email': 'c2@test.com',
          'displayName': 'Customer 2',
          'role': 'customer',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }
      ];
      await prefs.setStringList('mock_auth_users', usersList.map((e) => jsonEncode(e)).toList());

      // Setup Mock Repositories
      final orderRepo = MockOrderRepository(prefs);
      final productRepo = MockProductRepository(prefs);
      final userRepo = MockUserRepository(prefs);
      final categoryRepo = MockCategoryRepository(prefs);
      final expenseRepo = MockExpenseRepository(prefs);

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

      // Read Analytics stats
      final stats = await container.read(adminAnalyticsProvider.future);

      // Verify dashboard cards counts
      expect(stats.ordersToday, 2); // test_ord_1 and test_ord_2 are today
      expect(stats.ordersThisMonth, 3); // test_ord_1, test_ord_2, and test_ord_3 are within the month
      expect(stats.revenueToday, 200.0); // Only test_ord_1 is today and Delivered
      expect(stats.revenueThisMonth, 500.0); // test_ord_1 (200) + test_ord_3 (300) are Delivered within the month

      // Verify general counts
      expect(stats.productsCount > 0, true);
      expect(stats.customersCount > 0, true);

      // Verify top selling logic sorted in descending order of quantities
      expect(stats.topProducts.isNotEmpty, true);
      expect(stats.topProducts[0].key, 'Frozen Burger'); // 3 units sold in filter range
      expect(stats.topProducts[1].key, 'Fresh Chicken'); // 2 units sold in filter range
    });

    test('Verify analytics time filters changes daily revenue data grouping', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final ordersList = [
        {
          'id': 'test_ord_1',
          'userId': 'customer_1',
          'userEmail': 'c1@test.com',
          'status': 'Delivered',
          'totalAmount': 100.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'items': [
            {
              'productId': 'prod_chicken',
              'productNameAr': 'دجاج طازج',
              'productNameEn': 'Fresh Chicken',
              'price': 100.0,
              'quantity': 1,
            }
          ],
        },
      ];

      await prefs.setStringList('mock_orders', ordersList.map((e) => jsonEncode(e)).toList());

      final orderRepo = MockOrderRepository(prefs);
      final productRepo = MockProductRepository(prefs);
      final userRepo = MockUserRepository(prefs);
      final categoryRepo = MockCategoryRepository(prefs);
      final expenseRepo = MockExpenseRepository(prefs);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(orderRepo),
          productRepositoryProvider.overrideWithValue(productRepo),
          userRepositoryProvider.overrideWithValue(userRepo),
          categoryRepositoryProvider.overrideWithValue(categoryRepo),
          expenseRepositoryProvider.overrideWithValue(expenseRepo),
        ],
      );
      addTearDown(container.dispose);

      // Set filter to Today
      container.read(analyticsFilterProvider.notifier).state = 'Today';
      var stats = await container.read(adminAnalyticsProvider.future);
      // Hourly intervals (6 slots)
      expect(stats.dailyRevenueData.length, 6);

      // Set filter to 7 Days
      container.read(analyticsFilterProvider.notifier).state = '7 Days';
      stats = await container.read(adminAnalyticsProvider.future);
      expect(stats.dailyRevenueData.length, 7);

      // Set filter to 30 Days
      container.read(analyticsFilterProvider.notifier).state = '30 Days';
      stats = await container.read(adminAnalyticsProvider.future);
      expect(stats.dailyRevenueData.length, 30);
    });
  });
}
