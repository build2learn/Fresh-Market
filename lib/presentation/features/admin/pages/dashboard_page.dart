import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/domain/usecases/category/get_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/presentation/features/inventory/providers/batch_providers.dart';

final _dashboardStatsProvider = FutureProvider.autoDispose<_DashboardStats>((ref) async {
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final productRepo = ref.watch(productRepositoryProvider);
  final offerRepo = ref.watch(offerRepositoryProvider);
  final orderRepo = ref.watch(orderRepositoryProvider);

  final getCategories = GetCategoriesUseCase(repository: categoryRepo);
  final getProducts = GetProductsUseCase(repository: productRepo);
  final getOffers = GetOffersUseCase(repository: offerRepo);

  final categoriesResult = await getCategories();
  final productsResult = await getProducts();
  final offersResult = await getOffers();
  final ordersResult = await orderRepo.getOrders();

  final products = productsResult is Success<List<ProductEntity>> ? productsResult.data : <ProductEntity>[];
  final lowStockCount = products.where((p) => p.availableStock <= p.reorderLevel && p.availableStock > 0).length;
  final outOfStockCount = products.where((p) => p.availableStock <= 0).length;

  return _DashboardStats(
    totalCategories: categoriesResult is Success<List<CategoryEntity>> ? categoriesResult.data.length : 0,
    totalProducts: products.length,
    totalOffers: offersResult is Success<List<OfferEntity>> ? offersResult.data.length : 0,
    totalOrders: ordersResult is Success<List<OrderEntity>> ? ordersResult.data.length : 0,
    lowStockCount: lowStockCount,
    outOfStockCount: outOfStockCount,
  );
});

class _DashboardStats {
  final int totalCategories;
  final int totalProducts;
  final int totalOffers;
  final int totalOrders;
  final int lowStockCount;
  final int outOfStockCount;

