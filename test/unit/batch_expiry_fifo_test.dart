import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/batch.entity.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/data/models/order_model.dart';

String _testEncode(dynamic value) {
  return jsonEncode(value, toEncodable: (item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    if (item.runtimeType.toString().contains('Timestamp')) {
      return (item as dynamic).toDate().toIso8601String();
    }
    return item;
  });
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Batch & Expiry FIFO Management Tests', () {
    test('1. PO Goods Received -> Batch Creation', () async {
      final prefs = await SharedPreferences.getInstance();

      // Seed product 'prod_chicken' in mock products list so PO receives correctly
      final productMap = {
        'id': 'prod_chicken',
        'nameAr': 'دجاج طازج',
        'nameEn': 'Fresh Chicken',
        'price': 100.0,
        'stockQuantity': 4,
        'currentStock': 4,
        'availableStock': 4,
        'reservedStock': 0,
        'isAvailable': true,
        'imageUrl': '',
        'weight': 1.0,
        'weightUnitId': 'unit_kg',
        'categoryId': 'cat_meat',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setStringList('mock_products', [jsonEncode(productMap)]);

      final poRepo = MockPurchaseOrderRepository(prefs);
      final batchRepo = MockBatchRepository(prefs);

      // Create purchase order for prod_chicken
      final po = PurchaseOrderEntity(
        id: 'po_test_1',
        supplierId: 'supplier_1',
        supplierName: 'Cairo Fresh Farm',
        status: 'Ordered',
        items: const [
          PurchaseOrderItemEntity(
            productId: 'prod_chicken',
            productName: 'Fresh Chicken',
            quantityOrdered: 30,
            quantityReceived: 0,
          )
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final poCreateRes = await poRepo.createPurchaseOrder(po);
      expect(poCreateRes, isA<Success<PurchaseOrderEntity>>());

      // Receive items with custom batch code and expiry date
      final expiryDate = DateTime.now().add(const Duration(days: 45));
      final receiveRes = await poRepo.receivePurchaseOrderItems('po_test_1', [
        PurchaseOrderItemEntity(
          productId: 'prod_chicken',
          productName: 'Fresh Chicken',
          quantityOrdered: 30,
          quantityReceived: 30,
          unitCost: 75.0,
          batchCode: 'BATCH-CHICK-123',
          expiryDate: expiryDate,
        )
      ]);
      expect(receiveRes, isA<Success<void>>());

      // Fetch batch list and verify new batch details
      final batchListRes = await batchRepo.getBatches();
      expect(batchListRes, isA<Success<List<BatchEntity>>>());
      final batches = (batchListRes as Success<List<BatchEntity>>).data;

      final chickenBatch = batches.firstWhere((b) => b.productId == 'prod_chicken');
      expect(chickenBatch.batchCode, 'BATCH-CHICK-123');
      expect(chickenBatch.initialQuantity, 30);
      expect(chickenBatch.currentQuantity, 30);
      expect(chickenBatch.availableQuantity, 30);
      expect(chickenBatch.reservedQuantity, 0);
      expect(chickenBatch.unitCost, 75.0);
      expect(chickenBatch.expiryDate.year, expiryDate.year);
      expect(chickenBatch.expiryDate.month, expiryDate.month);
      expect(chickenBatch.expiryDate.day, expiryDate.day);
    });

    test('2. Order Checkout -> FIFO Stock Allocation', () async {
      final prefs = await SharedPreferences.getInstance();

      // Seed product prod_apple
      final productMap = {
        'id': 'prod_apple',
        'nameAr': 'تفاح أحمر',
        'nameEn': 'Red Apple',
        'price': 40.0,
        'stockQuantity': 30,
        'currentStock': 30,
        'availableStock': 30,
        'reservedStock': 0,
        'isAvailable': true,
        'imageUrl': '',
        'weight': 1.0,
        'weightUnitId': 'unit_kg',
        'categoryId': 'cat_fruits',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setStringList('mock_products', [jsonEncode(productMap)]);

      // Create two batches with different expiration dates for prod_apple
      final now = DateTime.now();
      final expiryOlder = now.add(const Duration(days: 5));
      final expiryNewer = now.add(const Duration(days: 15));

      final batch1 = {
        'id': 'batch_apple_old',
        'productId': 'prod_apple',
        'batchCode': 'B-APPLE-OLD',
        'initialQuantity': 10,
        'currentQuantity': 10,
        'availableQuantity': 10,
        'reservedQuantity': 0,
        'unitCost': 20.0,
        'manufactureDate': now.subtract(const Duration(days: 5)).toIso8601String(),
        'expiryDate': expiryOlder.toIso8601String(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final batch2 = {
        'id': 'batch_apple_new',
        'productId': 'prod_apple',
        'batchCode': 'B-APPLE-NEW',
        'initialQuantity': 20,
        'currentQuantity': 20,
        'availableQuantity': 20,
        'reservedQuantity': 0,
        'unitCost': 22.0,
        'manufactureDate': now.toIso8601String(),
        'expiryDate': expiryNewer.toIso8601String(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      await prefs.setStringList('mock_batches', [jsonEncode(batch1), jsonEncode(batch2)]);

      final orderRepo = MockOrderRepository(prefs);
      final batchRepo = MockBatchRepository(prefs);

      // Place an order requesting 15 Apples (should consume 10 from oldest batch, 5 from newer batch)
      final order = OrderEntity(
        id: 'ord_test_fifo',
        orderNumber: 'ORD-FIFO-001',
        customerId: 'cust_1',
        customerName: 'Test Customer',
        phone: '01234567890',
        address: 'Cairo, Egypt',
        subtotal: 600.0,
        deliveryFee: 15.0,
        total: 615.0,
        status: 'Pending',
        createdAt: now,
        userId: 'user_customer',
        userEmail: 'test@customer.com',
        totalAmount: 615.0,
        updatedAt: now,
        items: const [
          OrderItemEntity(
            productId: 'prod_apple',
            productName: 'Red Apple',
            quantity: 15,
            unitPrice: 40.0,
            totalPrice: 600.0,
            productNameAr: 'تفاح أحمر',
            productNameEn: 'Red Apple',
            price: 40.0,
          )
        ],
      );

      final orderRes = await orderRepo.createOrder(order);
      expect(orderRes, isA<Success<OrderEntity>>());
      final createdOrder = (orderRes as Success<OrderEntity>).data;

      // Verify allocations recorded on order metadata
      expect(createdOrder.batchAllocations, isNotNull);
      final appleAllocations = createdOrder.batchAllocations!['prod_apple'];
      expect(appleAllocations, isNotNull);
      expect(appleAllocations!['batch_apple_old'], 10);
      expect(appleAllocations['batch_apple_new'], 5);

      // Verify batch stocks in DB
      final batchesRes = await batchRepo.getBatches();
      final batches = (batchesRes as Success<List<BatchEntity>>).data;

      final oldBatch = batches.firstWhere((b) => b.id == 'batch_apple_old');
      expect(oldBatch.availableQuantity, 0);
      expect(oldBatch.reservedQuantity, 10);
      expect(oldBatch.currentQuantity, 10); // Physical stock unchanged until delivered

      final newBatch = batches.firstWhere((b) => b.id == 'batch_apple_new');
      expect(newBatch.availableQuantity, 15);
      expect(newBatch.reservedQuantity, 5);
      expect(newBatch.currentQuantity, 20); // Physical stock unchanged until delivered
    });

    test('3. Order Cancellation -> Restore Locked Stocks', () async {
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();

      // Seed mock product
      final productMap = {
        'id': 'prod_apple',
        'nameAr': 'تفاح أحمر',
        'nameEn': 'Red Apple',
        'price': 40.0,
        'stockQuantity': 30,
        'currentStock': 30,
        'availableStock': 15,
        'reservedStock': 15,
        'isAvailable': true,
        'imageUrl': '',
        'weight': 1.0,
        'weightUnitId': 'unit_kg',
        'categoryId': 'cat_fruits',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      await prefs.setStringList('mock_products', [jsonEncode(productMap)]);

      // Seed mock batches representing locked stock
      final batch1 = {
        'id': 'batch_apple_old',
        'productId': 'prod_apple',
        'batchCode': 'B-APPLE-OLD',
        'initialQuantity': 10,
        'currentQuantity': 10,
        'availableQuantity': 0,
        'reservedQuantity': 10,
        'unitCost': 20.0,
        'expiryDate': now.add(const Duration(days: 5)).toIso8601String(),
      };

      final batch2 = {
        'id': 'batch_apple_new',
        'productId': 'prod_apple',
        'batchCode': 'B-APPLE-NEW',
        'initialQuantity': 20,
        'currentQuantity': 20,
        'availableQuantity': 15,
        'reservedQuantity': 5,
        'unitCost': 22.0,
        'expiryDate': now.add(const Duration(days: 15)).toIso8601String(),
      };

      await prefs.setStringList('mock_batches', [jsonEncode(batch1), jsonEncode(batch2)]);

      // Seed pending order in order repository
      final order = OrderEntity(
        id: 'ord_test_fifo',
        orderNumber: 'ORD-FIFO-001',
        customerId: 'cust_1',
        customerName: 'Test Customer',
        phone: '01234567890',
        address: 'Cairo, Egypt',
        subtotal: 600.0,
        deliveryFee: 15.0,
        total: 615.0,
        status: 'Pending',
        createdAt: now,
        userId: 'user_customer',
        userEmail: 'test@customer.com',
        totalAmount: 615.0,
        updatedAt: now,
        items: const [
          OrderItemEntity(
            productId: 'prod_apple',
            productName: 'Red Apple',
            quantity: 15,
            unitPrice: 40.0,
            totalPrice: 600.0,
            productNameAr: 'تفاح أحمر',
            productNameEn: 'Red Apple',
            price: 40.0,
          )
        ],
        batchAllocations: const {
          'prod_apple': {
            'batch_apple_old': 10,
            'batch_apple_new': 5,
          }
        },
      );

      final orderRepo = MockOrderRepository(prefs);
      final batchRepo = MockBatchRepository(prefs);

      // Seed order directly
      final orderDto = OrderModel.fromEntity(order);
      await prefs.setStringList('mock_orders', [_testEncode(orderDto.toMap()..['id'] = orderDto.id)]);

      // Cancel the order
      final cancelRes = await orderRepo.updateOrderStatus('ord_test_fifo', 'Cancelled');
      expect(cancelRes, isA<Success<void>>());

      // Verify batch stocks are restored
      final batchesRes = await batchRepo.getBatches();
      final batches = (batchesRes as Success<List<BatchEntity>>).data;

      final oldBatch = batches.firstWhere((b) => b.id == 'batch_apple_old');
      expect(oldBatch.availableQuantity, 10);
      expect(oldBatch.reservedQuantity, 0);

      final newBatch = batches.firstWhere((b) => b.id == 'batch_apple_new');
      expect(newBatch.availableQuantity, 20);
      expect(newBatch.reservedQuantity, 0);
    });

    test('4. Order Fulfillment -> Decrement Physical Stocks', () async {
      final prefs = await SharedPreferences.getInstance();

      final now = DateTime.now();

      // Seed mock product
      final productMap = {
        'id': 'prod_apple',
        'nameAr': 'تفاح أحمر',
        'nameEn': 'Red Apple',
        'price': 40.0,
        'stockQuantity': 30,
        'currentStock': 30,
        'availableStock': 15,
        'reservedStock': 15,
        'isAvailable': true,
        'imageUrl': '',
        'weight': 1.0,
        'weightUnitId': 'unit_kg',
        'categoryId': 'cat_fruits',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      await prefs.setStringList('mock_products', [jsonEncode(productMap)]);

      // Seed mock batches representing locked stock
      final batch1 = {
        'id': 'batch_apple_old',
        'productId': 'prod_apple',
        'batchCode': 'B-APPLE-OLD',
        'initialQuantity': 10,
        'currentQuantity': 10,
        'availableQuantity': 0,
        'reservedQuantity': 10,
        'unitCost': 20.0,
        'expiryDate': now.add(const Duration(days: 5)).toIso8601String(),
      };

      final batch2 = {
        'id': 'batch_apple_new',
        'productId': 'prod_apple',
        'batchCode': 'B-APPLE-NEW',
        'initialQuantity': 20,
        'currentQuantity': 20,
        'availableQuantity': 15,
        'reservedQuantity': 5,
        'unitCost': 22.0,
        'expiryDate': now.add(const Duration(days: 15)).toIso8601String(),
      };

      await prefs.setStringList('mock_batches', [jsonEncode(batch1), jsonEncode(batch2)]);

      // Seed pending order in order repository
      final order = OrderEntity(
        id: 'ord_test_fifo',
        orderNumber: 'ORD-FIFO-001',
        customerId: 'cust_1',
        customerName: 'Test Customer',
        phone: '01234567890',
        address: 'Cairo, Egypt',
        subtotal: 600.0,
        deliveryFee: 15.0,
        total: 615.0,
        status: 'Pending',
        createdAt: now,
        userId: 'user_customer',
        userEmail: 'test@customer.com',
        totalAmount: 615.0,
        updatedAt: now,
        items: const [
          OrderItemEntity(
            productId: 'prod_apple',
            productName: 'Red Apple',
            quantity: 15,
            unitPrice: 40.0,
            totalPrice: 600.0,
            productNameAr: 'تفاح أحمر',
            productNameEn: 'Red Apple',
            price: 40.0,
          )
        ],
        batchAllocations: const {
          'prod_apple': {
            'batch_apple_old': 10,
            'batch_apple_new': 5,
          }
        },
      );

      final orderRepo = MockOrderRepository(prefs);
      final batchRepo = MockBatchRepository(prefs);

      // Seed order directly
      final orderDto = OrderModel.fromEntity(order);
      await prefs.setStringList('mock_orders', [_testEncode(orderDto.toMap()..['id'] = orderDto.id)]);

      // Deliver the order
      final deliverRes = await orderRepo.updateOrderStatus('ord_test_fifo', 'Delivered');
      expect(deliverRes, isA<Success<void>>());

      // Verify batch physical stock is decremented
      final batchesRes = await batchRepo.getBatches();
      final batches = (batchesRes as Success<List<BatchEntity>>).data;

      final oldBatch = batches.firstWhere((b) => b.id == 'batch_apple_old');
      expect(oldBatch.currentQuantity, 0); // physical stock decremented from 10 to 0
      expect(oldBatch.reservedQuantity, 0); // reserved released

      final newBatch = batches.firstWhere((b) => b.id == 'batch_apple_new');
      expect(newBatch.currentQuantity, 15); // physical stock decremented from 20 to 15
      expect(newBatch.reservedQuantity, 0); // reserved released
    });
  });
}
