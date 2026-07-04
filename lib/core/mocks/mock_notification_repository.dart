import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/enums/user_role.dart';
import 'package:fresh_market/core/enums/setting_type.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/entities/setting.entity.dart';
import 'package:fresh_market/domain/entities/coupon.entity.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/repositories/auth_repository.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';
import 'package:fresh_market/domain/repositories/offer_repository.dart';
import 'package:fresh_market/domain/repositories/weight_unit_repository.dart';
import 'package:fresh_market/domain/repositories/settings_repository.dart';
import 'package:fresh_market/domain/repositories/user_repository.dart';
import 'package:fresh_market/domain/repositories/notification_repository.dart';
import 'package:fresh_market/domain/repositories/coupon_repository.dart';
import 'package:fresh_market/domain/repositories/audit_log_repository.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import 'package:fresh_market/data/dto/user.dto.dart';
import 'package:fresh_market/data/models/user_model.dart';
import 'package:fresh_market/data/dto/category.dto.dart';
import 'package:fresh_market/data/models/category_model.dart';
import 'package:fresh_market/data/dto/product.dto.dart';
import 'package:fresh_market/data/models/product_model.dart';
import 'package:fresh_market/data/dto/offer.dto.dart';
import 'package:fresh_market/data/models/offer_model.dart';
import 'package:fresh_market/data/dto/weight_unit.dto.dart';
import 'package:fresh_market/data/models/weight_unit_model.dart';
import 'package:fresh_market/data/dto/coupon.dto.dart';
import 'package:fresh_market/data/models/coupon_model.dart';
import 'package:fresh_market/data/dto/audit_log.dto.dart';
import 'package:fresh_market/data/models/audit_log_model.dart';
import 'package:fresh_market/domain/entities/lookup.entity.dart';
import 'package:fresh_market/domain/repositories/lookup_repository.dart';
import 'package:fresh_market/data/dto/lookup.dto.dart';
import 'package:fresh_market/data/models/lookup_model.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/repositories/order_repository.dart';
import 'package:fresh_market/data/dto/order.dto.dart';
import 'package:fresh_market/data/models/order_model.dart';
import 'package:fresh_market/domain/entities/address.entity.dart';
import 'package:fresh_market/domain/repositories/address_repository.dart';
import 'package:fresh_market/data/dto/address.dto.dart';
import 'package:fresh_market/data/models/address_model.dart';
import 'package:fresh_market/domain/entities/supplier.entity.dart';
import 'package:fresh_market/domain/repositories/supplier_repository.dart';
import 'package:fresh_market/data/dto/supplier.dto.dart';
import 'package:fresh_market/data/models/supplier_model.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/repositories/purchase_order_repository.dart';
import 'package:fresh_market/data/dto/purchase_order.dto.dart';
import 'package:fresh_market/data/models/purchase_order_model.dart';
import 'package:fresh_market/domain/entities/stock_history.entity.dart';
import 'package:fresh_market/domain/repositories/stock_history_repository.dart';
import 'package:fresh_market/data/dto/stock_history.dto.dart';
import 'package:fresh_market/domain/entities/supplier_payment.entity.dart';
import 'package:fresh_market/domain/repositories/supplier_payment_repository.dart';
import 'package:fresh_market/data/dto/supplier_payment.dto.dart';
import 'package:fresh_market/data/models/supplier_payment_model.dart';
import 'package:fresh_market/domain/entities/batch.entity.dart';
import 'package:fresh_market/domain/repositories/batch_repository.dart';
import 'package:fresh_market/data/dto/batch.dto.dart';
import 'package:fresh_market/data/models/batch_model.dart';
import 'package:fresh_market/domain/entities/expense.entity.dart';
import 'package:fresh_market/domain/repositories/expense_repository.dart';
import 'package:fresh_market/data/dto/expense.dto.dart';
import 'package:fresh_market/data/models/expense_model.dart';
import 'package:fresh_market/domain/entities/warehouse.entity.dart';
import 'package:fresh_market/domain/entities/warehouse_inventory.entity.dart';
import 'package:fresh_market/domain/entities/stock_transfer.entity.dart';
import 'package:fresh_market/domain/repositories/warehouse_repository.dart';
import 'package:fresh_market/data/dto/warehouse.dto.dart';
import 'package:fresh_market/data/dto/warehouse_inventory.dto.dart';
import 'package:fresh_market/data/dto/stock_transfer.dto.dart';
import 'package:fresh_market/data/models/warehouse_model.dart';
import 'package:fresh_market/data/models/warehouse_inventory_model.dart';
import 'package:fresh_market/data/models/stock_transfer_model.dart';
import 'package:fresh_market/core/mocks/mock_helpers.dart';
import 'package:fresh_market/core/services/notification_service.dart';

