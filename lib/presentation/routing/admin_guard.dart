import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

class AdminGuard {
  final Ref _ref;

  AdminGuard(this._ref);

  String? call(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    if (!location.startsWith('/admin')) return null;

    final authState = _ref.read(authNotifierProvider);
    final user = authState.user;
    final isStaff = user?.role.isStaff ?? false;
    debugPrint('[AUTH] AdminGuard: location=$location, isStaff=$isStaff');

    if (!isStaff) {
      debugPrint('[AUTH] AdminGuard: redirect non-staff to home');
      return '/home';
    }

    final role = user!.role;

    if (location.startsWith('/admin/products') ||
        location.startsWith('/admin/categories') ||
        location.startsWith('/admin/offers') ||
        location.startsWith('/admin/banners')) {
      if (!role.canManageProducts) {
        debugPrint('[AUTH] AdminGuard: Redirect unauthorized products to admin dashboard');
        return '/admin';
      }
    }

    if (location.startsWith('/admin/orders')) {
      if (!role.canManageOrders) {
        debugPrint('[AUTH] AdminGuard: Redirect unauthorized orders to admin dashboard');
        return '/admin';
      }
    }

    if (location.startsWith('/admin/inventory') ||
        location.startsWith('/admin/suppliers') ||
        location.startsWith('/admin/purchase-orders')) {
      if (!role.canManageInventory) {
        debugPrint('[AUTH] AdminGuard: Redirect unauthorized inventory to admin dashboard');
        return '/admin';
      }
    }

    if (location.startsWith('/admin/reports')) {
      if (!role.canManageReports) {
        debugPrint('[AUTH] AdminGuard: Redirect unauthorized reports to admin dashboard');
        return '/admin';
      }
    }

    if (location.startsWith('/admin/settings') ||
        location.startsWith('/admin/users') ||
        location.startsWith('/admin/audit-logs') ||
        location.startsWith('/admin/weight-units')) {
      if (!role.canManageSettings) {
        debugPrint('[AUTH] AdminGuard: Redirect unauthorized settings to admin dashboard');
        return '/admin';
      }
    }

    debugPrint('[AUTH] AdminGuard: ALLOW access');
    return null;
  }
}
