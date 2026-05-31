import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../features/products/admin/pages/admin_products_page.dart';
import '../features/products/admin/pages/admin_product_form_page.dart';
import '../features/products/customer/pages/product_detail_page.dart';
import '../features/offers/admin/pages/admin_offer_form_page.dart';
import '../features/offers/admin/pages/admin_offers_page.dart';
import '../features/offers/customer/pages/offer_detail_page.dart';
import '../features/offers/customer/pages/offer_list_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/splash/pages/splash_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authGuard = AuthGuard(ref);
  final adminGuard = AdminGuard(ref);

  return GoRouter(
    initialLocation: RouteConstants.splash,
    redirect: (context, state) {
      final authRedirect = authGuard(context, state);
      if (authRedirect != null) return authRedirect;

      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      if (isAdminRoute) {
        return adminGuard(context, state);
      }

      return null;
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
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Page - TODO')),
            ),
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
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Search Page - TODO')),
            ),
          ),
          GoRoute(
            path: RouteConstants.notifications,
            name: RouteNames.notifications,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Notifications Page - TODO')),
            ),
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
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _calculateAdminIndex(state),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    label: Text('Products'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.category_outlined),
                    label: Text('Categories'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_offer_outlined),
                    label: Text('Offers'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.image_outlined),
                    label: Text('Banners'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    label: Text('Users'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    label: Text('Settings'),
                  ),
                ],
                onDestinationSelected: (index) => _onAdminNavTap(index, context),
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        ),
        routes: [
          GoRoute(
            path: '/admin',
            name: RouteNames.admin,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Admin Dashboard - TODO')),
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
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Admin Users - TODO')),
            ),
          ),
          GoRoute(
            path: '/admin/settings',
            name: RouteNames.adminSettings,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Admin Settings - TODO')),
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

int _calculateAdminIndex(GoRouterState state) {
  final location = state.matchedLocation;
  if (location.startsWith('/admin/products')) return 1;
  if (location.startsWith('/admin/categories')) return 2;
  if (location.startsWith('/admin/offers')) return 3;
  if (location.startsWith('/admin/banners')) return 4;
  if (location.startsWith('/admin/users')) return 5;
  if (location.startsWith('/admin/settings')) return 6;
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

void _onAdminNavTap(int index, BuildContext context) {
  switch (index) {
    case 0: context.go('/admin');
    case 1: context.go('/admin/products');
    case 2: context.go('/admin/categories');
    case 3: context.go('/admin/offers');
    case 4: context.go('/admin/banners');
    case 5: context.go('/admin/users');
    case 6: context.go('/admin/settings');
  }
}
