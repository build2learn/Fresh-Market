import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/order.entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../dto/order.dto.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

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
  Future<Result<OrderEntity>> createOrder(OrderEntity order) async {
    try {
      final docRef = order.id.isEmpty ? _ordersCol.doc() : _ordersCol.doc(order.id);
      
      final generatedNum = order.orderNumber.isEmpty 
          ? 'ORD-${DateTime.now().millisecondsSinceEpoch}' 
          : order.orderNumber;

      final finalOrder = order.copyWith(
        id: docRef.id,
        orderNumber: generatedNum,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      final dto = OrderModel.fromEntity(finalOrder);

      // 1. Write to orders document
      final orderData = dto.toMap();
      orderData[FirestoreConstants.createdAt] = FieldValue.serverTimestamp();
      orderData[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp();
      batch.set(docRef, orderData);

      // Fetch product details to log correctly
      final productSnapshots = await Future.wait(
        dto.items.map((item) => _firestore.collection(FirestoreConstants.products).doc(item.productId).get())
      );
      final productMap = <String, Map<String, dynamic>>{};
      for (final doc in productSnapshots) {
        if (doc.exists) {
          productMap[doc.id] = doc.data() as Map<String, dynamic>;
        }
      }

      // 2. Write order items to subcollection /orders/{orderId}/order_items
      // & top-level order_items
      for (final item in dto.items) {
        final subDocRef = docRef.collection(FirestoreConstants.orderItems).doc();
        final topDocRef = _orderItemsCol.doc(subDocRef.id);
        
        final itemData = item.toMap();
        itemData['orderId'] = docRef.id;
        itemData[FirestoreConstants.createdAt] = FieldValue.serverTimestamp();

        batch.set(subDocRef, itemData);
        batch.set(topDocRef, itemData);

        // Update product stock: decrement availableStock, increment reservedStock
        final productDocRef = _firestore.collection(FirestoreConstants.products).doc(item.productId);
        batch.update(productDocRef, {
          'availableStock': FieldValue.increment(-item.quantity),
          'reservedStock': FieldValue.increment(item.quantity),
          'stockQuantity': FieldValue.increment(-item.quantity), // legacy sync
        });

        // Write to stock history
        final productData = productMap[item.productId] ?? {};
        final curStock = productData['currentStock'] as int? ?? productData['stockQuantity'] as int? ?? 50;
        final resStock = productData['reservedStock'] as int? ?? 0;
        final avStock = productData['availableStock'] as int? ?? productData['stockQuantity'] as int? ?? (curStock - resStock);
        final nameAr = productData['nameAr'] as String? ?? item.productNameAr;
        final nameEn = productData['nameEn'] as String? ?? item.productNameEn;

        final historyDocRef = _firestore.collection('stock_history').doc();
        batch.set(historyDocRef, {
          'id': historyDocRef.id,
          'productId': item.productId,
          'productNameAr': nameAr,
          'productNameEn': nameEn,
          'type': 'order_created',
          'quantityChanged': -item.quantity,
          'previousStock': avStock,
          'newStock': avStock - item.quantity,
          'reasonAr': 'تم حجز المخزون لطلب جديد رقم ${finalOrder.orderNumber}',
          'reasonEn': 'Stock reserved for new order #${finalOrder.orderNumber}',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': order.customerId.isNotEmpty ? order.customerId : 'system',
        });
      }

      // Increment coupon usage count if applicable
      if (finalOrder.couponCode != null && finalOrder.couponCode!.isNotEmpty) {
        final couponSnapshot = await _firestore.collection('coupons')
            .where('code', isEqualTo: finalOrder.couponCode!.trim().toUpperCase())
            .limit(1)
            .get();
        if (couponSnapshot.docs.isNotEmpty) {
          final couponDocRef = couponSnapshot.docs.first.reference;
          batch.update(couponDocRef, {'usedCount': FieldValue.increment(1)});
        }
      }

      await batch.commit();

      // Check stock and trigger alerts asynchronously
      for (final item in dto.items) {
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

      // Fetch created document to return it
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      return Success(OrderModel.fromDto(OrderDto.fromMap(data, doc.id)));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateOrderStatus(String orderId, String status) async {
    try {
      final docRef = _ordersCol.doc(orderId);
      final doc = await docRef.get();
      if (!doc.exists) {
        return Failure(FirestoreException(message: 'Order not found'));
      }
      final orderData = doc.data() as Map<String, dynamic>;
      final order = OrderModel.fromDto(OrderDto.fromMap(orderData, doc.id));
      final oldStatus = order.status;

      if (oldStatus == status) {
        return const Success(null);
      }

      final batch = _firestore.batch();
      
      batch.update(docRef, {
        'status': status,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });

      final isOldStatusReserving = (oldStatus == 'Pending' || oldStatus == 'Confirmed' || oldStatus == 'Preparing' || oldStatus == 'OutForDelivery');

      if (status == 'Cancelled' && isOldStatusReserving) {
        for (final item in order.items) {
          final productDocRef = _firestore.collection(FirestoreConstants.products).doc(item.productId);
          batch.update(productDocRef, {
            'availableStock': FieldValue.increment(item.quantity),
            'reservedStock': FieldValue.increment(-item.quantity),
            'stockQuantity': FieldValue.increment(item.quantity), // legacy sync
          });

          final productDoc = await productDocRef.get();
          int avStock = 0;
          if (productDoc.exists) {
            final pData = productDoc.data() as Map<String, dynamic>;
            final cur = pData['currentStock'] as int? ?? pData['stockQuantity'] as int? ?? 50;
            final res = pData['reservedStock'] as int? ?? 0;
            avStock = pData['availableStock'] as int? ?? pData['stockQuantity'] as int? ?? (cur - res);
          }

          final historyDocRef = _firestore.collection('stock_history').doc();
          batch.set(historyDocRef, {
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
      } else if (status == 'Delivered' && isOldStatusReserving) {
        for (final item in order.items) {
          final productDocRef = _firestore.collection(FirestoreConstants.products).doc(item.productId);
          batch.update(productDocRef, {
            'currentStock': FieldValue.increment(-item.quantity),
            'reservedStock': FieldValue.increment(-item.quantity),
          });

          final productDoc = await productDocRef.get();
          int curStock = 0;
          if (productDoc.exists) {
            final pData = productDoc.data() as Map<String, dynamic>;
            curStock = pData['currentStock'] as int? ?? pData['stockQuantity'] as int? ?? 50;
          }

          final historyDocRef = _firestore.collection('stock_history').doc();
          batch.set(historyDocRef, {
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
      }

      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
