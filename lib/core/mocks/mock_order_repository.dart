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
import 'package:fresh_market/core/mocks/mock_auth_repository.dart';
import 'package:fresh_market/core/mocks/mock_coupon_repository.dart';

class MockOrderRepository implements OrderRepository {
  static const String ordersKey = 'mock_orders';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<OrderEntity>>.broadcast();

  MockOrderRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(ordersKey) ?? [];
    if (list.isEmpty) {
      final now = DateTime.now();
      final seedOrders = [
        {
          'id': 'order_1',
          'userId': 'customer_user',
          'userEmail': 'customer@freshmarket.com',
          'status': 'Pending',
          'totalAmount': 105.0,
          'createdAt': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'items': [
            {
              'productId': 'prod_minced_meat',
              'productNameAr': 'لحمة مفرومة',
              'productNameEn': 'Minced Meat',
              'price': 60.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1588168333986-5078647ac9ab?w=500',
              'weight': 400.0,
              'weightUnitId': 'gram',
            },
            {
              'productId': 'prod_frozen_burger',
              'productNameAr': 'برجر مجمد',
              'productNameEn': 'Frozen Burger',
              'price': 45.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
              'weight': 400.0,
              'weightUnitId': 'gram',
            }
          ],
        },
        {
          'id': 'order_2',
          'userId': 'customer_user',
          'userEmail': 'customer@freshmarket.com',
          'status': 'Delivered',
          'totalAmount': 500.0,
          'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'items': [
            {
              'productId': 'prod_meat_box',
              'productNameAr': 'صندوق لحوم',
              'productNameEn': 'Meat Box',
              'price': 500.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
              'weight': 1.0,
              'weightUnitId': 'box',
            }
          ],
        }
      ];
      _prefs.setStringList(ordersKey, seedOrders.map((e) => jsonEncode(e)).toList());
    }
  }

  List<OrderDto> _getOrders() {
    final list = _prefs.getStringList(ordersKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return OrderDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<OrderDto> list) {
    _prefs.setStringList(ordersKey, list.map((e) => mockEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => OrderModel.fromDto(dto)).toList());
  }

  @override
  Future<Result<List<OrderEntity>>> getOrders({
    String? userId,
    String? status,
    String? searchQuery,
  }) async {
    var all = _getOrders();
    if (userId != null && userId.isNotEmpty) {
      all = all.where((o) => o.userId == userId).toList();
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      all = all.where((o) => o.status == status).toList();
    }
    var entities = all.map((dto) => OrderModel.fromDto(dto)).toList();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      entities = entities.where((o) =>
          o.id.toLowerCase().contains(query) ||
          o.orderNumber.toLowerCase().contains(query) ||
          o.customerName.toLowerCase().contains(query) ||
          o.phone.toLowerCase().contains(query) ||
          o.address.toLowerCase().contains(query) ||
          o.userEmail.toLowerCase().contains(query)).toList();
    }
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(entities);
  }

  @override
  Stream<List<OrderEntity>> watchOrders({
    String? userId,
    String? status,
    String? searchQuery,
  }) {
    Timer.run(() {
      var all = _getOrders();
      if (userId != null && userId.isNotEmpty) {
        all = all.where((o) => o.userId == userId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        all = all.where((o) => o.status == status).toList();
      }
      var entities = all.map((dto) => OrderModel.fromDto(dto)).toList();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        entities = entities.where((o) =>
            o.id.toLowerCase().contains(query) ||
            o.orderNumber.toLowerCase().contains(query) ||
            o.customerName.toLowerCase().contains(query) ||
            o.phone.toLowerCase().contains(query) ||
            o.address.toLowerCase().contains(query) ||
            o.userEmail.toLowerCase().contains(query)).toList();
      }
      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _controller.add(entities);
    });

    return _controller.stream.map((list) {
      var filtered = list;
      if (userId != null && userId.isNotEmpty) {
        filtered = filtered.where((o) => o.userId == userId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        filtered = filtered.where((o) => o.status == status).toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered.where((o) =>
            o.id.toLowerCase().contains(query) ||
            o.orderNumber.toLowerCase().contains(query) ||
            o.customerName.toLowerCase().contains(query) ||
            o.phone.toLowerCase().contains(query) ||
            o.address.toLowerCase().contains(query) ||
            o.userEmail.toLowerCase().contains(query)).toList();
      }
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  @override
  Stream<OrderEntity?> watchOrder(String orderId) {
    return watchOrders().map((list) {
      try {
        return list.firstWhere((o) => o.id == orderId);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<Result<OrderEntity>> createOrder(OrderEntity order) async {
    final all = _getOrders();
    final newId = order.id.isEmpty ? 'order_${DateTime.now().millisecondsSinceEpoch}' : order.id;
    final generatedNum = order.orderNumber.isEmpty 
        ? 'ORD-${DateTime.now().millisecondsSinceEpoch}' 
        : order.orderNumber;

    // Reserve stock from batches using FIFO
    final batchAllocations = <String, Map<String, int>>{};
    try {
      final batchListStr = _prefs.getStringList('mock_batches') ?? [];
      final allBatches = batchListStr.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();

      for (final orderItem in order.items) {
        final pid = orderItem.productId;
        int qtyRemaining = orderItem.quantity;
        final itemAllocations = <String, int>{};

        // Filter batches for this product that are not expired
        final productBatches = allBatches.where((b) {
          final isSameProduct = b['productId'] == pid;
          if (!isSameProduct) return false;
          final expStr = b['expiryDate'] as String? ?? '';
          if (expStr.isEmpty) return true;
          try {
            final exp = DateTime.parse(expStr);
            return exp.isAfter(DateTime.now());
          } catch (_) {
            return true;
          }
        }).toList();

        // Sort by expiryDate ascending (FIFO)
        productBatches.sort((a, b) {
          final expA = DateTime.tryParse(a['expiryDate'] as String? ?? '') ?? DateTime.now();
          final expB = DateTime.tryParse(b['expiryDate'] as String? ?? '') ?? DateTime.now();
          return expA.compareTo(expB);
        });

        for (final batch in productBatches) {
          if (qtyRemaining <= 0) break;
          final avQty = batch['availableQuantity'] as int? ?? 0;
          if (avQty <= 0) continue;

          final deduct = qtyRemaining < avQty ? qtyRemaining : avQty;
          batch['availableQuantity'] = avQty - deduct;
          batch['reservedQuantity'] = (batch['reservedQuantity'] as int? ?? 0) + deduct;
          batch['updatedAt'] = DateTime.now().toIso8601String();

          itemAllocations[batch['id'] as String] = deduct;
          qtyRemaining -= deduct;
        }

        if (itemAllocations.isNotEmpty) {
          batchAllocations[pid] = itemAllocations;
        }
      }

      // Save updated batches back to preferences
      _prefs.setStringList('mock_batches', allBatches.map((b) => jsonEncode(b)).toList());
    } catch (e) {
      debugPrint('[MOCK ORDER BATCH FIFO] Error reserving batch stock: $e');
    }

    final finalOrder = order.copyWith(
      id: newId,
      orderNumber: generatedNum,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      batchAllocations: batchAllocations,
    );
    final dto = OrderModel.fromEntity(finalOrder);
    all.add(dto);
    _saveAll(all);

    // Increment coupon usedCount if applicable
    if (order.couponCode != null && order.couponCode!.isNotEmpty) {
      try {
        final couponListStr = _prefs.getStringList(MockCouponRepository.couponsKey) ?? [];
        final couponIdx = couponListStr.indexWhere((cStr) {
          final decoded = jsonDecode(cStr) as Map;
          return (decoded['code'] as String).trim().toUpperCase() == order.couponCode!.trim().toUpperCase();
        });
        if (couponIdx != -1) {
          final couponMap = Map<String, dynamic>.from(jsonDecode(couponListStr[couponIdx]) as Map);
          int usedCount = couponMap['usedCount'] as int? ?? 0;
          couponMap['usedCount'] = usedCount + 1;
          couponListStr[couponIdx] = jsonEncode(couponMap);
          _prefs.setStringList(MockCouponRepository.couponsKey, couponListStr);
        }
      } catch (e) {
        debugPrint('[MOCK ORDER REPO] Failed to increment coupon count: $e');
      }
    }

    // Adjust loyalty points for the user
    try {
      final userListStr = _prefs.getStringList(MockAuthRepository.usersKey) ?? [];
      final userIdx = userListStr.indexWhere((uStr) {
        final decoded = jsonDecode(uStr) as Map;
        return decoded['id'] == order.userId;
      });
      if (userIdx != -1) {
        final userMap = Map<String, dynamic>.from(jsonDecode(userListStr[userIdx]) as Map);
        int loyaltyPoints = userMap['loyaltyPoints'] as int? ?? 0;
        int lifetimePoints = userMap['lifetimePoints'] as int? ?? 0;
        
        // 1. Subtract redeemed points
        if (order.loyaltyPointsRedeemed != null && order.loyaltyPointsRedeemed! > 0) {
          loyaltyPoints -= order.loyaltyPointsRedeemed!;
        }
        
        // 2. Add earned points
        if (order.loyaltyPointsEarned != null && order.loyaltyPointsEarned! > 0) {
          loyaltyPoints += order.loyaltyPointsEarned!;
          lifetimePoints += order.loyaltyPointsEarned!;
        }
        
        // 3. Re-evaluate membership level
        String level = 'Bronze';
        if (lifetimePoints >= 5000) {
          level = 'Platinum';
        } else if (lifetimePoints >= 1500) {
          level = 'Gold';
        } else if (lifetimePoints >= 500) {
          level = 'Silver';
        }
        
        userMap['loyaltyPoints'] = loyaltyPoints;
        userMap['lifetimePoints'] = lifetimePoints;
        userMap['membershipLevel'] = level;
        userMap['updatedAt'] = DateTime.now().toIso8601String();
        
        userListStr[userIdx] = jsonEncode(userMap);
        _prefs.setStringList(MockAuthRepository.usersKey, userListStr);
        debugPrint('[MOCK LOYALTY] Updated user points: balance=$loyaltyPoints, lifetime=$lifetimePoints, tier=$level');
      }
    } catch (e) {
      debugPrint('[MOCK LOYALTY] Error updating points: $e');
    }

    // Reserve stock for each item in the order
    try {
      final prodListStr = _prefs.getStringList('mock_products') ?? [];
      final updatedProds = prodListStr.map((itemStr) {
        final map = jsonDecode(itemStr) as Map<String, dynamic>;
        final pid = map['id'] as String;
        
        final orderItem = order.items.cast<OrderItemEntity?>().firstWhere((oi) => oi?.productId == pid, orElse: () => null);
        if (orderItem != null) {
          final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 50;
          final res = map['reservedStock'] as int? ?? 0;
          final av = map['availableStock'] as int? ?? map['stockQuantity'] as int? ?? (cur - res);
          
          final newAv = (av - orderItem.quantity).clamp(0, 999999);
          final newRes = res + orderItem.quantity;
          
          map['availableStock'] = newAv;
          map['reservedStock'] = newRes;
          map['stockQuantity'] = newAv; // sync legacy stockQuantity
          
          mockLogStockHistory(
            prefs: _prefs,
            productId: pid,
            productNameAr: map['nameAr'] as String? ?? orderItem.productNameAr,
            productNameEn: map['nameEn'] as String? ?? orderItem.productNameEn,
            type: 'order_created',
            quantityChanged: -orderItem.quantity,
            previousStock: av,
            newStock: newAv,
            reasonAr: 'تم حجز المخزون لطلب جديد رقم ${finalOrder.orderNumber}',
            reasonEn: 'Stock reserved for new order #${finalOrder.orderNumber}',
            createdBy: order.customerId,
          );

          final alertQty = map['reorderLevel'] as int? ?? map['alertQuantity'] as int? ?? 10;
          final nameAr = map['nameAr'] as String? ?? '';
          final nameEn = map['nameEn'] as String? ?? '';
          
          if (newAv == 0) {
            NotificationService.instance.simulateNotification(
              title: 'Out of Stock Alert / تنبيه نفاد المخزون',
              body: 'Product ${nameEn} is out of stock! / المنتج ${nameAr} نفد من المخزون!',
              data: {
                'type': 'system',
                'titleAr': 'تنبيه نفاد المخزون',
                'bodyAr': 'المنتج ${nameAr} نفد من المخزون تماماً!',
                'titleEn': 'Out of Stock Alert',
                'bodyEn': 'Product ${nameEn} is out of stock!',
              },
            );
          } else if (newAv <= alertQty) {
            NotificationService.instance.simulateNotification(
              title: 'Low Stock Alert / تنبيه انخفاض المخزون',
              body: 'Product ${nameEn} is running low (${newAv} remaining). / المنتج ${nameAr} يقترب من النفاد (${newAv} متبقي).',
              data: {
                'type': 'system',
                'titleAr': 'تنبيه انخفاض المخزون',
                'bodyAr': 'المنتج ${nameAr} يقترب من النفاد (${newAv} متبقي).',
                'titleEn': 'Low Stock Alert',
                'bodyEn': 'Product ${nameEn} is running low (${newAv} remaining).',
              },
            );
          }
        }
        return jsonEncode(map);
      }).toList();
      _prefs.setStringList('mock_products', updatedProds);
    } catch (_) {}

    // Simulate notification when order is created
    NotificationService.instance.simulateNotification(
      title: 'Order Placed! / تم تقديم الطلب!',
      body: 'Your order #${newId} is being processed. / طلبك رقم #${newId} قيد المعالجة الآن.',
      data: {
        'type': 'order',
        'orderId': newId,
        'titleAr': 'تم تقديم الطلب!',
        'bodyAr': 'طلبك رقم #${newId} قيد المعالجة الآن.',
        'titleEn': 'Order Placed!',
        'bodyEn': 'Your order #${newId} is being processed.',
      },
    );

    return Success(finalOrder);
  }

  @override
  Future<Result<void>> updateOrderStatus(String orderId, String status) async {
    final all = _getOrders();
    final idx = all.indexWhere((o) => o.id == orderId);
    if (idx == -1) return Failure(FirestoreException(message: 'Order not found'));
    final old = all[idx];
    final oldStatus = old.status;

    if (oldStatus == status) {
      return const Success(null);
    }

    final updated = OrderDto(
      id: old.id,
      orderNumber: old.orderNumber,
      customerId: old.customerId,
      customerName: old.customerName,
      phone: old.phone,
      address: old.address,
      subtotal: old.subtotal,
      deliveryFee: old.deliveryFee,
      total: old.total,
      status: status,
      createdAt: old.createdAt,
      userId: old.userId,
      userEmail: old.userEmail,
      totalAmount: old.totalAmount,
      updatedAt: DateTime.now(),
      items: old.items,
      shippingAddress: old.shippingAddress,
      couponCode: old.couponCode,
      discountAmount: old.discountAmount,
      loyaltyPointsEarned: old.loyaltyPointsEarned,
      loyaltyPointsRedeemed: old.loyaltyPointsRedeemed,
      loyaltyDiscount: old.loyaltyDiscount,
    );
    all[idx] = updated;
    _saveAll(all);

    // Stock allocation rules on transitions
    final isOldStatusReserving = (oldStatus == 'Pending' || oldStatus == 'Confirmed' || oldStatus == 'Preparing' || oldStatus == 'OutForDelivery');

    if (status == 'Cancelled' && isOldStatusReserving) {
      try {
        final prodListStr = _prefs.getStringList('mock_products') ?? [];
        final updatedProds = prodListStr.map((itemStr) {
          final map = jsonDecode(itemStr) as Map<String, dynamic>;
          final pid = map['id'] as String;
          
          final orderItems = old.items.where((oi) => oi.productId == pid).toList();
          if (orderItems.isNotEmpty) {
            final orderItem = orderItems.first;
            final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 50;
            final res = map['reservedStock'] as int? ?? 0;
            final av = map['availableStock'] as int? ?? map['stockQuantity'] as int? ?? (cur - res);
            
            final newAv = av + orderItem.quantity;
            final newRes = (res - orderItem.quantity).clamp(0, 999999);
            
            map['availableStock'] = newAv;
            map['reservedStock'] = newRes;
            map['stockQuantity'] = newAv; // sync legacy stockQuantity
            
            mockLogStockHistory(
              prefs: _prefs,
              productId: pid,
              productNameAr: map['nameAr'] as String? ?? orderItem.productNameAr,
              productNameEn: map['nameEn'] as String? ?? orderItem.productNameEn,
              type: 'order_cancelled',
              quantityChanged: orderItem.quantity,
              previousStock: av,
              newStock: newAv,
              reasonAr: 'تم إرجاع المخزون لإلغاء الطلب رقم ${old.orderNumber}',
              reasonEn: 'Stock restored due to cancellation of order #${old.orderNumber}',
              createdBy: old.customerId,
            );
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_products', updatedProds);
      } catch (_) {}

      // Restore allocated batch stock on Cancellation
      try {
        if (old.batchAllocations != null && old.batchAllocations!.isNotEmpty) {
          final batchListStr = _prefs.getStringList('mock_batches') ?? [];
          final allBatches = batchListStr.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();

          old.batchAllocations!.forEach((productId, allocations) {
            allocations.forEach((batchId, qty) {
              final batchIdx = allBatches.indexWhere((b) => b['id'] == batchId);
              if (batchIdx != -1) {
                final b = allBatches[batchIdx];
                final av = b['availableQuantity'] as int? ?? 0;
                final res = b['reservedQuantity'] as int? ?? 0;
                b['availableQuantity'] = av + qty;
                b['reservedQuantity'] = (res - qty).clamp(0, 999999);
                b['updatedAt'] = DateTime.now().toIso8601String();
              }
            });
          });
          _prefs.setStringList('mock_batches', allBatches.map((b) => jsonEncode(b)).toList());
        }
      } catch (e) {
        debugPrint('[MOCK BATCH CANCEL] Error restoring batch stock: $e');
      }
    } else if (status == 'Delivered' && isOldStatusReserving) {
      try {
        final prodListStr = _prefs.getStringList('mock_products') ?? [];
        final updatedProds = prodListStr.map((itemStr) {
          final map = jsonDecode(itemStr) as Map<String, dynamic>;
          final pid = map['id'] as String;
          
          final orderItems = old.items.where((oi) => oi.productId == pid).toList();
          if (orderItems.isNotEmpty) {
            final orderItem = orderItems.first;
            final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 50;
            final res = map['reservedStock'] as int? ?? 0;
            
            final newCur = (cur - orderItem.quantity).clamp(0, 999999);
            final newRes = (res - orderItem.quantity).clamp(0, 999999);
            
            map['currentStock'] = newCur;
            map['reservedStock'] = newRes;
            
            mockLogStockHistory(
              prefs: _prefs,
              productId: pid,
              productNameAr: map['nameAr'] as String? ?? orderItem.productNameAr,
              productNameEn: map['nameEn'] as String? ?? orderItem.productNameEn,
              type: 'fulfillment',
              quantityChanged: -orderItem.quantity,
              previousStock: cur,
              newStock: newCur,
              reasonAr: 'تم تسليم المنتجات وتعديل المخزون الفعلي للطلب رقم ${old.orderNumber}',
              reasonEn: 'Physical stock decremented upon delivery of order #${old.orderNumber}',
              createdBy: 'system',
            );
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_products', updatedProds);
      } catch (_) {}

      // Finalize batch stock deduction on Delivery
      try {
        if (old.batchAllocations != null && old.batchAllocations!.isNotEmpty) {
          final batchListStr = _prefs.getStringList('mock_batches') ?? [];
          final allBatches = batchListStr.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();

          old.batchAllocations!.forEach((productId, allocations) {
            allocations.forEach((batchId, qty) {
              final batchIdx = allBatches.indexWhere((b) => b['id'] == batchId);
              if (batchIdx != -1) {
                final b = allBatches[batchIdx];
                final cur = b['currentQuantity'] as int? ?? 0;
                final res = b['reservedQuantity'] as int? ?? 0;
                b['currentQuantity'] = (cur - qty).clamp(0, 999999);
                b['reservedQuantity'] = (res - qty).clamp(0, 999999);
                b['updatedAt'] = DateTime.now().toIso8601String();
              }
            });
          });
          _prefs.setStringList('mock_batches', allBatches.map((b) => jsonEncode(b)).toList());
        }
      } catch (e) {
        debugPrint('[MOCK BATCH DELIVER] Error deducting actual batch stock: $e');
      }
    }

    // Localized status names for notifications
    final statusAr = _getStatusAr(status);
    final statusEn = status;

    NotificationService.instance.simulateNotification(
      title: 'Order Status Updated / تحديث حالة الطلب',
      body: 'Order #${orderId} is now ${statusEn}. / حالة الطلب #${orderId} أصبحت ${statusAr}.',
      data: {
        'type': 'order',
        'orderId': orderId,
        'titleAr': 'تحديث حالة الطلب',
        'bodyAr': 'حالة الطلب #${orderId} أصبحت ${statusAr}.',
        'titleEn': 'Order Status Updated',
        'bodyEn': 'Order #${orderId} is now ${statusEn}.',
      },
    );

    return const Success(null);
  }

  String _getStatusAr(String status) {
    switch (status) {
      case 'Pending': return 'قيد الانتظار';
      case 'Confirmed': return 'تم التأكيد';
      case 'Preparing': return 'قيد التجهيز';
      case 'OutForDelivery': return 'خارج للتوصيل';
      case 'Delivered': return 'تم التوصيل';
      case 'Cancelled': return 'ملغي';
      default: return status;
    }
  }
}
