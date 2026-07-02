import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/user_role.dart';
import '../features/auth/providers/auth_providers.dart';
import 'route_names.dart';
import 'auth_guard.dart';
import 'admin_guard.dart';
import '../../core/constants/route_constants.dart';
import '../features/auth/pages/sign_in_page.dart';
import '../features/auth/pages/sign_up_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/categories/admin/pages/admin_categories_page.dart';
import '../features/categories/admin/pages/admin_category_form_page.dart';
import '../features/categories/customer/pages/category_products_page.dart';
import '../features/categories/customer/pages/categories_list_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/products/admin/pages/admin_products_page.dart';
import '../features/products/admin/pages/admin_product_form_page.dart';
import '../features/products/customer/pages/product_detail_page.dart';
import '../features/offers/admin/pages/admin_offer_form_page.dart';
import '../features/offers/admin/pages/admin_offers_page.dart';
import '../features/offers/customer/pages/offer_detail_page.dart';
import '../features/offers/customer/pages/offer_list_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/splash/pages/splash_page.dart';
import '../features/admin/pages/dashboard_page.dart';
import '../features/search/pages/search_page.dart';
import '../features/admin/pages/admin_settings_page.dart';
import '../features/weight_units/admin/pages/admin_weight_units_page.dart';
import '../features/weight_units/admin/pages/admin_weight_unit_form_page.dart';
import '../features/notifications/pages/notifications_page.dart';
import '../features/admin/pages/lookups_page.dart';
import '../features/admin/pages/lookup_list_page.dart';
import '../features/admin/pages/lookup_form_page.dart';
import '../features/cart/pages/cart_page.dart';
import '../features/admin/pages/admin_orders_page.dart';
import '../features/admin/pages/admin_order_details_page.dart';
import '../features/addresses/pages/address_list_page.dart';
import '../features/addresses/pages/address_form_page.dart';
import '../features/admin/pages/admin_customers_page.dart';
import '../features/admin/pages/admin_coupons_page.dart';
import '../features/admin/pages/admin_coupon_form_page.dart';
import '../features/admin/pages/admin_audit_logs_page.dart';
import '../features/admin/pages/admin_analytics_page.dart';
import '../features/admin/pages/admin_suppliers_page.dart';
import '../features/admin/pages/admin_supplier_details_page.dart';
import '../features/admin/pages/admin_supplier_form_page.dart';
import '../features/admin/pages/admin_purchase_orders_page.dart';
import '../features/admin/pages/admin_purchase_order_form_page.dart';
import '../features/orders/pages/my_orders_page.dart';
import '../features/orders/pages/order_details_page.dart';
import '../features/admin/pages/admin_inventory_page.dart';
import '../features/admin/pages/admin_reports_page.dart';
import '../features/admin/pages/admin_warehouse_page.dart';
import '../features/admin/pages/admin_delivery_page.dart';
import '../features/admin/pages/admin_treasury_page.dart';
import '../features/admin/pages/admin_employees_page.dart';
import '../features/admin/pages/admin_notifications_page.dart';
import '../features/admin/pages/admin_ai_assistant_page.dart';
import '../features/admin/pages/admin_batches_page.dart';
import '../features/admin/pages/admin_expenses_page.dart';

class _AdminNavDestination {
  final IconData icon;
  final String label;
  final String route;
  final bool Function(UserRole role) hasPermission;

  const _AdminNavDestination({
    required this.icon,
    required this.label,
    required this.route,
    required this.hasPermission,
  });
}

