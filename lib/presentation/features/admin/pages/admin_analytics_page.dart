import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/core/providers/locale_provider.dart';
import 'package:fresh_market/domain/entities/expense.entity.dart';
import 'package:fresh_market/data/providers/expense_repository_provider.dart';

// Analytics date range filters
final analyticsFilterProvider = StateProvider.autoDispose<String>((ref) => 'This Month');

class ChartBarData {
  final String label;
  final double value;

  const ChartBarData(this.label, this.value);
}

class AnalyticsStats {
  final int ordersToday;
  final int ordersThisMonth;
  final double revenueToday;
  final double revenueThisMonth;
  final double expensesThisMonth;
  final double netProfitThisMonth;
  final int productsCount;
  final int customersCount;
  final List<ChartBarData> dailyRevenueData;
  final List<ChartBarData> monthlyRevenueData;
  final List<MapEntry<String, int>> topProducts;
  final List<MapEntry<String, int>> topCategories;

  const AnalyticsStats({
    required this.ordersToday,
    required this.ordersThisMonth,
    required this.revenueToday,
    required this.revenueThisMonth,
    required this.expensesThisMonth,
    required this.netProfitThisMonth,
    required this.productsCount,
    required this.customersCount,
    required this.dailyRevenueData,
    required this.monthlyRevenueData,
    required this.topProducts,
    required this.topCategories,
  });
}

