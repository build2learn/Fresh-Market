import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/user_role.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/address_repository_provider.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/domain/entities/address.entity.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CustomerStats {
  final UserEntity user;
  final int orderCount;
  final double totalSpend;
  final DateTime? lastOrderDate;
  final List<OrderEntity> orders;

  const CustomerStats({
    required this.user,
    required this.orderCount,
    required this.totalSpend,
    this.lastOrderDate,
    required this.orders,
  });
}

final adminCustomersProvider = FutureProvider.autoDispose<List<CustomerStats>>((ref) async {
  final userRepo = ref.watch(userRepositoryProvider);
  final orderRepo = ref.watch(orderRepositoryProvider);

  final usersResult = await userRepo.getUsers(limit: 100);
  final ordersResult = await orderRepo.getOrders();

  if (usersResult is Success<List<UserEntity>> && ordersResult is Success<List<OrderEntity>>) {
    final allUsers = usersResult.data;
    final orders = ordersResult.data;

    return allUsers.map((user) {
      final userOrdersAll = orders.where((o) => o.userId == user.id).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final userOrdersActive = userOrdersAll.where((o) => o.status != 'Cancelled').toList();
      final totalSpend = userOrdersActive.fold<double>(0, (sum, o) => sum + (o.total > 0 ? o.total : o.totalAmount));
      final lastOrderDate = userOrdersAll.isNotEmpty ? userOrdersAll.first.createdAt : null;

      return CustomerStats(
        user: user,
        orderCount: userOrdersActive.length,
        totalSpend: totalSpend,
        lastOrderDate: lastOrderDate,
        orders: userOrdersAll,
      );
    }).toList();
  }

  return <CustomerStats>[];
});