final List<_AdminNavDestination> _allAdminDestinations = [
  _AdminNavDestination(
    icon: Icons.dashboard_outlined,
    label: 'Dashboard',
    route: '/admin',
    hasPermission: (_) => true,
  ),
  _AdminNavDestination(
    icon: Icons.inventory_2_outlined,
    label: 'Products',
    route: '/admin/products',
    hasPermission: (r) => r.canManageProducts,
  ),
  _AdminNavDestination(
    icon: Icons.category_outlined,
    label: 'Categories',
    route: '/admin/categories',
    hasPermission: (r) => r.canManageProducts,
  ),
  _AdminNavDestination(
    icon: Icons.local_offer_outlined,
    label: 'Offers',
    route: '/admin/offers',
    hasPermission: (r) => r.canManageProducts,
  ),
  _AdminNavDestination(
    icon: Icons.shopping_bag_outlined,
    label: 'Orders',
    route: '/admin/orders',
    hasPermission: (r) => r.canManageOrders,
  ),
  _AdminNavDestination(
    icon: Icons.people_outline,
    label: 'Customers',
    route: '/admin/customers',
    hasPermission: (r) => r.canManageSettings,
  ),
  _AdminNavDestination(
    icon: Icons.warehouse_outlined,
    label: 'Inventory',
    route: '/admin/inventory',
    hasPermission: (r) => r.canManageInventory,
  ),
  _AdminNavDestination(
    icon: Icons.business_outlined,
    label: 'Suppliers',
    route: '/admin/suppliers',
    hasPermission: (r) => r.canManageInventory,
  ),
  _AdminNavDestination(
    icon: Icons.receipt_long_outlined,
    label: 'Purchase Orders',
    route: '/admin/purchase-orders',
    hasPermission: (r) => r.canManageInventory,
  ),
  _AdminNavDestination(
    icon: Icons.store_outlined,
    label: 'Warehouse',
    route: '/admin/warehouse',
    hasPermission: (r) => r.canManageInventory,
  ),
  _AdminNavDestination(
    icon: Icons.calendar_today_outlined,
    label: 'Batches & Expiry',
    route: '/admin/batches',
    hasPermission: (r) => r.canManageInventory,
  ),
  _AdminNavDestination(
    icon: Icons.money_off_outlined,
    label: 'Expenses',
    route: '/admin/expenses',
    hasPermission: (r) => r.isAdmin,
  ),
  _AdminNavDestination(
    icon: Icons.local_shipping_outlined,
    label: 'Delivery',
    route: '/admin/delivery',
    hasPermission: (r) => r.canManageOrders,
  ),
  _AdminNavDestination(
    icon: Icons.confirmation_number_outlined,
    label: 'Coupons',
    route: '/admin/coupons',
    hasPermission: (r) => r.canManageProducts,
  ),
  _AdminNavDestination(
    icon: Icons.summarize_outlined,
    label: 'Reports',
    route: RouteConstants.adminReports,
    hasPermission: (r) => r.canManageReports,
  ),
  _AdminNavDestination(
    icon: Icons.analytics_outlined,
    label: 'Analytics',
    route: '/admin/analytics',
    hasPermission: (r) => r.canManageReports,
  ),
  _AdminNavDestination(
    icon: Icons.account_balance_outlined,
    label: 'Treasury',
    route: '/admin/treasury',
    hasPermission: (r) => r.isAdmin,
  ),
  _AdminNavDestination(
    icon: Icons.badge_outlined,
    label: 'Employees',
    route: '/admin/employees',
    hasPermission: (r) => r.isAdmin,
  ),
  _AdminNavDestination(
    icon: Icons.history_outlined,
    label: 'Audit Logs',
    route: '/admin/audit-logs',
    hasPermission: (r) => r.canManageSettings,
  ),
  _AdminNavDestination(
    icon: Icons.notifications_active_outlined,
    label: 'Notifications',
    route: '/admin/notifications',
    hasPermission: (r) => r.isStaff,
  ),
  _AdminNavDestination(
    icon: Icons.settings_outlined,
    label: 'Settings',
    route: '/admin/settings',
    hasPermission: (r) => r.canManageSettings,
  ),
  _AdminNavDestination(
    icon: Icons.auto_awesome_outlined,
    label: 'AI Assistant',
    route: '/admin/ai-assistant',
    hasPermission: (r) => r.isStaff,
  ),
];

final goRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = AuthGuard(ref);
  final adminGuard = AdminGuard(ref);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      debugPrint('[ROUTER] navigation: location=${state.matchedLocation}');
      final authRedirect = authGuard(context, state);
      if (authRedirect != null) {
        debugPrint('[ROUTER] navigation: authGuard redirect -> $authRedirect');
        return authRedirect;
      }
      final adminRedirect = adminGuard(context, state);
      if (adminRedirect != null) {
        debugPrint('[ROUTER] navigation: adminGuard redirect -> $adminRedirect');
      }
      return adminRedirect;
    },
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteConstants.signIn,
        name: RouteNames.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: RouteConstants.signUp,
        name: RouteNames.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: RouteConstants.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _calculateIndex(state),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'Categories'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: 'Notifications'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
            onTap: (index) => _onNavTap(index, context),
          ),
        ),
        routes: [
          GoRoute(
            path: RouteConstants.home,
            name: RouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RouteConstants.categoryList,
            name: RouteNames.categoriesList,
            builder: (context, state) => const CategoriesListPage(),
          ),
          GoRoute(
            path: '/categories/:id',
            name: RouteNames.categoryProducts,
            builder: (context, state) => CategoryProductsPage(
              categoryId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/products/:id',
            name: RouteNames.productDetail,
            builder: (context, state) => ProductDetailPage(
              productId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteConstants.offerList,
            name: RouteNames.offerList,
            builder: (context, state) => const OfferListPage(),
          ),
          GoRoute(
            path: '/offers/:id',
            name: RouteNames.offerDetail,
            builder: (context, state) => OfferDetailPage(
              offerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteConstants.search,
            name: RouteNames.search,
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: RouteConstants.notifications,
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteConstants.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: RouteConstants.settings,
            name: RouteNames.settings,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Settings Page - TODO')),
            ),
          ),
          GoRoute(
            path: RouteConstants.cart,
            name: RouteNames.cart,
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: RouteConstants.myOrders,
            name: RouteNames.myOrders,
            builder: (context, state) => const MyOrdersPage(),
          ),
          GoRoute(
            path: RouteConstants.orderDetail,
            name: RouteNames.orderDetail,
            builder: (context, state) => CustomerOrderDetailPage(
              orderId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/addresses',
            name: 'addresses',
            builder: (context, state) => const AddressListPage(),
          ),
          GoRoute(
            path: '/addresses/new',
            name: 'addressNew',
            builder: (context, state) => const AddressFormPage(),
          ),
          GoRoute(
            path: '/addresses/edit/:id',
            name: 'addressEdit',
            builder: (context, state) => AddressFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
        ],
      ),

      ShellRoute(
        builder: (context, state, child) => Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(currentUserProvider);
            final userRole = user?.role ?? UserRole.customer;
            final visibleDestinations = _allAdminDestinations
                .where((d) => d.hasPermission(userRole))
                .toList();

            final location = state.matchedLocation;
            var selectedIndex = visibleDestinations.indexWhere((d) {
              if (d.route == '/admin') {
                return location == '/admin';
              }
              return location.startsWith(d.route);
            });
            if (selectedIndex == -1) selectedIndex = 0;

            return Scaffold(
              body: Row(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              selectedIndex: selectedIndex,
                              labelType: NavigationRailLabelType.all,
                              destinations: visibleDestinations
                                  .map((d) => NavigationRailDestination(
                                        icon: Icon(d.icon),
                                        label: Text(d.label),
                                      ))
                                  .toList(),
                              onDestinationSelected: (index) {
                                context.go(visibleDestinations[index].route);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: child),
                ],
              ),
            );
          },
        ),
        routes: [
          GoRoute(
            path: '/admin',
            name: RouteNames.admin,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteConstants.adminOrders,
            name: RouteNames.adminOrders,
            builder: (context, state) => const AdminOrdersPage(),
          ),
          GoRoute(
            path: RouteConstants.adminOrderDetail,
            name: RouteNames.adminOrderDetail,
            builder: (context, state) => AdminOrderDetailPage(
              orderId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/admin/products',
            name: RouteNames.adminProducts,
            builder: (context, state) => const AdminProductsPage(),
          ),
          GoRoute(
            path: '/admin/products/new',
            name: RouteNames.adminProductNew,
            builder: (context, state) => const AdminProductFormPage(),
          ),
          GoRoute(
            path: '/admin/products/:id',
            name: RouteNames.adminProductEdit,
            builder: (context, state) => AdminProductFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/inventory',
            builder: (context, state) => const AdminInventoryPage(),
          ),
          GoRoute(
            path: '/admin/categories',
            name: RouteNames.adminCategories,
            builder: (context, state) => const AdminCategoriesPage(),
          ),
          GoRoute(
            path: '/admin/categories/new',
            name: RouteNames.adminCategoryNew,
            builder: (context, state) => const AdminCategoryFormPage(),
          ),
          GoRoute(
            path: '/admin/categories/:id',
            name: RouteNames.adminCategoryEdit,
            builder: (context, state) => AdminCategoryFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/offers',
            name: RouteNames.adminOffers,
            builder: (context, state) => const AdminOffersPage(),
          ),
          GoRoute(
            path: '/admin/offers/new',
            name: RouteNames.adminOfferNew,
            builder: (context, state) => const AdminOfferFormPage(),
          ),
          GoRoute(
            path: '/admin/offers/:id',
            name: RouteNames.adminOfferEdit,
            builder: (context, state) => AdminOfferFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/banners',
            name: RouteNames.adminBanners,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Admin Banners - TODO')),
            ),
          ),
          GoRoute(
            path: '/admin/users',
            name: RouteNames.adminUsers,
            builder: (context, state) => const AdminCustomersPage(),
          ),
          GoRoute(
            path: '/admin/customers',
            builder: (context, state) => const AdminCustomersPage(),
          ),
          GoRoute(
            path: RouteConstants.adminReports,
            name: RouteNames.adminReports,
            builder: (context, state) => const AdminReportsPage(),
          ),
          GoRoute(
            path: '/admin/suppliers',
            builder: (context, state) => const AdminSuppliersPage(),
          ),
          GoRoute(
            path: '/admin/suppliers/new',
            builder: (context, state) => const AdminSupplierFormPage(),
          ),
          GoRoute(
            path: '/admin/suppliers/edit/:id',
            builder: (context, state) => AdminSupplierFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/suppliers/details/:id',
            builder: (context, state) => AdminSupplierDetailsPage(
              supplierId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/admin/purchase-orders',
            builder: (context, state) => const AdminPurchaseOrdersPage(),
          ),
          GoRoute(
            path: '/admin/purchase-orders/new',
            builder: (context, state) => const AdminPurchaseOrderFormPage(),
          ),
          GoRoute(
            path: '/admin/purchase-orders/edit/:id',
            builder: (context, state) => AdminPurchaseOrderFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/coupons',
            builder: (context, state) => const AdminCouponsPage(),
          ),
          GoRoute(
            path: '/admin/coupons/new',
            builder: (context, state) => const AdminCouponFormPage(),
          ),
          GoRoute(
            path: '/admin/coupons/edit/:id',
            builder: (context, state) => AdminCouponFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/audit-logs',
            builder: (context, state) => const AdminAuditLogsPage(),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (context, state) => const AdminAnalyticsPage(),
          ),
          GoRoute(
            path: '/admin/warehouse',
            builder: (context, state) => const AdminWarehousePage(),
          ),
          GoRoute(
            path: '/admin/batches',
            builder: (context, state) => const AdminBatchesPage(),
          ),
          GoRoute(
            path: '/admin/expenses',
            builder: (context, state) => const AdminExpensesPage(),
          ),
          GoRoute(
            path: '/admin/delivery',
            builder: (context, state) => const AdminDeliveryPage(),
          ),
          GoRoute(
            path: '/admin/treasury',
            builder: (context, state) => const AdminTreasuryPage(),
          ),
          GoRoute(
            path: '/admin/employees',
            builder: (context, state) => const AdminEmployeesPage(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const AdminNotificationsPage(),
          ),
          GoRoute(
            path: '/admin/ai-assistant',
            builder: (context, state) => const AdminAIAssistantPage(),
          ),
          GoRoute(
            path: '/admin/settings',
            name: RouteNames.adminSettings,
            builder: (context, state) => const AdminSettingsPage(),
          ),
          GoRoute(
            path: '/admin/weight-units',
            name: RouteNames.adminWeightUnits,
            builder: (context, state) => const AdminWeightUnitsPage(),
          ),
          GoRoute(
            path: '/admin/weight-units/new',
            name: RouteNames.adminWeightUnitNew,
            builder: (context, state) => const AdminWeightUnitFormPage(),
          ),
          GoRoute(
            path: '/admin/weight-units/:id',
            name: RouteNames.adminWeightUnitEdit,
            builder: (context, state) => AdminWeightUnitFormPage(
              editId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/lookups',
            builder: (context, state) => const LookupsPage(),
          ),
          GoRoute(
            path: '/admin/lookups/list',
            builder: (context, state) => LookupListPage(
              lookupType: state.uri.queryParameters['type'] ?? '',
              title: state.uri.queryParameters['title'] ?? 'List',
            ),
          ),
          GoRoute(
            path: '/admin/lookups/new',
            builder: (context, state) => LookupFormPage(
              lookupType: state.uri.queryParameters['type'] ?? '',
            ),
          ),
          GoRoute(
            path: '/admin/lookups/edit/:id',
            builder: (context, state) => LookupFormPage(
              lookupType: state.uri.queryParameters['type'] ?? '',
              editId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
        ],
      ),
    ],
  );
});

int _calculateIndex(GoRouterState state) {
  final location = state.matchedLocation;
  if (location.startsWith('/categories')) return 1;
  if (location.startsWith('/search')) return 2;
  if (location.startsWith('/notifications')) return 3;
  if (location.startsWith('/profile') || location.startsWith('/settings')) return 4;
  return 0;
}

void _onNavTap(int index, BuildContext context) {
  switch (index) {
    case 0: context.go(RouteConstants.home);
    case 1: context.go('/categories/list');
    case 2: context.go(RouteConstants.search);
    case 3: context.go(RouteConstants.notifications);
    case 4: context.go(RouteConstants.profile);
  }
}