// Real-time analytics stream aggregation provider
final adminAnalyticsProvider = StreamProvider.autoDispose<AnalyticsStats>((ref) {
  final locale = ref.watch(localeProvider);
  final orderRepo = ref.watch(orderRepositoryProvider);
  final productRepo = ref.watch(productRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final activeFilter = ref.watch(analyticsFilterProvider);

  final ordersStream = orderRepo.watchOrders();

  return ordersStream.asyncMap((orders) async {
    final productsRes = await productRepo.getProducts(limit: 1000);
    final categoriesRes = await categoryRepo.getCategories();
    final usersRes = await userRepo.getUsers(limit: 1000);
    final expensesRes = await expenseRepo.getExpenses();

    final products = productsRes is Success<List<ProductEntity>> ? productsRes.data : <ProductEntity>[];
    final categories = categoriesRes is Success<List<CategoryEntity>> ? categoriesRes.data : <CategoryEntity>[];
    final users = usersRes is Success<List<UserEntity>> ? usersRes.data : <UserEntity>[];

    final customers = users.where((u) => u.isCustomer).toList();
    final customersCount = customers.length;
    final productsCount = products.length;

    // Dates calculations
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
    final endOfMonth = nextMonth.subtract(const Duration(microseconds: 1));

    DateTime startOfFilter;
    DateTime endOfFilter = endOfToday;

    switch (activeFilter) {
      case 'Today':
        startOfFilter = startOfToday;
        break;
      case '7 Days':
        startOfFilter = startOfToday.subtract(const Duration(days: 6));
        break;
      case '30 Days':
        startOfFilter = startOfToday.subtract(const Duration(days: 29));
        break;
      case 'This Month':
      default:
        startOfFilter = startOfMonth;
        endOfFilter = endOfMonth;
        break;
    }

    int ordersTodayCount = 0;
    int ordersThisMonthCount = 0;
    double revenueTodaySum = 0.0;
    double revenueThisMonthSum = 0.0;

    for (final order in orders) {
      final date = order.createdAt;
      final isToday = (date.isAfter(startOfToday) || date.isAtSameMomentAs(startOfToday)) &&
                      (date.isBefore(endOfToday) || date.isAtSameMomentAs(endOfToday));
      final isThisMonth = (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth)) &&
                          (date.isBefore(endOfMonth) || date.isAtSameMomentAs(endOfMonth));

      if (isToday) {
        ordersTodayCount++;
        if (order.status == 'Delivered') {
          revenueTodaySum += order.total;
        }
      }
      if (isThisMonth) {
        ordersThisMonthCount++;
        if (order.status == 'Delivered') {
          revenueThisMonthSum += order.total;
        }
      }
    }

    // Daily Revenue Grouping
    final dailyRevenueMap = <String, double>{};
    final langCode = locale.languageCode;

    if (activeFilter == 'Today') {
      final slots = langCode == 'ar'
          ? ['١٢ ص - ٤ ص', '٤ ص - ٨ ص', '٨ ص - ١٢ م', '١٢ م - ٤ م', '٤ م - ٨ م', '٨ م - ١٢ ص']
          : ['12 AM - 4 AM', '4 AM - 8 AM', '8 AM - 12 PM', '12 PM - 4 PM', '4 PM - 8 PM', '8 PM - 12 AM'];
      for (final s in slots) {
        dailyRevenueMap[s] = 0.0;
      }
      for (final order in orders) {
        if (order.status == 'Delivered' &&
            (order.createdAt.isAfter(startOfToday) || order.createdAt.isAtSameMomentAs(startOfToday)) &&
            (order.createdAt.isBefore(endOfToday) || order.createdAt.isAtSameMomentAs(endOfToday))) {
          final hr = order.createdAt.hour;
          int slotIdx = hr ~/ 4;
          if (slotIdx >= 6) slotIdx = 5;
          final sName = slots[slotIdx];
          dailyRevenueMap[sName] = (dailyRevenueMap[sName] ?? 0.0) + order.total;
        }
      }
    } else if (activeFilter == '7 Days') {
      for (int i = 6; i >= 0; i--) {
        final d = startOfToday.subtract(Duration(days: i));
        final label = DateFormat('EEE d/M', langCode).format(d);
        dailyRevenueMap[label] = 0.0;
      }
      for (final order in orders) {
        if (order.status == 'Delivered') {
          final date = order.createdAt;
          final diffDays = startOfToday.difference(DateTime(date.year, date.month, date.day)).inDays;
          if (diffDays >= 0 && diffDays < 7) {
            final label = DateFormat('EEE d/M', langCode).format(date);
            dailyRevenueMap[label] = (dailyRevenueMap[label] ?? 0.0) + order.total;
          }
        }
      }
    } else if (activeFilter == '30 Days') {
      for (int i = 29; i >= 0; i--) {
        final d = startOfToday.subtract(Duration(days: i));
        final label = DateFormat('d/M', langCode).format(d);
        dailyRevenueMap[label] = 0.0;
      }
      for (final order in orders) {
        if (order.status == 'Delivered') {
          final date = order.createdAt;
          final diffDays = startOfToday.difference(DateTime(date.year, date.month, date.day)).inDays;
          if (diffDays >= 0 && diffDays < 30) {
            final label = DateFormat('d/M', langCode).format(date);
            dailyRevenueMap[label] = (dailyRevenueMap[label] ?? 0.0) + order.total;
          }
        }
      }
    } else if (activeFilter == 'This Month') {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        final d = DateTime(now.year, now.month, i);
        final label = DateFormat('d/M', langCode).format(d);
        dailyRevenueMap[label] = 0.0;
      }
      for (final order in orders) {
        if (order.status == 'Delivered') {
          final date = order.createdAt;
          if (date.year == now.year && date.month == now.month) {
            final label = DateFormat('d/M', langCode).format(date);
            dailyRevenueMap[label] = (dailyRevenueMap[label] ?? 0.0) + order.total;
          }
        }
      }
    }

    final dailyRevenueData = dailyRevenueMap.entries.map((e) => ChartBarData(e.key, e.value)).toList();

    // Monthly Revenue Grouping
    final monthlyRevenueMap = <String, double>{};
    final months = langCode == 'ar'
        ? ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    for (final m in months) {
      monthlyRevenueMap[m] = 0.0;
    }
    for (final order in orders) {
      if (order.status == 'Delivered' && order.createdAt.year == now.year) {
        final mIdx = order.createdAt.month - 1;
        if (mIdx >= 0 && mIdx < 12) {
          final mName = months[mIdx];
          monthlyRevenueMap[mName] = (monthlyRevenueMap[mName] ?? 0.0) + order.total;
        }
      }
    }
    final monthlyRevenueData = monthlyRevenueMap.entries.map((e) => ChartBarData(e.key, e.value)).toList();

    // Top Products and Categories Mappings
    final productSalesMap = <String, int>{};
    final prodToCatMap = {for (final p in products) p.id: p.categoryId};
    final catMap = {
      for (final c in categories)
        c.id: langCode == 'ar' ? c.nameAr : c.nameEn
    };

    final categorySalesMap = <String, int>{};

    for (final order in orders) {
      final date = order.createdAt;
      final inFilter = (date.isAfter(startOfFilter) || date.isAtSameMomentAs(startOfFilter)) &&
                       (date.isBefore(endOfFilter) || date.isAtSameMomentAs(endOfFilter));
      if (inFilter && order.status != 'Cancelled') {
        for (final item in order.items) {
          final prodName = langCode == 'ar' ? item.productNameAr : item.productNameEn;
          productSalesMap[prodName] = (productSalesMap[prodName] ?? 0) + item.quantity;

          final catId = prodToCatMap[item.productId];
          final catName = catMap[catId] ?? (langCode == 'ar' ? 'أخرى' : 'Other');
          categorySalesMap[catName] = (categorySalesMap[catName] ?? 0) + item.quantity;
        }
      }
    }

    final topProducts = productSalesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categorySalesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final expenses = expensesRes is Success<List<ExpenseEntity>> ? expensesRes.data : <ExpenseEntity>[];
    double expensesThisMonthSum = 0.0;
    for (final e in expenses) {
      final date = e.expenseDate;
      final isThisMonth = (date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth)) &&
                          (date.isBefore(endOfMonth) || date.isAtSameMomentAs(endOfMonth));
      if (isThisMonth) {
        expensesThisMonthSum += e.amount;
      }
    }
    final netProfitThisMonthSum = revenueThisMonthSum - expensesThisMonthSum;

    return AnalyticsStats(
      ordersToday: ordersTodayCount,
      ordersThisMonth: ordersThisMonthCount,
      revenueToday: revenueTodaySum,
      revenueThisMonth: revenueThisMonthSum,
      expensesThisMonth: expensesThisMonthSum,
      netProfitThisMonth: netProfitThisMonthSum,
      productsCount: productsCount,
      customersCount: customersCount,
      dailyRevenueData: dailyRevenueData,
      monthlyRevenueData: monthlyRevenueData,
      topProducts: topProducts.take(5).toList(),
      topCategories: topCategories.take(5).toList(),
    );
  });
});