class MockNotificationRepository implements NotificationRepository {
  static const String _notificationsKey = 'mock_notifications';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<NotificationEntity>>.broadcast();

  MockNotificationRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_notificationsKey) ?? [];
    if (list.isEmpty) {
      final testNotification = {
        'id': 'notif_welcome',
        'userId': 'customer_user',
        'title': 'Welcome to Fresh Market! / أهلاً بك في فريش ماركت!',
        'body': 'Enjoy our fresh meat and offers. / استمتع باللحوم الطازجة والعروض.',
        'type': 'system',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _prefs.setStringList(_notificationsKey, [jsonEncode(testNotification)]);
    }
  }

  List<Map<String, dynamic>> _getNotificationsRaw() {
    final list = _prefs.getStringList(_notificationsKey) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  void _saveAll(List<Map<String, dynamic>> list) {
    _prefs.setStringList(_notificationsKey, list.map((e) => jsonEncode(e)).toList());
    _emit(list);
  }

  void _emit(List<Map<String, dynamic>> list) {
    final entities = list.map((m) => _mapToEntity(m)).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _controller.add(entities);
  }

  NotificationEntity _mapToEntity(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.fromString(map['type'] as String? ?? 'system'),
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotifications(String userId, {int limit = 50}) async {
    final all = _getNotificationsRaw().where((n) => n['userId'] == userId || n['userId'] == 'all').toList();
    final entities = all.map((m) => _mapToEntity(m)).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(entities.take(limit).toList());
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    Timer.run(() {
      final all = _getNotificationsRaw().where((n) => n['userId'] == userId || n['userId'] == 'all').toList();
      _emit(all);
    });
    return _controller.stream.map((list) => list.where((n) => n.userId == userId || n.userId == 'all').toList());
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    final all = _getNotificationsRaw();
    final idx = all.indexWhere((n) => n['id'] == notificationId);
    if (idx != -1) {
      all[idx]['isRead'] = true;
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllAsRead(String userId) async {
    final all = _getNotificationsRaw();
    for (var i = 0; i < all.length; i++) {
      if (all[i]['userId'] == userId || all[i]['userId'] == 'all') {
        all[i]['isRead'] = true;
      }
    }
    _saveAll(all);
    return const Success(null);
  }

  @override
  Future<Result<NotificationEntity>> createNotification(NotificationEntity notification) async {
    final all = _getNotificationsRaw();
    final newId = notification.id.isEmpty ? 'notif_${DateTime.now().millisecondsSinceEpoch}' : notification.id;
    final map = {
      'id': newId,
      'userId': notification.userId,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.value,
      'isRead': notification.isRead,
      'createdAt': DateTime.now().toIso8601String(),
      if (notification.data != null) 'data': notification.data,
    };
    all.add(map);
    _saveAll(all);

    // Trigger local simulation so foreground listener can intercept it!
    NotificationService.instance.simulateNotification(
      title: notification.title,
      body: notification.body,
      data: notification.data,
    );

    return Success(_mapToEntity(map));
  }
}