  const _DashboardStats({
    required this.totalCategories,
    required this.totalProducts,
    required this.totalOffers,
    required this.totalOrders,
    required this.lowStockCount,
    required this.outOfStockCount,
  });
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_dashboardStatsProvider);
    final expiryStats = ref.watch(expiryAlertStatsProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'لوحة التحكم للمسؤول' : 'Admin Control Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_dashboardStatsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_dashboardStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Section
            _buildWelcomeHeader(context),
            const SizedBox(height: 24),

            // Expiry Alert Banner
            _buildExpiryAlertBanner(context, expiryStats),
            if (expiryStats != null && (expiryStats.expiredCount > 0 || expiryStats.expiringIn7DaysCount > 0 || expiryStats.expiringIn30DaysCount > 0))
              const SizedBox(height: 24),

            // Statistics Summary
            Text(
              isAr ? 'لمحة سريعة عن العمليات' : 'Operations at a Glance',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (stats) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: context.l10n.totalProducts,
                    value: '${stats.totalProducts}',
                    color: context.colorScheme.primary,
                    onTap: () => context.push(RouteConstants.adminProducts),
                  ),
                  _StatCard(
                    icon: Icons.category_outlined,
                    label: context.l10n.totalCategories,
                    value: '${stats.totalCategories}',
                    color: context.colorScheme.secondary,
                    onTap: () => context.push(RouteConstants.adminCategories),
                  ),
                  _StatCard(
                    icon: Icons.local_offer_outlined,
                    label: context.l10n.totalOffers,
                    value: '${stats.totalOffers}',
                    color: context.colorScheme.tertiary,
                    onTap: () => context.push(RouteConstants.adminOffers),
                  ),
                  _StatCard(
                    icon: Icons.shopping_bag_outlined,
                    label: isAr ? 'إجمالي الطلبات' : 'Total Orders',
                    value: '${stats.totalOrders}',
                    color: Colors.purple.shade700,
                    onTap: () => context.push(RouteConstants.adminOrders),
                  ),
                  _StatCard(
                    icon: Icons.warning_amber_outlined,
                    label: isAr ? 'منخفض المخزون' : 'Low Stock Count',
                    value: '${stats.lowStockCount}',
                    color: Colors.orange.shade700,
                    onTap: () => context.push('/admin/inventory'),
                  ),
                  _StatCard(
                    icon: Icons.error_outline,
                    label: isAr ? 'نفد من المخزون' : 'Out of Stock Count',
                    value: '${stats.outOfStockCount}',
                    color: Colors.red.shade700,
                    onTap: () => context.push('/admin/inventory'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // AI Copilot Fast Access (Floating Banner)
            _buildAICopilotBanner(context),
            const SizedBox(height: 32),

            // Grouped Navigation Tree Nodes
            _buildGroupHeader(context, isAr ? 'إدارة المخزون والتخزين' : 'Logistics & Stock Control'),
            _buildNavGrid(context, [
              _NavNode(isAr ? 'المنتجات' : 'Products', Icons.inventory_2_outlined, Colors.blue, () => context.push(RouteConstants.adminProducts)),
              _NavNode(isAr ? 'الفئات' : 'Categories', Icons.category_outlined, Colors.teal, () => context.push(RouteConstants.adminCategories)),
              _NavNode(isAr ? 'العروض الترويجية' : 'Offers', Icons.local_offer_outlined, Colors.amber, () => context.push(RouteConstants.adminOffers)),
              _NavNode(isAr ? 'مستويات المخزون' : 'Inventory Levels', Icons.warehouse_outlined, Colors.indigo, () => context.push('/admin/inventory')),
              _NavNode(isAr ? 'إدارة المستودعات' : 'Warehouse Management', Icons.store_outlined, Colors.purple, () => context.push('/admin/warehouse')),
              _NavNode(isAr ? 'إدارة الموردين' : 'Suppliers', Icons.business_outlined, Colors.orange, () => context.push('/admin/suppliers')),
              _NavNode(isAr ? 'أوامر الشراء للموردين' : 'Purchase Orders', Icons.receipt_long_outlined, Colors.pink, () => context.push('/admin/purchase-orders')),
              _NavNode(isAr ? 'تتبع الدفعات والصلاحية' : 'Batches & Expiry', Icons.calendar_today_outlined, Colors.deepPurple, () => context.push('/admin/batches')),
            ]),
            const SizedBox(height: 28),

            _buildGroupHeader(context, isAr ? 'المبيعات وتوزيع الشحنات' : 'Sales & Fleet Dispatch'),
            _buildNavGrid(context, [
              _NavNode(isAr ? 'طلبات العملاء' : 'Customer Orders', Icons.shopping_bag_outlined, Colors.indigo, () => context.push(RouteConstants.adminOrders)),
              _NavNode(isAr ? 'دليل العملاء' : 'Customers', Icons.people_outline, Colors.teal, () => context.push('/admin/customers')),
              _NavNode(isAr ? 'أسطول التوصيل' : 'Delivery Dispatch', Icons.local_shipping_outlined, Colors.deepOrange, () => context.push('/admin/delivery')),
              _NavNode(isAr ? 'قسائم الخصم' : 'Coupons', Icons.confirmation_number_outlined, Colors.red, () => context.push('/admin/coupons')),
            ]),
            const SizedBox(height: 28),

            _buildGroupHeader(context, isAr ? 'التقارير والمقاييس المالية' : 'Analytics & Financials'),
            _buildNavGrid(context, [
              _NavNode(isAr ? 'الملخصات والتقارير' : 'Reports', Icons.summarize_outlined, Colors.blue, () => context.push(RouteConstants.adminReports)),
              _NavNode(isAr ? 'لوحة التحليلات' : 'Analytics & Sales', Icons.analytics_outlined, Colors.purple, () => context.push('/admin/analytics')),
              _NavNode(isAr ? 'خزينة النقد والمالية' : 'Treasury & Cash', Icons.account_balance_outlined, Colors.teal, () => context.push('/admin/treasury')),
              _NavNode(isAr ? 'إدارة المصروفات' : 'Expenses', Icons.money_off_outlined, Colors.red, () => context.push('/admin/expenses')),
            ]),
            const SizedBox(height: 28),

            _buildGroupHeader(context, isAr ? 'النظام وأدوات التحكم' : 'Control & Administration'),
            _buildNavGrid(context, [
              _NavNode(isAr ? 'الموظفين والصلاحيات' : 'Employees', Icons.badge_outlined, Colors.amber, () => context.push('/admin/employees')),
              _NavNode(isAr ? 'سجل العمليات' : 'Audit Logs', Icons.history_outlined, Colors.blueGrey, () => context.push('/admin/audit-logs')),
              _NavNode(isAr ? 'التنبيهات الجماعية' : 'Notifications', Icons.notifications_active_outlined, Colors.red, () => context.push('/admin/notifications')),
              _NavNode(isAr ? 'إعدادات المنصة' : 'Settings', Icons.settings_outlined, Colors.grey, () => context.push('/admin/settings')),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final isAr = context.isRtl;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.primary.withOpacity(0.9),
            context.colorScheme.tertiary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'مرحباً، المسؤول النظام' : 'Welcome back, Admin',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr ? 'لديك صلاحيات كاملة لإدارة المتجر' : 'You have full access to manage the storefront',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAICopilotBanner(BuildContext context) {
    final isAr = context.isRtl;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/admin/ai-assistant'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade900.withOpacity(0.85),
                Colors.teal.shade900.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'اسأل المساعد الذكي' : 'Consult AI Copilot',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr 
                          ? 'تحليل مستويات المخزون، تسويات السائقين، أو كتابة تقرير المبيعات تلقائياً' 
                          : 'Audit driver shift sheets, analyze margins, or run stock projections in seconds.',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNavGrid(BuildContext context, List<_NavNode> nodes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: context.isMobile ? 1.45 : 1.7,
      ),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: node.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: node.color.withOpacity(0.1),
                    child: Icon(node.icon, color: node.color, size: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    node.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpiryAlertBanner(BuildContext context, ExpiryAlertStats? stats) {
    if (stats == null) return const SizedBox.shrink();
    final isAr = context.isRtl;
    final hasExpired = stats.expiredCount > 0;
    final hasNearExpiry = stats.expiringIn7DaysCount > 0 || stats.expiringIn30DaysCount > 0;

    if (!hasExpired && !hasNearExpiry) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/admin/batches'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasExpired
                  ? [Colors.red.shade900.withOpacity(0.85), Colors.red.shade700.withOpacity(0.85)]
                  : [Colors.orange.shade900.withOpacity(0.85), Colors.orange.shade700.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasExpired ? Icons.dangerous : Icons.warning_amber_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'تنبيهات صلاحية المخزون!' : 'Inventory Expiry Alerts!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (stats.expiredCount > 0)
                    _ExpiryChip(
                      label: isAr
                          ? 'منتهي الصلاحية: ${stats.expiredCount}'
                          : 'Expired: ${stats.expiredCount}',
                      color: Colors.red.shade100,
                      textColor: Colors.red.shade900,
                    ),
                  if (stats.expiringIn7DaysCount > 0)
                    _ExpiryChip(
                      label: isAr
                          ? 'تنتهي خلال 7 أيام: ${stats.expiringIn7DaysCount}'
                          : 'Expiring in 7 days: ${stats.expiringIn7DaysCount}',
                      color: Colors.orange.shade100,
                      textColor: Colors.orange.shade900,
                    ),
                  if (stats.expiringIn30DaysCount > 0)
                    _ExpiryChip(
                      label: isAr
                          ? 'تنتهي خلال 30 يوم: ${stats.expiringIn30DaysCount}'
                          : 'Expiring in 30 days: ${stats.expiringIn30DaysCount}',
                      color: Colors.amber.shade100,
                      textColor: Colors.amber.shade900,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _ExpiryChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavNode {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _NavNode(this.label, this.icon, this.color, this.onTap);
}
