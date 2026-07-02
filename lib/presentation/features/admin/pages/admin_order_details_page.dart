import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/audit_log_repository_provider.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:intl/intl.dart';

final _adminOrderDetailProvider = StreamProvider.family.autoDispose<OrderEntity?, String>((ref, id) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchOrder(id);
});

class AdminOrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;

  const AdminOrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends ConsumerState<AdminOrderDetailPage> {
  bool _isUpdating = false;  Color _getStatusColor(BuildContext context, String status) {
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
  Future<void> _updateStatus(String status, OrderEntity order) async {
    setState(() {
      _isUpdating = true;
    });

    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.updateOrderStatus(widget.orderId, status);

    if (!mounted) return;

    setState(() {
      _isUpdating = false;
    });

    if (result is Success<void>) {
      context.showSnackBar(context.l10n.statusUpdated);
      if (status == 'Cancelled') {
        final currentUser = ref.read(authNotifierProvider).user;
        if (currentUser != null) {
          final auditLogRepo = ref.read(auditLogRepositoryProvider);
          await auditLogRepo.createAuditLog(
            AuditLogEntity(
              id: '',
              userId: currentUser.id,
              userEmail: currentUser.email,
              action: 'Order Cancelled',
              details: 'Order ${order.orderNumber} was cancelled by administrator (${currentUser.email}).',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    } else if (result is Failure<void>) {
      context.showSnackBar(result.error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(_adminOrderDetailProvider(widget.orderId));
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'تفاصيل الطلب' : 'Order Details'),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return Center(
              child: Text(
                isAr ? 'الطلب غير موجود' : 'Order not found',
                style: context.textTheme.titleMedium,
              ),
            );
          }
          return _buildContent(context, order);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: TextStyle(color: context.colorScheme.error)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderEntity order) {
    final isAr = context.isRtl;
    final dateStr = DateFormat.yMMMd().add_jm().format(order.createdAt);
    final statusColor = _getStatusColor(context, order.status);    final statusOptions = [
      'Pending',
      'Confirmed',
      'Preparing',
      'OutForDelivery',
      'Delivered',
      'Cancelled',
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status header panel
        Card(
          elevation: 0,
          color: statusColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: statusColor.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'الحالة الحالية' : 'Current Status',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLocalStatusName(context, order.status),
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_isUpdating)
                      const CircularProgressIndicator()
                    else
                      DropdownButton<String>(
                        value: order.status,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                        underline: const SizedBox(),
                        icon: Icon(Icons.edit, color: statusColor),
                        borderRadius: BorderRadius.circular(12),
                        onChanged: (newStatus) {
                          if (newStatus != null && newStatus != order.status) {
                            _updateStatus(newStatus, order);
                          }
                        },
                        items: statusOptions.map((st) {
                          return DropdownMenuItem<String>(
                            value: st,
                            child: Text(
                              _getLocalStatusName(context, st),
                              style: TextStyle(
                                color: _getStatusColor(context, st),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order Info & Customer Details Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'معلومات الطلب والعميل' : 'Order & Customer Info',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                _buildInfoRow(context, isAr ? 'رقم الطلب' : 'Order Number', order.orderNumber.isNotEmpty ? order.orderNumber : order.id, isSelectable: true),
                _buildInfoRow(context, context.l10n.orderId, order.id, isSelectable: true),
                _buildInfoRow(context, isAr ? 'اسم العميل' : 'Customer Name', order.customerName),
                _buildInfoRow(context, isAr ? 'هاتف العميل' : 'Customer Phone', order.phone),
                _buildInfoRow(context, isAr ? 'بريد العميل الالكتروني' : 'Customer Email', order.userEmail),
                _buildInfoRow(context, isAr ? 'رقم تعريف العميل' : 'Customer ID', order.customerId),
                _buildInfoRow(context, context.l10n.orderDate, dateStr),
                _buildInfoRow(context, isAr ? 'العنوان' : 'Address', order.address),              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Timeline Progress Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تتبع حالة الطلب' : 'Order Progress Tracking',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                _buildTimeline(context, order.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order Items List Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: context.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.items,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: context.colorScheme.surfaceContainerHighest,
                            child: item.imageUrl != null
                                ? Image.network(
                                    item.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.inventory_2,
                                      color: context.colorScheme.outline,
                                    ),
                                  )
                                : Icon(
                                    Icons.inventory_2,
                                    color: context.colorScheme.outline,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? item.productNameAr : item.productNameEn,
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x ${context.formatPrice(item.price)}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          context.formatPrice(item.price * item.quantity),
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 32),
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
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isSelectable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: isSelectable
                ? SelectableText(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, String currentStatus) {
    final isAr = context.isRtl;
    if (currentStatus == 'Cancelled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              isAr ? 'تم إلغاء هذا الطلب ولا يمكن متابعته.' : 'This order has been cancelled and cannot proceed.',
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    final steps = ['Pending', 'Confirmed', 'Preparing', 'OutForDelivery', 'Delivered'];
    final currentIndex = steps.indexOf(currentStatus);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final stepName = _getLocalStatusName(context, step);
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;
        final activeColor = _getStatusColor(context, step);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? activeColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? activeColor : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepName,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
