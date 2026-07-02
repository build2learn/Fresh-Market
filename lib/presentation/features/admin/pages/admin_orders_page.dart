import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:intl/intl.dart';

final _adminOrderStatusTabProvider = StateProvider<String>((ref) => 'All');
final _adminOrderSearchQueryProvider = StateProvider<String>((ref) => '');

final _adminOrdersBaseStreamProvider = StreamProvider.autoDispose<List<OrderEntity>>((ref) {
  final status = ref.watch(_adminOrderStatusTabProvider);
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchOrders(status: status == 'All' ? null : status);
});

final _adminOrdersStreamProvider = Provider.autoDispose<AsyncValue<List<OrderEntity>>>((ref) {
  final baseState = ref.watch(_adminOrdersBaseStreamProvider);
  final searchQuery = ref.watch(_adminOrderSearchQueryProvider).trim().toLowerCase();

  return baseState.whenData((list) {
    if (searchQuery.isEmpty) return list;
    return list.where((o) =>
        o.id.toLowerCase().contains(searchQuery) ||
        o.orderNumber.toLowerCase().contains(searchQuery) ||
        o.customerName.toLowerCase().contains(searchQuery) ||
        o.phone.toLowerCase().contains(searchQuery) ||
        o.address.toLowerCase().contains(searchQuery) ||
        o.userEmail.toLowerCase().contains(searchQuery)).toList();
  });
});

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
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
  Widget build(BuildContext context) {
    final selectedStatus = ref.watch(_adminOrderStatusTabProvider);
    final ordersAsync = ref.watch(_adminOrdersStreamProvider);

    final statusList = [
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
        title: Text(context.l10n.ordersTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: context.l10n.searchOrders,
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(_adminOrderSearchQueryProvider.notifier).state = '';
                        },
                      ),
                  ],
                  onChanged: (val) {
                    ref.read(_adminOrderSearchQueryProvider.notifier).state = val.trim();
                  },
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(context.colorScheme.surfaceContainerHigh),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: statusList.map((status) {
                final isSelected = selectedStatus == status;
                final statusName = status == 'All'
                    ? (context.isRtl ? 'الكل' : 'All')
                    : _getLocalStatusName(context, status);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(statusName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(_adminOrderStatusTabProvider.notifier).state = status;
                      }
                    },
                    selectedColor: context.colorScheme.primaryContainer,
                    checkmarkColor: context.colorScheme.primary,
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
                          Icons.inbox_outlined,
                          size: 64,
                          color: context.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.noOrders,
                          style: context.textTheme.titleMedium?.copyWith(
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
                    return _buildOrderCard(context, order);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error: $err', style: TextStyle(color: context.colorScheme.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final statusColor = _getStatusColor(context, order.status);
    final statusText = _getLocalStatusName(context, order.status);
    final dateStr = DateFormat.yMMMd().add_jm().format(order.createdAt);
    final isAr = context.isRtl;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () => context.push(RouteConstants.adminOrderDetailPath(order.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          isAr ? 'الطلب: ' : 'Order: ',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SelectableText(
                          order.orderNumber.isNotEmpty ? order.orderNumber : (order.id.length > 10 ? '${order.id.substring(0, 10)}...' : order.id),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            final textToCopy = order.orderNumber.isNotEmpty ? order.orderNumber : order.id;
                            Clipboard.setData(ClipboardData(text: textToCopy));
                            context.showSnackBar(
                              isAr ? 'تم نسخ رقم الطلب!' : 'Order number copied!',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      statusText,
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
                  Icon(Icons.person_outline, size: 16, color: context.colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    order.customerName.isNotEmpty 
                        ? '${order.customerName} (${order.userEmail})'
                        : order.userEmail,
                    style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: context.colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    order.phone.isNotEmpty ? order.phone : (isAr ? 'لا يوجد هاتف' : 'No phone'),
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: context.colorScheme.outline),
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
                  Icon(Icons.shopping_bag_outlined, size: 16, color: context.colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    isAr
                        ? 'عدد العناصر: ${order.items.fold(0, (sum, i) => sum + i.quantity)}'
                        : 'Items count: ${order.items.fold(0, (sum, i) => sum + i.quantity)}',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartTotal,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.formatPrice(order.totalAmount),
                    style: context.textTheme.titleLarge?.copyWith(
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
  }
}
