import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/order.entity.dart';
import '../../../../data/providers/order_repository_provider.dart';
import '../../../../data/providers/audit_log_repository_provider.dart';
import '../../../../domain/entities/audit_log.entity.dart';
import '../../auth/providers/auth_providers.dart';

final _customerOrderDetailProvider = StreamProvider.family.autoDispose<OrderEntity?, String>((ref, id) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchOrders().map((list) {
    try {
      return list.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  });
});

class CustomerOrderDetailPage extends ConsumerStatefulWidget {
  final String orderId;

  const CustomerOrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<CustomerOrderDetailPage> createState() => _CustomerOrderDetailPageState();
}

class _CustomerOrderDetailPageState extends ConsumerState<CustomerOrderDetailPage> {
  bool _isCancelling = false;

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

  Future<void> _cancelOrder(OrderEntity order) async {
    final isAr = context.isRtl;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'إلغاء الطلب' : 'Cancel Order'),
        content: Text(
          isAr
              ? 'هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'
              : 'Are you sure you want to cancel this order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isAr ? 'تراجع' : 'Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
            ),
            child: Text(isAr ? 'إلغاء الطلب' : 'Cancel Order'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    final repo = ref.read(orderRepositoryProvider);
    final result = await repo.updateOrderStatus(widget.orderId, 'Cancelled');

    if (!mounted) return;

    setState(() {
      _isCancelling = false;
    });

    if (result is Success<void>) {
      final currentUser = ref.read(authNotifierProvider).user;
      if (currentUser != null) {
        final auditLogRepo = ref.read(auditLogRepositoryProvider);
        await auditLogRepo.createAuditLog(
          AuditLogEntity(
            id: '',
            userId: currentUser.id,
            userEmail: currentUser.email,
            action: 'Order Cancelled',
            details: 'Order ${order.orderNumber} was cancelled by the customer.',
            timestamp: DateTime.now(),
          ),
        );
      }
      context.showSnackBar(
        isAr ? 'تم إلغاء الطلب بنجاح' : 'Order cancelled successfully',
      );
      // Refresh user points if needed
      ref.read(authNotifierProvider.notifier).refreshUser();
    } else if (result is Failure<void>) {
      context.showSnackBar(result.error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(_customerOrderDetailProvider(widget.orderId));
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
    final statusColor = _getStatusColor(context, order.status);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status indicator card
        Card(
          elevation: 0,
          color: statusColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: statusColor.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'حالة الطلب' : 'Order Status',
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
                if (order.status == 'Pending')
                  _isCancelling
                      ? const CircularProgressIndicator()
                      : FilledButton.icon(
                          onPressed: () => _cancelOrder(order),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(isAr ? 'إلغاء' : 'Cancel'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colorScheme.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order credentials card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'معلومات الطلب' : 'Order Information',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  context,
                  isAr ? 'رقم الطلب' : 'Order Number',
                  order.orderNumber.isNotEmpty ? order.orderNumber : order.id,
                ),
                _buildInfoRow(context, context.l10n.orderDate, dateStr),
                _buildInfoRow(context, isAr ? 'رقم المستلم' : 'Recipient Phone', order.phone),
                _buildInfoRow(context, isAr ? 'عنوان التوصيل' : 'Delivery Address', order.address),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Timeline Progress Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تتبع الطلب' : 'Order Tracking',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _buildTimeline(context, order.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order Items Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'المنتجات' : 'Products',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    final itemName = isAr ? item.productNameAr : item.productNameEn;
                    return Row(
                      children: [
                        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image_outlined),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemName,
                                style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x ${context.formatPrice(item.unitPrice)}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          context.formatPrice(item.totalPrice),
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cost Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'ملخص الحساب' : 'Payment Summary',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                _buildPriceRow(context, isAr ? 'المجموع الفرعي' : 'Subtotal', order.subtotal),
                _buildPriceRow(context, isAr ? 'رسوم التوصيل' : 'Delivery Fee', order.deliveryFee),
                if (order.discountAmount != null && order.discountAmount! > 0)
                  _buildPriceRow(context, isAr ? 'خصم الكوبون' : 'Coupon Discount', -order.discountAmount!),
                if (order.loyaltyDiscount != null && order.loyaltyDiscount! > 0)
                  _buildPriceRow(context, isAr ? 'خصم النقاط' : 'Loyalty Discount', -order.loyaltyDiscount!),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.cartTotal,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      context.formatPrice(order.total),
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (order.loyaltyPointsEarned != null && order.loyaltyPointsEarned! > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    isAr
                        ? 'سوف تكسب ${order.loyaltyPointsEarned} نقطة ولاء من هذا الطلب.'
                        : 'You will earn ${order.loyaltyPointsEarned} loyalty points from this order.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double amount) {
    final formatted = context.formatPrice(amount.abs());
    final sign = amount < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            '$sign$formatted',
            style: context.textTheme.bodyMedium?.copyWith(
              color: amount < 0 ? Colors.red.shade700 : null,
              fontWeight: amount < 0 ? FontWeight.bold : null,
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
              isAr ? 'تم إلغاء هذا الطلب.' : 'This order has been cancelled.',
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
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? Colors.black87 : Colors.black38,
                      ),
                    ),
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