class AdminCustomersPage extends ConsumerStatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  ConsumerState<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends ConsumerState<AdminCustomersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(adminCustomersProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة العملاء' : 'Customer Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people_outline),
              text: isAr ? 'دليل العملاء' : 'Customer Directory',
            ),
            Tab(
              icon: const Icon(Icons.insights),
              text: isAr ? 'رؤى وتحليلات' : 'Insights Dashboard',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDirectoryTab(customersAsync),
          _buildInsightsTab(customersAsync),
        ],
      ),
    );
  }

  Widget _buildDirectoryTab(AsyncValue<List<CustomerStats>> asyncVal) {
    final isAr = context.isRtl;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAr ? 'بحث باسم العميل، البريد، أو الهاتف...' : 'Search by name, email, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRoleFilter,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(isAr ? 'الكل' : 'All Roles'),
                    ),
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text(isAr ? 'العملاء' : 'Customers'),
                    ),
                    DropdownMenuItem(
                      value: 'staff',
                      child: Text(isAr ? 'الموظفين' : 'Staff/Employees'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRoleFilter = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminCustomersProvider),
            child: asyncVal.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('$err')),
              data: (list) {
                final filtered = list.where((stats) {
                  if (_selectedRoleFilter == 'customer' && !stats.user.isCustomer) return false;
                  if (_selectedRoleFilter == 'staff' && !stats.user.role.isStaff) return false;

                  if (_searchQuery.isEmpty) return true;
                  final name = (stats.user.displayName ?? '').toLowerCase();
                  final email = stats.user.email.toLowerCase();
                  final phone = (stats.user.phoneNumber ?? '').toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      phone.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      isAr ? 'لا يوجد عملاء يطابقون البحث' : 'No customers match your search',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final stats = filtered[index];
                    return _CustomerCard(stats: stats);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsTab(AsyncValue<List<CustomerStats>> asyncVal) {
    final isAr = context.isRtl;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminCustomersProvider),
      child: asyncVal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text(isAr ? 'لا توجد بيانات متاحة' : 'No customer data available'),
            );
          }

          final topSpenders = List<CustomerStats>.from(list)
            ..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));

          final mostActive = List<CustomerStats>.from(list)
            ..sort((a, b) => b.orderCount.compareTo(a.orderCount));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInsightSection(
                context,
                title: isAr ? 'الأكثر إنفاقاً (أعلى 5)' : 'Top Spenders (Top 5)',
                statsList: topSpenders.take(5).toList(),
                valueBuilder: (stats) => context.formatPrice(stats.totalSpend),
                progressBuilder: (stats) {
                  final maxVal = topSpenders.first.totalSpend;
                  return maxVal > 0 ? stats.totalSpend / maxVal : 0.0;
                },
              ),
              const SizedBox(height: 28),
              _buildInsightSection(
                context,
                title: isAr ? 'الأكثر نشاطاً بالطلبات (أعلى 5)' : 'Most Active by Orders (Top 5)',
                statsList: mostActive.take(5).toList(),
                valueBuilder: (stats) => isAr ? '${stats.orderCount} طلبات' : '${stats.orderCount} orders',
                progressBuilder: (stats) {
                  final maxVal = mostActive.first.orderCount;
                  return maxVal > 0 ? stats.orderCount / maxVal : 0.0;
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInsightSection(
    BuildContext context, {
    required String title,
    required List<CustomerStats> statsList,
    required String Function(CustomerStats) valueBuilder,
    required double Function(CustomerStats) progressBuilder,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final stats = statsList[index];
                final progress = progressBuilder(stats);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stats.user.displayName ?? stats.user.email,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          valueBuilder(stats),
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
                        value: progress,
                        backgroundColor: context.colorScheme.surfaceContainerHighest,
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
}

class _CustomerCard extends ConsumerWidget {
  final CustomerStats stats;

  const _CustomerCard({required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = context.isRtl;
    final user = stats.user;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: user.isActive ? Colors.transparent : Colors.red.shade300.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: user.isActive ? context.colorScheme.primaryContainer : Colors.red.shade50,
          child: Text(
            user.displayName != null && user.displayName!.isNotEmpty
                ? user.displayName![0].toUpperCase()
                : 'C',
            style: TextStyle(
              color: user.isActive ? context.colorScheme.onPrimaryContainer : Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName ?? (isAr ? 'عميل غير مسمى' : 'Unnamed Customer'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: user.isActive ? Colors.green.shade300 : Colors.red.shade300),
              ),
              child: Text(
                user.isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'غير نشط' : 'Inactive'),
                style: TextStyle(
                  color: user.isActive ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(fontSize: 12)),
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              Text(user.phoneNumber!, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCompactStat(
                  context,
                  isAr ? 'الطلبات: ${stats.orderCount}' : 'Orders: ${stats.orderCount}',
                  context.colorScheme.secondaryContainer,
                  context.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                _buildCompactStat(
                  context,
                  isAr ? 'الإنفاق: ${context.formatPrice(stats.totalSpend)}' : 'Spend: ${context.formatPrice(stats.totalSpend)}',
                  context.colorScheme.tertiaryContainer,
                  context.colorScheme.onTertiaryContainer,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: user.isActive,
              activeColor: Colors.green,
              onChanged: (val) async {
                final repo = ref.read(userRepositoryProvider);
                await repo.toggleUserActive(user.id, val);
                ref.invalidate(adminCustomersProvider);
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showCustomerDetailsDialog(context, ref),
      ),
    );
  }

  Widget _buildCompactStat(BuildContext context, String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: textCol, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, WidgetRef ref) {
    final isAr = context.isRtl;
    final user = stats.user;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تفاصيل ملف العميل' : 'Customer Profile Details'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile section
                _buildSectionHeader(context, isAr ? 'معلومات الحساب' : 'Account Information'),
                const SizedBox(height: 8),
                _buildDetailRow(isAr ? 'الاسم' : 'Name', user.displayName ?? 'N/A'),
                _buildDetailRow(isAr ? 'البريد الإلكتروني' : 'Email', user.email),
                _buildDetailRow(isAr ? 'الهاتف' : 'Phone', user.phoneNumber ?? 'N/A'),
                _buildDetailRow(
                  isAr ? 'حالة الحساب' : 'Account Status',
                  user.isActive ? (isAr ? 'نشط' : 'Active') : (isAr ? 'غير نشط' : 'Inactive'),
                  color: user.isActive ? Colors.green : Colors.red,
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final currentUser = ref.watch(currentUserProvider);
                    if (currentUser == null || !currentUser.role.canManageSettings) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 24),
                        _buildSectionHeader(context, isAr ? 'صلاحيات الحساب' : 'Account Role & Permissions'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<UserRole>(
                          value: user.role,
                          decoration: InputDecoration(
                            labelText: isAr ? 'الصلاحية (الدور)' : 'Role / Position',
                            border: const OutlineInputBorder(),
                          ),
                          items: UserRole.values
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role.value.toUpperCase()),
                                  ),)
                              .toList(),
                          onChanged: (newRole) async {
                            if (newRole != null) {
                              final repo = ref.read(userRepositoryProvider);
                              await repo.updateUserRole(user.id, newRole.value);
                              ref.invalidate(adminCustomersProvider);
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 24),

                // Statistics
                _buildSectionHeader(context, isAr ? 'الملخص والإحصائيات' : 'Summary & Statistics'),
                const SizedBox(height: 8),
                _buildDetailRow(isAr ? 'إجمالي المشتريات' : 'Total Spend', context.formatPrice(stats.totalSpend)),
                _buildDetailRow(isAr ? 'عدد الطلبات المكتملة' : 'Orders Count', '${stats.orderCount}'),
                _buildDetailRow(
                  isAr ? 'تاريخ آخر طلب' : 'Last Order Date',
                  stats.lastOrderDate != null
                      ? DateFormat.yMMMd(isAr ? 'ar' : 'en').add_jm().format(stats.lastOrderDate!)
                      : 'N/A',
                ),
                _buildDetailRow(
                  isAr ? 'مستوى العضوية' : 'Membership Level',
                  '${user.membershipLevel} (${user.loyaltyPoints} ${isAr ? 'نقطة' : 'Points'})',
                  color: Colors.orange.shade800,
                ),
                const Divider(height: 24),

                // Addresses list
                _buildSectionHeader(context, isAr ? 'العناوين المسجلة' : 'Addresses'),
                const SizedBox(height: 8),
                FutureBuilder<Result<List<AddressEntity>>>(
                  future: ref.read(addressRepositoryProvider).getAddresses(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LinearProgressIndicator());
                    }
                    final res = snapshot.data;
                    if (res is Success<List<AddressEntity>> && res.data.isNotEmpty) {
                      return Column(
                        children: res.data.map((address) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            child: ListTile(
                              dense: true,
                              title: Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${address.phone}\n${address.address}, ${address.city}'),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Text(
                      isAr ? 'لا توجد عناوين مسجلة' : 'No registered addresses found',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    );
                  },
                ),
                const Divider(height: 24),

                // Order history
                _buildSectionHeader(context, isAr ? 'سجل الطلبات' : 'Order History'),
                const SizedBox(height: 8),
                if (stats.orders.isEmpty)
                  Text(
                    isAr ? 'لا توجد طلبات سابقة' : 'No order history',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  )
                else
                  Column(
                    children: stats.orders.map((order) {
                      Color statusCol = Colors.grey;
                      if (order.status == 'Delivered') statusCol = Colors.green;
                      if (order.status == 'Cancelled') statusCol = Colors.red;
                      if (order.status == 'Pending') statusCol = Colors.orange;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          dense: true,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(context.formatPrice(order.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat.yMMMd(isAr ? 'ar' : 'en').format(order.createdAt)),
                              Text(
                                order.status,
                                style: TextStyle(color: statusCol, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/admin/orders/${order.id}');
                          },
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colorScheme.primary,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
