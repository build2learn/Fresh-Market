import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/enums/user_role.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/order.entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../dto/order.dto.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  CollectionReference get _ordersCol => _firestore.collection(FirestoreConstants.orders);
  CollectionReference get _orderItemsCol => _firestore.collection(FirestoreConstants.orderItems);

  @override
  Future<Result<List<OrderEntity>>> getOrders({
    String? userId,
    String? status,
    String? searchQuery,
  }) async {
    try {
      Query query = _ordersCol.orderBy(FirestoreConstants.createdAt, descending: true);

      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      List<OrderEntity> list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromDto(OrderDto.fromMap(data, doc.id));
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        list = list.where((o) =>
            o.id.toLowerCase().contains(lowerQuery) ||
            o.orderNumber.toLowerCase().contains(lowerQuery) ||
            o.customerName.toLowerCase().contains(lowerQuery) ||
            o.phone.toLowerCase().contains(lowerQuery) ||
            o.address.toLowerCase().contains(lowerQuery) ||
            o.userEmail.toLowerCase().contains(lowerQuery)).toList();
      }

      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<OrderEntity>> watchOrders({
    String? userId,
    String? status,
    String? searchQuery,
  }) {
    Query query = _ordersCol.orderBy(FirestoreConstants.createdAt, descending: true);

    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snapshot) {
      List<OrderEntity> list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromDto(OrderDto.fromMap(data, doc.id));
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        list = list.where((o) =>
            o.id.toLowerCase().contains(lowerQuery) ||
            o.orderNumber.toLowerCase().contains(lowerQuery) ||
            o.customerName.toLowerCase().contains(lowerQuery) ||
            o.phone.toLowerCase().contains(lowerQuery) ||
            o.address.toLowerCase().contains(lowerQuery) ||
            o.userEmail.toLowerCase().contains(lowerQuery)).toList();
      }

      return list;
    });
  }

  @override
  Stream<OrderEntity?> watchOrder(String orderId) {
    return _ordersCol.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return OrderModel.fromDto(OrderDto.fromMap(data, doc.id));
    });
  }

  @override
  Future<Result<OrderEntity>> createOrder(OrderEntity order) async {
    try {
      final docRef = order.id.isEmpty ? _ordersCol.doc() : _ordersCol.doc(order.id);
      
      final generatedNum = order.orderNumber.isEmpty 
          ? 'ORD-${DateTime.now().millisecondsSinceEpoch}' 
          : order.orderNumber;

      // 1. Resolve coupon doc reference outside the transaction
      DocumentReference? couponDocRef;
      if (order.couponCode != null && order.couponCode!.trim().isNotEmpty) {
        final couponSnapshot = await _firestore.collection('coupons')
            .where('code', isEqualTo: order.couponCode!.trim().toUpperCase())
            .limit(1)
            .get();
        if (couponSnapshot.docs.isNotEmpty) {
          couponDocRef = couponSnapshot.docs.first.reference;
        }
      }

      final userDocRef = _firestore.collection('users').doc(order.customerId);

      // 2. Perform checkout inside transaction
      final finalOrder = await _firestore.runTransaction<OrderEntity>((transaction) async {
        // Read Phase
        final userGet = transaction.get(userDocRef);
        final couponGet = couponDocRef != null ? transaction.get(couponDocRef) : Future.value(null);
        final productGets = order.items.map((item) {
          return transaction.get(_firestore.collection(FirestoreConstants.products).doc(item.productId));
        }).toList();

        final userSnapshot = await userGet;
        final couponSnapshot = await couponGet;
        final productSnapshots = await Future.wait(productGets);

        // Map product data
        final productMap = <String, Map<String, dynamic>>{};
        for (var i = 0; i < order.items.length; i++) {
          final snapshot = productSnapshots[i];
          if (!snapshot.exists) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Product ${order.items[i].productId} not found',
            );
          }
          productMap[snapshot.id] = snapshot.data() as Map<String, dynamic>;
        }

        // Validate stock and recalculate subtotal
        double recalculatedSubtotal = 0.0;
        final verifiedItems = <OrderItemEntity>[];
        for (final item in order.items) {
          final pData = productMap[item.productId]!;
          final isAvail = pData['isAvailable'] as bool? ?? true;
          final pStatus = pData['status'] as String? ?? 'Active';
          if (!isAvail || pStatus != 'Active') {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Product ${item.productName} is currently unavailable',
            );
          }

          final cur = pData['currentStock'] as int? ?? pData['stockQuantity'] as int? ?? 0;
          final res = pData['reservedStock'] as int? ?? 0;
          final stock = pData['availableStock'] as int? ?? pData['stockQuantity'] as int? ?? (cur - res);
          if (stock < item.quantity) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Insufficient stock for product ${item.productName}',
            );
          }

          final price = (pData['price'] as num?)?.toDouble() ?? 0.0;
          final itemTotal = price * item.quantity;
          recalculatedSubtotal += itemTotal;
          verifiedItems.add(item.copyWith(
            unitPrice: price,
            totalPrice: itemTotal,
            price: price,
          ));
        }

        // Validate coupon
        double verifiedDiscountAmount = 0.0;
        if (couponSnapshot != null && couponSnapshot.exists) {
          final cData = couponSnapshot.data() as Map<String, dynamic>;
          final isActive = cData['isActive'] as bool? ?? true;
          final expiryVal = cData['expiryDate'];
          DateTime? expiryDate;
          if (expiryVal != null) {
            if (expiryVal is Timestamp) {
              expiryDate = expiryVal.toDate();
            } else if (expiryVal is String) {
              expiryDate = DateTime.tryParse(expiryVal);
            }
          }
          final usageLimit = cData['usageLimit'] as int?;
          final usedCount = cData['usedCount'] as int? ?? 0;
          final minOrderAmount = (cData['minOrderAmount'] as num?)?.toDouble() ?? 0.0;
          final discountValue = (cData['discountValue'] as num?)?.toDouble() ?? 0.0;
          final couponType = cData['type'] as String? ?? 'Fixed';

          final isExpired = expiryDate != null && expiryDate.isBefore(DateTime.now());
          final limitReached = usageLimit != null && usedCount >= usageLimit;

          if (isActive && !isExpired && !limitReached && recalculatedSubtotal >= minOrderAmount) {
            if (couponType == 'Percentage') {
              verifiedDiscountAmount = recalculatedSubtotal * (discountValue / 100.0);
            } else {
              verifiedDiscountAmount = discountValue;
            }
            verifiedDiscountAmount = verifiedDiscountAmount.clamp(0.0, recalculatedSubtotal);
          }
        }

        // Validate user points and calculate loyalty
        int userPoints = 0;
        int lifetimePoints = 0;
        String membershipLevel = 'Bronze';
        if (userSnapshot.exists) {
          final uData = userSnapshot.data() as Map<String, dynamic>;
          userPoints = uData['loyaltyPoints'] as int? ?? 0;
          lifetimePoints = uData['lifetimePoints'] as int? ?? 0;
          membershipLevel = uData['membershipLevel'] as String? ?? 'Bronze';
        }

        int verifiedPointsToRedeem = 0;
        double verifiedLoyaltyDiscount = 0.0;
        if (order.loyaltyPointsRedeemed != null && order.loyaltyPointsRedeemed! > 0) {
          final remainingBeforeLoyalty = recalculatedSubtotal + 15.0 - verifiedDiscountAmount;
          final pointsNeeded = (remainingBeforeLoyalty * 10).ceil();
          verifiedPointsToRedeem = pointsNeeded.clamp(0, userPoints);
          verifiedLoyaltyDiscount = verifiedPointsToRedeem / 10.0;
        }

        const deliveryFee = 15.0;
        final verifiedGrandTotal = (recalculatedSubtotal + deliveryFee - verifiedDiscountAmount - verifiedLoyaltyDiscount).clamp(0.0, 999999.0);
        final verifiedPointsEarned = (verifiedGrandTotal / 10.0).floor();

        // FIFO Batch Allocation: Read batches for each product and allocate from oldest expiry first
        final batchAllocations = <String, Map<String, int>>{};
        for (final item in verifiedItems) {
          final batchQuery = await _firestore
              .collection('batches')
              .where('productId', isEqualTo: item.productId)
              .orderBy('expiryDate', descending: false)
              .get();

          if (batchQuery.docs.isNotEmpty) {
            var remainingQty = item.quantity;
            final itemAllocations = <String, int>{};
            final now = DateTime.now();

            for (final batchDoc in batchQuery.docs) {
              if (remainingQty <= 0) break;

              final batchData = batchDoc.data();
              final availableQty = batchData['availableQuantity'] as int? ?? 0;
              if (availableQty <= 0) continue;

              // Skip expired batches
              final expiryVal = batchData['expiryDate'];
              DateTime? expiryDate;
              if (expiryVal is Timestamp) {
                expiryDate = expiryVal.toDate();
              } else if (expiryVal is String) {
                expiryDate = DateTime.tryParse(expiryVal);
              }
              if (expiryDate != null && expiryDate.isBefore(now)) continue;

              final allocateQty = remainingQty > availableQty ? availableQty : remainingQty;
              itemAllocations[batchDoc.id] = allocateQty;

              // Update batch: decrement available, increment reserved
              transaction.update(batchDoc.reference, {
                'availableQuantity': FieldValue.increment(-allocateQty),
                'reservedQuantity': FieldValue.increment(allocateQty),
                FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
              });

              remainingQty -= allocateQty;
            }

            if (itemAllocations.isNotEmpty) {
              batchAllocations[item.productId] = itemAllocations;
            }
          }
        }

        final transactionalOrder = order.copyWith(
          id: docRef.id,
          orderNumber: generatedNum,
          subtotal: recalculatedSubtotal,
          discountAmount: verifiedDiscountAmount,
          loyaltyDiscount: verifiedLoyaltyDiscount,
          loyaltyPointsRedeemed: verifiedPointsToRedeem,
          loyaltyPointsEarned: verifiedPointsEarned,
          total: verifiedGrandTotal,
          totalAmount: verifiedGrandTotal,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: verifiedItems,
          batchAllocations: batchAllocations.isNotEmpty ? batchAllocations : null,
        );

        final dto = OrderModel.fromEntity(transactionalOrder);
        final orderData = dto.toMap();
        orderData[FirestoreConstants.createdAt] = FieldValue.serverTimestamp();
        orderData[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp();

        // Write Phase
        transaction.set(docRef, orderData);

        for (final item in dto.items) {
          final subDocRef = docRef.collection(FirestoreConstants.orderItems).doc();
          final topDocRef = _orderItemsCol.doc(subDocRef.id);

          final itemData = item.toMap();
          itemData['orderId'] = docRef.id;
          itemData[FirestoreConstants.createdAt] = FieldValue.serverTimestamp();

          transaction.set(subDocRef, itemData);
          transaction.set(topDocRef, itemData);

          // Update stock: decrement availableStock, increment reservedStock
          final productDocRef = _firestore.collection(FirestoreConstants.products).doc(item.productId);
          transaction.update(productDocRef, {
            'availableStock': FieldValue.increment(-item.quantity),
            'reservedStock': FieldValue.increment(item.quantity),
            'stockQuantity': FieldValue.increment(-item.quantity), // legacy sync
          });

          // Stock History Log
          final pData = productMap[item.productId]!;
          final nameAr = pData['nameAr'] as String? ?? item.productNameAr;
          final nameEn = pData['nameEn'] as String? ?? item.productNameEn;
          final curStock = pData['currentStock'] as int? ?? pData['stockQuantity'] as int? ?? 0;
          final resStock = pData['reservedStock'] as int? ?? 0;
          final avStock = pData['availableStock'] as int? ?? pData['stockQuantity'] as int? ?? (curStock - resStock);

          final historyDocRef = _firestore.collection('stock_history').doc();
          transaction.set(historyDocRef, {
            'id': historyDocRef.id,
            'productId': item.productId,
            'productNameAr': nameAr,
            'productNameEn': nameEn,
            'type': 'order_created',
            'quantityChanged': -item.quantity,
            'previousStock': avStock,
            'newStock': avStock - item.quantity,
            'reasonAr': 'تم حجز المخزون لطلب جديد رقم ${transactionalOrder.orderNumber}',
            'reasonEn': 'Stock reserved for new order #${transactionalOrder.orderNumber}',
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': order.customerId.isNotEmpty ? order.customerId : 'system',
          });
        }

        // Increment coupon count
        if (couponDocRef != null) {
          transaction.update(couponDocRef, {
            'usedCount': FieldValue.increment(1),
          });
        }

        // Update user loyalty points & membership level
        if (userSnapshot.exists) {
          final newLoyaltyPoints = userPoints - verifiedPointsToRedeem + verifiedPointsEarned;
          final newLifetimePoints = lifetimePoints + verifiedPointsEarned;

          String level = 'Bronze';
          if (newLifetimePoints >= 5000) {
            level = 'Platinum';
          } else if (newLifetimePoints >= 1500) {
            level = 'Gold';
          } else if (newLifetimePoints >= 500) {
            level = 'Silver';
          }

          transaction.update(userDocRef, {
            'loyaltyPoints': newLoyaltyPoints,
            'lifetimePoints': newLifetimePoints,
            'membershipLevel': level,
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        }

        return transactionalOrder;
      });

      // Post-transaction low stock alerts triggered asynchronously
      for (final item in finalOrder.items) {
        try {
          final productDoc = await _firestore.collection(FirestoreConstants.products).doc(item.productId).get();
          if (productDoc.exists) {
            final data = productDoc.data() as Map<String, dynamic>;
            final cur = data['currentStock'] as int? ?? data['stockQuantity'] as int? ?? 0;
            final res = data['reservedStock'] as int? ?? 0;
            final stock = data['availableStock'] as int? ?? data['stockQuantity'] as int? ?? (cur - res);
            final alertQty = data['reorderLevel'] as int? ?? data['alertQuantity'] as int? ?? 10;
            final nameAr = data['nameAr'] as String? ?? '';
            final nameEn = data['nameEn'] as String? ?? '';
            
            if (stock <= 0) {
              await _firestore.collection(FirestoreConstants.notifications).add({
                'userId': 'all',
                'title': 'Out of Stock Alert',
                'body': 'Product $nameEn is out of stock!',
                'type': 'system',
                'isRead': false,
                'createdAt': FieldValue.serverTimestamp(),
                'data': {
                  'titleAr': 'تنبيه نفاد المخزون',
                  'bodyAr': 'المنتج $nameAr نفد من المخزون تماماً!',
                  'titleEn': 'Out of Stock Alert',
                  'bodyEn': 'Product $nameEn is out of stock!',
                },
              });
            } else if (stock <= alertQty) {
              await _firestore.collection(FirestoreConstants.notifications).add({
                'userId': 'all',
                'title': 'Low Stock Alert',
                'body': 'Product $nameEn is running low ($stock remaining).',
                'type': 'system',
                'isRead': false,
                'createdAt': FieldValue.serverTimestamp(),
                'data': {
                  'titleAr': 'تنبيه انخفاض المخزون',
                  'bodyAr': 'المنتج $nameAr يقترب من النفاد ($stock متبقي).',
                  'titleEn': 'Low Stock Alert',
                  'bodyEn': 'Product $nameEn is running low ($stock remaining).',
                },
              });
            }
          }
        } catch (_) {}
      }

      return Success(finalOrder);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateOrderStatus(String orderId, String status) async {
    try {
      final docRef = _ordersCol.doc(orderId);
      final curUserUid = _auth.currentUser?.uid;
      if (curUserUid == null) {
        return Failure(AuthException(message: 'User is not authenticated'));
      }
      final userDocRef = _firestore.collection('users').doc(curUserUid);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDocRef);
        final orderSnapshot = await transaction.get(docRef);

        if (!userSnapshot.exists) {
          throw FirebaseException(plugin: 'cloud_firestore', message: 'User not found');
        }
        if (!orderSnapshot.exists) {
          throw FirebaseException(plugin: 'cloud_firestore', message: 'Order not found');
        }

        final userData = userSnapshot.data() as Map<String, dynamic>;
        final userRole = UserRole.fromString(userData['role'] as String? ?? 'customer');

        final orderData = orderSnapshot.data() as Map<String, dynamic>;
        final order = OrderModel.fromDto(OrderDto.fromMap(orderData, orderSnapshot.id));
        final oldStatus = order.status;

        if (oldStatus == status) {
          return;
        }

        // Authorization rules
        if (status == 'Cancelled') {
          // Customer can only cancel their own Pending orders
          if (curUserUid == order.customerId) {
            if (oldStatus != 'Pending') {
              throw FirebaseException(
                plugin: 'cloud_firestore',
                message: 'Customers can only cancel Pending orders',
              );
            }
          } else if (!userRole.isStaff && !userRole.canManageOrders) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Unauthorized status modification request',
            );
          }
        } else {
          // Only staff can perform other operational status transitions
          if (!userRole.isStaff && !userRole.canManageOrders) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Only staff can perform operational status transitions',
            );
          }
        }

        final isOldStatusReserving = (oldStatus == 'Pending' || oldStatus == 'Confirmed' || oldStatus == 'Preparing' || oldStatus == 'OutForDelivery');

        if ((status == 'Cancelled' || status == 'Delivered') && isOldStatusReserving) {
          // Read Phase: Get product stocks in parallel
          final productGets = order.items.map((item) {
            return transaction.get(_firestore.collection(FirestoreConstants.products).doc(item.productId));
          }).toList();
          final productSnapshots = await Future.wait(productGets);

          // Write Phase: Update order status
          transaction.update(docRef, {
            'status': status,
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });

          if (status == 'Cancelled') {
            for (var i = 0; i < order.items.length; i++) {
              final item = order.items[i];
              final productSnapshot = productSnapshots[i];
              final productDocRef = _firestore.collection(FirestoreConstants.products).doc(item.productId);

              transaction.update(productDocRef, {
                'availableStock': FieldValue.increment(item.quantity),
                'reservedStock': FieldValue.increment(-item.quantity),
                'stockQuantity': FieldValue.increment(item.quantity), // legacy sync
              });

              int avStock = 0;
              if (productSnapshot.exists) {
                final pData = productSnapshot.data() as Map<String, dynamic>;
                final cur = pData['currentStock'] as int? ?? pData['stockQuantity'] as int? ?? 50;
                final res = pData['reservedStock'] as int? ?? 0;
                avStock = pData['availableStock'] as int? ?? pData['stockQuantity'] as int? ?? (cur - res);
              }

              final historyDocRef = _firestore.collection('stock_history').doc();
              transaction.set(historyDocRef, {
                'id': historyDocRef.id,
                'productId': item.productId,
                'productNameAr': item.productNameAr,
                'productNameEn': item.productNameEn,
                'type': 'order_cancelled',
                'quantityChanged': item.quantity,
                'previousStock': avStock,
                'newStock': avStock + item.quantity,
                'reasonAr': 'تم إرجاع المخزون لإلغاء الطلب رقم ${order.orderNumber}',
                'reasonEn': 'Stock restored due to cancellation of order #${order.orderNumber}',
                'createdAt': FieldValue.serverTimestamp(),
                'createdBy': order.customerId.isNotEmpty ? order.customerId : 'system',
              });
            }

            // Rollback FIFO batch allocations
            if (order.batchAllocations != null && order.batchAllocations!.isNotEmpty) {
              for (final entry in order.batchAllocations!.entries) {
                for (final batchEntry in entry.value.entries) {
                  final batchDocRef = _firestore.collection('batches').doc(batchEntry.key);
                  transaction.update(batchDocRef, {
                    'availableQuantity': FieldValue.increment(batchEntry.value),
                    'reservedQuantity': FieldValue.increment(-batchEntry.value),
                    FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
                  });
                }
              }
            }
          } else if (status == 'Delivered') {
            for (var i = 0; i < order.items.length; i++) {
              final item = order.items[i];
              final productSnapshot = productSnapshots[i];
              final productDocRef = _firestore.collection(FirestoreConstants.products).doc(item.productId);

              transaction.update(productDocRef, {
                'currentStock': FieldValue.increment(-item.quantity),
                'reservedStock': FieldValue.increment(-item.quantity),
              });

              int curStock = 0;
              if (productSnapshot.exists) {
                final pData = productSnapshot.data() as Map<String, dynamic>;
                curStock = pData['currentStock'] as int? ?? pData['stockQuantity'] as int? ?? 50;
              }

              final historyDocRef = _firestore.collection('stock_history').doc();
              transaction.set(historyDocRef, {
                'id': historyDocRef.id,
                'productId': item.productId,
                'productNameAr': item.productNameAr,
                'productNameEn': item.productNameEn,
                'type': 'fulfillment',
                'quantityChanged': -item.quantity,
                'previousStock': curStock,
                'newStock': curStock - item.quantity,
                'reasonAr': 'تم تسليم المنتجات وتعديل المخزون الفعلي للطلب رقم ${order.orderNumber}',
                'reasonEn': 'Physical stock decremented upon delivery of order #${order.orderNumber}',
                'createdAt': FieldValue.serverTimestamp(),
                'createdBy': 'system',
              });
            }

            // Fulfill FIFO batch allocations: decrement physical stock from batches
            if (order.batchAllocations != null && order.batchAllocations!.isNotEmpty) {
              for (final entry in order.batchAllocations!.entries) {
                for (final batchEntry in entry.value.entries) {
                  final batchDocRef = _firestore.collection('batches').doc(batchEntry.key);
                  transaction.update(batchDocRef, {
                    'currentQuantity': FieldValue.increment(-batchEntry.value),
                    'reservedQuantity': FieldValue.increment(-batchEntry.value),
                    FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
                  });
                }
              }
            }
          }
        } else {
          // Just update status
          transaction.update(docRef, {
            'status': status,
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });

      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
