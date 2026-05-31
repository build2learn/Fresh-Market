import 'dart:async';
import '../entities/notification.entity.dart';
import '../../core/utils/result.dart';

abstract interface class NotificationRepository {
  Future<Result<List<NotificationEntity>>> getNotifications(String userId, {int limit = 50});
  Stream<List<NotificationEntity>> watchNotifications(String userId);
  Future<Result<void>> markAsRead(String notificationId);
  Future<Result<void>> markAllAsRead(String userId);
}
