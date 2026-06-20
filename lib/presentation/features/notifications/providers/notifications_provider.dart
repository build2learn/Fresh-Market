import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/data/providers/notification_repository_provider.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value(<NotificationEntity>[]);
  }
  
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchNotifications(user.id);
});

class NotificationsActions {
  final Ref _ref;
  NotificationsActions(this._ref);

  Future<void> markAsRead(String id) async {
    final repository = _ref.read(notificationRepositoryProvider);
    await repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final user = _ref.read(currentUserProvider);
    if (user != null) {
      final repository = _ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(user.id);
    }
  }
}

final notificationsActionsProvider = Provider.autoDispose<NotificationsActions>((ref) {
  return NotificationsActions(ref);
});

final unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
