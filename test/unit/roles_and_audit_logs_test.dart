import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/enums/user_role.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/presentation/routing/admin_guard.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final adminGuardProvider = Provider<AdminGuard>((ref) => AdminGuard(ref));

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Roles & Permissions Unit Tests', () {
    test('Verify permissions on UserRole', () {
      // Admin
      expect(UserRole.admin.isAdmin, true);
      expect(UserRole.admin.isCustomer, false);
      expect(UserRole.admin.isStaff, true);
      expect(UserRole.admin.canManageProducts, true);
      expect(UserRole.admin.canManageOrders, true);
      expect(UserRole.admin.canManageInventory, true);
      expect(UserRole.admin.canManageReports, true);
      expect(UserRole.admin.canManageSettings, true);

      // Manager
      expect(UserRole.manager.isAdmin, false);
      expect(UserRole.manager.isCustomer, false);
      expect(UserRole.manager.isStaff, true);
      expect(UserRole.manager.canManageProducts, true);
      expect(UserRole.manager.canManageOrders, true);
      expect(UserRole.manager.canManageInventory, true);
      expect(UserRole.manager.canManageReports, true);
      expect(UserRole.manager.canManageSettings, false);

      // Warehouse
      expect(UserRole.warehouse.isAdmin, false);
      expect(UserRole.warehouse.isCustomer, false);
      expect(UserRole.warehouse.isStaff, true);
      expect(UserRole.warehouse.canManageProducts, false);
      expect(UserRole.warehouse.canManageOrders, true);
      expect(UserRole.warehouse.canManageInventory, true);
      expect(UserRole.warehouse.canManageReports, false);
      expect(UserRole.warehouse.canManageSettings, false);

      // Delivery
      expect(UserRole.delivery.isAdmin, false);
      expect(UserRole.delivery.isCustomer, false);
      expect(UserRole.delivery.isStaff, true);
      expect(UserRole.delivery.canManageProducts, false);
      expect(UserRole.delivery.canManageOrders, true);
      expect(UserRole.delivery.canManageInventory, false);
      expect(UserRole.delivery.canManageReports, false);
      expect(UserRole.delivery.canManageSettings, false);

      // Customer Service
      expect(UserRole.customerService.isAdmin, false);
      expect(UserRole.customerService.isCustomer, false);
      expect(UserRole.customerService.isStaff, true);
      expect(UserRole.customerService.canManageProducts, false);
      expect(UserRole.customerService.canManageOrders, true);
      expect(UserRole.customerService.canManageInventory, false);
      expect(UserRole.customerService.canManageReports, false);
      expect(UserRole.customerService.canManageSettings, false);

      // Customer
      expect(UserRole.customer.isAdmin, false);
      expect(UserRole.customer.isCustomer, true);
      expect(UserRole.customer.isStaff, false);
      expect(UserRole.customer.canManageProducts, false);
      expect(UserRole.customer.canManageOrders, false);
      expect(UserRole.customer.canManageInventory, false);
      expect(UserRole.customer.canManageReports, false);
      expect(UserRole.customer.canManageSettings, false);
    });

    test('Verify AdminGuard sub-path authorization and redirection', () {
      final now = DateTime.now();

      final testCases = [
        // Non-staff redirection
        _GuardTestCase(
          role: UserRole.customer,
          route: '/admin/products',
          expectedRedirect: '/home',
        ),
        // Admin permissions on settings
        _GuardTestCase(
          role: UserRole.admin,
          route: '/admin/settings',
          expectedRedirect: null,
        ),
        // Manager setting check (unauthorized -> redirect to /admin)
        _GuardTestCase(
          role: UserRole.manager,
          route: '/admin/settings',
          expectedRedirect: '/admin',
        ),
        // Manager products check (authorized -> pass)
        _GuardTestCase(
          role: UserRole.manager,
          route: '/admin/products',
          expectedRedirect: null,
        ),
        // Warehouse orders check (authorized -> pass)
        _GuardTestCase(
          role: UserRole.warehouse,
          route: '/admin/orders',
          expectedRedirect: null,
        ),
        // Warehouse products check (unauthorized -> redirect to /admin)
        _GuardTestCase(
          role: UserRole.warehouse,
          route: '/admin/products',
          expectedRedirect: '/admin',
        ),
      ];

      for (final tc in testCases) {
        final mockUser = UserEntity(
          id: 'test_user',
          email: 'user@test.com',
          displayName: 'Test User',
          role: tc.role,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final notifier = MockAuthNotifier(AuthState(
          status: AuthStatus.authenticated,
          user: mockUser,
        ));

        final container = ProviderContainer(
          overrides: [
            authNotifierProvider.overrideWith((ref) => notifier),
          ],
        );
        addTearDown(container.dispose);

        final adminGuard = container.read(adminGuardProvider);
        final mockContext = _MockBuildContext();
        final mockState = MockGoRouterState(tc.route);

        final redirect = adminGuard(mockContext, mockState);
        expect(
          redirect,
          tc.expectedRedirect,
          reason: 'Failed test case: role=${tc.role.value}, route=${tc.route}',
        );
      }
    });
  });

  group('Audit Logs Unit Tests', () {
    test('Verify audit log mock storage creation and watchStream', () async {
      final prefs = await SharedPreferences.getInstance();
      final auditLogRepo = MockAuditLogRepository(prefs);

      // Verify initial logs has 1 seeded log
      final initialLogs = await auditLogRepo.getAuditLogs();
      expect(initialLogs, isA<Success<List<AuditLogEntity>>>());
      if (initialLogs is Success<List<AuditLogEntity>>) {
        expect(initialLogs.data.length, 1);
        expect(initialLogs.data.first.action, 'System Setup');
      }

      // Create audit log
      final log = AuditLogEntity(
        id: '',
        userId: 'admin_123',
        userEmail: 'admin@test.com',
        action: 'Price Changed',
        details: 'Price of Apples changed to 12.0 EGP',
        timestamp: DateTime.now(),
      );

      final createResult = await auditLogRepo.createAuditLog(log);
      expect(createResult, isA<Success<AuditLogEntity>>());
      if (createResult is Success<AuditLogEntity>) {
        expect(createResult.data.id.isNotEmpty, true);
      }

      // Verify populated list contains both logs, sorted descending by timestamp
      final logsAfter = await auditLogRepo.getAuditLogs();
      expect(logsAfter, isA<Success<List<AuditLogEntity>>>());
      if (logsAfter is Success<List<AuditLogEntity>>) {
        expect(logsAfter.data.length, 2);
        expect(logsAfter.data.first.action, 'Price Changed');
        expect(logsAfter.data.first.userId, 'admin_123');
      }
    });
  });
}

class _GuardTestCase {
  final UserRole role;
  final String route;
  final String? expectedRedirect;

  _GuardTestCase({
    required this.role,
    required this.route,
    required this.expectedRedirect,
  });
}

class _MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGoRouterState implements GoRouterState {
  @override
  final String matchedLocation;

  MockGoRouterState(this.matchedLocation);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