class AdminAnalyticsPage extends ConsumerWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminAnalyticsProvider);
    final activeFilter = ref.watch(analyticsFilterProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'التحليلات والمبيعات' : 'Analytics & Sales'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminAnalyticsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Glassmorphism Filter Selector
                _buildFilterChips(context, ref, activeFilter),
                const SizedBox(height: 20),

                // Metrics summary cards
                _buildMetricsGrid(context, stats),
                const SizedBox(height: 28),

                // Custom charts layout
                if (context.isMobile) ...[
                  _buildDailyRevenueSection(context, stats, activeFilter),
                  const SizedBox(height: 28),
                  _buildMonthlyRevenueSection(context, stats),
                  const SizedBox(height: 28),
                  _buildTopProductsSection(context, stats),
                  const SizedBox(height: 28),
                  _buildTopCategoriesSection(context, stats),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildDailyRevenueSection(context, stats, activeFilter),
                            const SizedBox(height: 28),
                            _buildMonthlyRevenueSection(context, stats),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTopProductsSection(context, stats),
                            const SizedBox(height: 28),
                            _buildTopCategoriesSection(context, stats),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, String active) {
    final isAr = context.isRtl;
    final filters = ['Today', '7 Days', '30 Days', 'This Month'];
    final labels = isAr 
        ? ['اليوم', '٧ أيام', '٣٠ يوماً', 'هذا الشهر'] 
        : ['Today', '7 Days', '30 Days', 'This Month'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (idx) {
            final f = filters[idx];
            final label = labels[idx];
            final isSelected = active == f;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                selectedColor: context.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (val) {
                  if (val) {
                    ref.read(analyticsFilterProvider.notifier).state = f;
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, AnalyticsStats stats) {
    final isAr = context.isRtl;

    return GridView.count(
      crossAxisCount: context.isMobile ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: context.isMobile ? 1.25 : 1.6,
      children: [
        _buildMetricCard(
          context,
          title: isAr ? 'طلبات اليوم' : 'Orders Today',
          value: '${stats.ordersToday}',
          icon: Icons.today_outlined,
          color: Colors.blue.shade700,
        ),
        _buildMetricCard(
          context,
          title: isAr ? 'طلبات هذا الشهر' : 'Orders This Month',
          value: '${stats.ordersThisMonth}',
          icon: Icons.calendar_month_outlined,
          color: Colors.purple.shade700,
        ),
        _buildMetricCard(
          context,
          title: isAr ? 'إيرادات هذا الشهر' : 'Revenue This Month',
          value: context.formatPrice(stats.revenueThisMonth),
          icon: Icons.monetization_on_outlined,
          color: Colors.green.shade700,
          subValue: 'E£ / EGP',
        ),
        _buildMetricCard(
          context,
          title: isAr ? 'مصروفات هذا الشهر' : 'Expenses This Month',
          value: context.formatPrice(stats.expensesThisMonth),
          icon: Icons.money_off_outlined,
          color: Colors.red.shade700,
          subValue: 'E£ / EGP',
        ),
        _buildMetricCard(
          context,
          title: isAr ? 'صافي أرباح الشهر' : 'Net Profit This Month',
          value: context.formatPrice(stats.netProfitThisMonth),
          icon: Icons.trending_up,
          color: stats.netProfitThisMonth >= 0 ? Colors.teal.shade700 : Colors.red.shade900,
          subValue: 'E£ / EGP',
        ),
        _buildMetricCard(
          context,
          title: isAr ? 'عدد العملاء' : 'Customers Count',
          value: '${stats.customersCount}',
          icon: Icons.people_outline,
          color: Colors.indigo.shade700,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subValue,
  }) {
    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.surface,
              color.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subValue != null) ...[
              const SizedBox(height: 2),
              Text(
                subValue,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRevenueSection(BuildContext context, AnalyticsStats stats, String filter) {
    final isAr = context.isRtl;
    String title = isAr ? 'الإيرادات اليومية' : 'Daily Revenue';
    if (filter == 'Today') {
      title = isAr ? 'إيرادات اليوم (حسب الساعات)' : 'Today\'s Hourly Revenue';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _BarChartWidget(data: stats.dailyRevenueData),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyRevenueSection(BuildContext context, AnalyticsStats stats) {
    final isAr = context.isRtl;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'الإيرادات الشهرية' : 'Monthly Revenue',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _BarChartWidget(data: stats.monthlyRevenueData),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsSection(BuildContext context, AnalyticsStats stats) {
    final isAr = context.isRtl;
    final data = stats.topProducts;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'المنتجات الأكثر مبيعاً' : 'Top Products',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (data.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    isAr ? 'لا توجد بيانات للفلترة المحددة' : 'No product sales data for selected filter',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entry = data[index];
                  final maxVal = data.first.value;
                  final fraction = maxVal > 0 ? entry.value / maxVal : 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            isAr ? '${entry.value} وحدة' : '${entry.value} units',
                            style: TextStyle(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          backgroundColor: context.colorScheme.surfaceVariant,
                          color: context.colorScheme.primary,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoriesSection(BuildContext context, AnalyticsStats stats) {
    final isAr = context.isRtl;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'الفئات الأكثر مبيعاً' : 'Top Categories',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (stats.topCategories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    isAr ? 'لا توجد بيانات للفلترة المحددة' : 'No category sales data for selected filter',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              _DonutChartWidget(data: stats.topCategories),
          ],
        ),
      ),
    );
  }
}

// Custom interactive vertical bar chart
class _BarChartWidget extends StatefulWidget {
  final List<ChartBarData> data;

  const _BarChartWidget({required this.data});

  @override
  State<_BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<_BarChartWidget> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No revenue data available', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final maxVal = widget.data.fold<double>(0.0, (max, e) => e.value > max ? e.value : max);
    final isAr = context.isRtl;

    return SizedBox(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.data.length, (idx) {
                  final item = widget.data[idx];
                  final barHeight = maxVal > 0 ? (item.value / maxVal) * 140.0 : 0.0;
                  final isHovered = _hoveredIndex == idx;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _hoveredIndex = isHovered ? null : idx;
                      });
                    },
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _hoveredIndex = idx;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _hoveredIndex = null;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isHovered && item.value > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${item.value.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: context.colorScheme.surface,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 18),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              width: widget.data.length > 15 ? 18 : 28,
                              height: barHeight == 0 ? 4 : barHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isHovered
                                      ? [context.colorScheme.primary, context.colorScheme.tertiary]
                                      : [
                                          context.colorScheme.primary.withOpacity(0.8),
                                          context.colorScheme.primary.withOpacity(0.5)
                                        ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: widget.data.length > 15 ? 18 : 34,
                              child: Text(
                                item.label,
                                style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Donut chart
class _DonutChartWidget extends StatelessWidget {
  final List<MapEntry<String, int>> data;

  const _DonutChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, e) => sum + e.value);
    if (total == 0) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text('No data available')),
      );
    }

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.amber.shade700,
      Colors.purple.shade600,
      Colors.teal.shade600,
    ];

    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(130, 130),
                painter: _DonutChartPainter(data: data, total: total, colors: colors),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      context.isRtl ? 'المبيعات' : 'Sales',
                      style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(data.length, (idx) {
              final entry = data[idx];
              final pct = (entry.value / total * 100).toStringAsFixed(1);
              final color = colors[idx % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$pct%',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> data;
  final int total;
  final List<Color> colors;

  _DonutChartPainter({required this.data, required this.total, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 18.0;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -3.1415926535 / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.1415926535;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
