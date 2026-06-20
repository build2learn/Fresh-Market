import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/presentation/features/admin/pages/admin_customers_page.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Customer Management Unit Tests', () {
    test('Verify CustomerStats calculations (totalSpend, orderCount, lastOrderDate)', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Seed Mock Users (2 customers)
      final usersList = [
        {
          'id': 'customer_john',
          'email': 'john@test.com',
          'displayName': 'John Doe',
          'role': 'customer',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'customer_jane',
          'email': 'jane@test.com',
          'displayName': 'Jane Smith',
          'role': 'customer',
          'isActive': false,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }
      ];
      await prefs.setStringList('mock_auth_users', usersList.map((e) => jsonEncode(e)).toList());

      // Seed Mock Orders:
      // John has:
      // - 1 Delivered order today (200.0)
      // - 1 Pending order 2 days ago (150.0)
      // - 1 Cancelled order 5 days ago (300.0) -> Should NOT count in totalSpend or active orderCount
      // Jane has:
      // - 1 Delivered order today (400.0)
      final ordersList = [
        {
          'id': 'ord_john_1',
          'userId': 'customer_john',
          'userEmail': 'john@test.com',
          'status': 'Delivered',
          'totalAmount': 200.0,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'items': [],
        },
        {
          'id': 'ord_john_2',
          'userId': 'customer_john',
          'userEmail': 'john@test.com',
          'status': 'Pending',
          'totalAmount': 150.0,
          'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'items': [],
        },
        {
          'id': 'ord_john_3',
          'userId': 'customer_john',
          'userEmail': 'john@test.com',
          'status': 'Cancelled',
          'totalAmount': 300.0,
          'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          'items': [],
        },
        {
          'id': 'ord_jane_1',
          'userId': 'customer_jane',
          'userEmail': 'jane@test.com',
          'status': 'Delivered',
          'totalAmount': 400.0,
          'createdAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
          'items': [],
        },
      ];
      await prefs.setStringList('mock_orders', ordersList.map((e) => jsonEncode(e)).toList());

      final orderRepo = MockOrderRepository(prefs);
      final productRepo = MockProductRepository(prefs);
      final userRepo = MockUserRepository(prefs);
      final categoryRepo = MockCategoryRepository(prefs);

      final container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(orderRepo),
          productRepositoryProvider.overrideWithValue(productRepo),
          userRepositoryProvider.overrideWithValue(userRepo),
          categoryRepositoryProvider.overrideWithValue(categoryRepo),
        ],
      );
      addTearDown(container.dispose);

      final customerList = await container.read(adminCustomersProvider.future);

      expect(customerList.length, 2);

      final johnStats = customerList.firstWhere((c) => c.user.id == 'customer_john');
      final janeStats = customerList.firstWhere((c) => c.user.id == 'customer_jane');

      // John verification:
      // Orders: Delivered (200) + Pending (150) = 350 spend.
      // Active count: 2 (Delivered + Pending). Total list: 3 (Delivered + Pending + Cancelled).
      expect(johnStats.orderCount, 2);
      expect(johnStats.totalSpend, 350.0);
      expect(johnStats.orders.length, 3);
      expect(johnStats.lastOrderDate != null, true);
      // Last order date should be today (now)
      expect(johnStats.lastOrderDate!.day, now.day);

      // Jane verification:
      expect(janeStats.orderCount, 1);
      expect(janeStats.totalSpend, 400.0);
      expect(janeStats.user.isActive, false); // should read false initially
    });

    test('Verify customer toggle active/inactive status updates repository', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final usersList = [
        {
          'id': 'customer_john',
          'email': 'john@test.com',
          'displayName': 'John Doe',
          'role': 'customer',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        }
      ];
      await prefs.setStringList('mock_auth_users', usersList.map((e) => jsonEncode(e)).toList());

      final userRepo = MockUserRepository(prefs);
      final orderRepo = MockOrderRepository(prefs);

      final container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(userRepo),
          orderRepositoryProvider.overrideWithValue(orderRepo),
        ],
      );
      addTearDown(container.dispose);

      // Toggle status to inactive
      final toggleRes = await userRepo.toggleUserActive('customer_john', false);
      expect(toggleRes, isA<Success<UserEntity>>());
      
      final updatedUser = (toggleRes as Success<UserEntity>).data;
      expect(updatedUser.isActive, false);

      // Verify stats list updates
      final statsList = await container.read(adminCustomersProvider.future);
      expect(statsList.first.user.isActive, false);
    });
  });
}
