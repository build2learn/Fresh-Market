import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/order.entity.dart';
import '../../../../data/providers/order_repository_provider.dart';
import '../../auth/providers/auth_providers.dart';

final _userOrderStatusTabProvider = StateProvider.autoDispose<String>((ref) => 'All');

final _userOrdersStreamProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  final status = ref.watch(_userOrderStatusTabProvider);
  final repo = ref.watch(orderRepositoryProvider);
  
  return repo.watchOrders(
    userId: user.id,
    status: status == 'All' ? null : status,
  );
});

class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Pending':
        return Colors.amber.shade700;
      case 'Confirmed':
        return Colors.blue.shade700;
      case 'Preparing':
        return Colors.indigo.shade700;
      case 'OutForDelivery':
        return Colors.purple.shade700;
      case 'Delivered':
        return Colors.green.shade700;
      case 'Cancelled':
        return Colors.red.shade700;
      default:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  String _getLocalStatusName(BuildContext context, String status) {
    switch (status) {
      case 'Pending':
        return context.l10n.statusPending;
      case 'Confirmed':
        return context.l10n.statusConfirmed;
      case 'Preparing':
        return context.l10n.statusPreparing;
      case 'OutForDelivery':
        return context.l10n.statusOutForDelivery;
      case 'Delivered':
        return context.l10n.statusDelivered;
      case 'Cancelled':
        return context.l10n.statusCancelled;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = context.isRtl;
    final selectedTab = ref.watch(_userOrderStatusTabProvider);
    final ordersAsync = ref.watch(_userOrdersStreamProvider);

    final statusTabs = [
      'All',
      'Pending',
      'Confirmed',
      'Preparing',
      'OutForDelivery',
      'Delivered',
      'Cancelled'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'طلباتي' : 'My Orders'),
      ),
      body: Column(
        children: [
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: statusTabs.map((status) {
                final isSelected = selectedTab == status;
                final tabLabel = status == 'All'
                    ? (isAr ? 'الكل' : 'All')
                    : _getLocalStatusName(context, status);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tabLabel),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(_userOrderStatusTabProvider.notifier).state = status;
                      }
                    },
                    selectedColor: context.colorScheme.primaryContainer,
                    checkmarkColor: context.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: context.colorScheme.outline.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAr ? 'لا توجد طلبات بعد' : 'No orders found',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final dateStr = DateFormat.yMMMd().add_jm().format(order.createdAt);
                    final statusColor = _getStatusColor(context, order.status);
                    final statusLabel = _getLocalStatusName(context, order.status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: context.colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => context.push(RouteConstants.orderDetailPath(order.id)),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order.orderNumber.isNotEmpty 
                                        ? order.orderNumber 
                                        : '#${order.id.substring(0, 8)}',
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: statusColor.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: context.textTheme.labelMedium?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 16, color: context.colorScheme.outline),
                                  const SizedBox(width: 8),
                                  Text(
                                    dateStr,
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 16, color: context.colorScheme.outline),
                                  const SizedBox(width: 8),
                                  Text(
                                    isAr 
                                        ? 'المنتجات: ${order.items.length}' 
                                        : 'Products: ${order.items.length}',
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isAr ? 'الإجمالي:' : 'Total:',
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    context.formatPrice(order.total),
                                    style: context.textTheme.titleMedium?.copyWith(
                                      color: context.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
