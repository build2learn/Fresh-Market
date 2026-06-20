import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final actions = ref.read(notificationsActionsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإشعارات' : 'Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () => actions.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(
                isArabic ? 'تحديد الكل كمقروء' : 'Mark all read',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsStreamProvider),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(isArabic ? 'فشل تحميل الإشعارات' : 'Failed to load notifications'),
                const SizedBox(height: 8),
                Text('$err', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 80,
                      color: context.colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isArabic ? 'لا توجد إشعارات بعد' : 'No notifications yet',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'سنقوم بإعلامك فور وجود عروض أو تغييرات جديدة!'
                          : 'We will notify you when new offers or updates arrive!',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final notification = list[index];
                return _NotificationItem(
                  notification: notification,
                  isArabic: isArabic,
                  onTap: () {
                    // Mark as read
                    if (!notification.isRead) {
                      actions.markAsRead(notification.id);
                    }
                    
                    // Navigate if applicable
                    if (notification.type == NotificationType.product &&
                        notification.data != null &&
                        notification.data!['productId'] != null) {
                      final productId = notification.data!['productId'];
                      context.push('/products/$productId');
                    } else if (notification.type == NotificationType.offer &&
                        notification.data != null &&
                        notification.data!['offerId'] != null) {
                      final offerId = notification.data!['offerId'];
                      context.push('/offers/$offerId');
                    }
                  },
                  onMarkRead: () => actions.markAsRead(notification.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final bool isArabic;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const _NotificationItem({
    required this.notification,
    required this.isArabic,
    required this.onTap,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    // Determine title and body based on language data payload
    final title = isArabic
        ? (notification.data?['titleAr'] ?? notification.title)
        : (notification.data?['titleEn'] ?? notification.title);
    final body = isArabic
        ? (notification.data?['bodyAr'] ?? notification.body)
        : (notification.data?['bodyEn'] ?? notification.body);

    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.offer:
        icon = Icons.local_offer_outlined;
        iconColor = Colors.orange;
        break;
      case NotificationType.product:
        icon = Icons.shopping_basket_outlined;
        iconColor = Colors.green;
        break;
      case NotificationType.order:
        icon = Icons.receipt_long_outlined;
        iconColor = Colors.blue;
        break;
      case NotificationType.system:
      default:
        icon = Icons.info_outline;
        iconColor = Colors.purple;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead
          ? context.colorScheme.surfaceVariant.withOpacity(0.3)
          : context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? Colors.transparent
              : context.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Icon
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              color: notification.isRead
                                  ? context.colorScheme.onSurface.withOpacity(0.7)
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: notification.isRead
                            ? context.colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(notification.createdAt, isArabic),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions (Mark Read option for unread)
              if (!notification.isRead)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  tooltip: isArabic ? 'تحديد كمقروء' : 'Mark as read',
                  onPressed: onMarkRead,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt, bool isAr) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return isAr ? 'الآن' : 'Just now';
    } else if (diff.inMinutes < 60) {
      return isAr ? 'قبل ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return isAr ? 'قبل ${diff.inHours} ساعة' : '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
