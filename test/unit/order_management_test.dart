import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Order Management Tests', () {
    test('Create order and verify schema and stock deduction', () async {
      final prefs = await SharedPreferences.getInstance();
      final orderRepo = MockOrderRepository(prefs);
      final productRepo = MockProductRepository(prefs);

      // Verify chicken stock before order (seeded with 4)
      final prodResultBefore = await productRepo.getProduct('prod_chicken');
      expect(prodResultBefore, isA<Success<ProductEntity>>());
      final chickenBefore = (prodResultBefore as Success<ProductEntity>).data;
      expect(chickenBefore.stockQuantity, 4);

      // Create new order
      final newOrder = OrderEntity(
        id: '',
        orderNumber: '', // repo should generate this
        customerId: 'customer_user',
        customerName: 'Abdelrahman',
        phone: '01234567890',
        address: '5th Settlement, New Cairo',
        subtotal: 100.0,
        deliveryFee: 15.0,
        total: 115.0,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'customer_user',
        userEmail: 'customer@freshmarket.com',
        totalAmount: 115.0,
        items: const [
          OrderItemEntity(
            productId: 'prod_chicken',
            productName: 'Fresh Chicken',
            quantity: 2,
            unitPrice: 50.0,
            totalPrice: 100.0,
            productNameAr: 'دجاج طازج',
            productNameEn: 'Fresh Chicken',
            price: 50.0,
          ),
        ],
      );

      final createResult = await orderRepo.createOrder(newOrder);
      expect(createResult, isA<Success<OrderEntity>>());
      final createdOrder = (createResult as Success<OrderEntity>).data;

      // Verify fields
      expect(createdOrder.id.isNotEmpty, true);
      expect(createdOrder.orderNumber.startsWith('ORD-'), true);
      expect(createdOrder.customerId, 'customer_user');
      expect(createdOrder.customerName, 'Abdelrahman');
      expect(createdOrder.phone, '01234567890');
      expect(createdOrder.address, '5th Settlement, New Cairo');
      expect(createdOrder.subtotal, 100.0);
      expect(createdOrder.deliveryFee, 15.0);
      expect(createdOrder.total, 115.0);
      expect(createdOrder.status, 'Pending');
      expect(createdOrder.items.first.productName, 'Fresh Chicken');
      expect(createdOrder.items.first.unitPrice, 50.0);
      expect(createdOrder.items.first.totalPrice, 100.0);

      // Verify chicken stock deducted by 2 (4 - 2 = 2)
      final prodResultAfter = await productRepo.getProduct('prod_chicken');
      expect(prodResultAfter, isA<Success<ProductEntity>>());
      final chickenAfter = (prodResultAfter as Success<ProductEntity>).data;
      expect(chickenAfter.stockQuantity, 2);
    });

    test('Verify order status transitions', () async {
      final prefs = await SharedPreferences.getInstance();
      final orderRepo = MockOrderRepository(prefs);

      // Fetch active orders (seed orders present)
      final ordersResult = await orderRepo.getOrders();
      expect(ordersResult, isA<Success<List<OrderEntity>>>());
      final orders = (ordersResult as Success<List<OrderEntity>>).data;
      final order = orders.firstWhere((o) => o.status == 'Pending');

      // Update status: Pending -> Confirmed
      final confirmRes = await orderRepo.updateOrderStatus(order.id, 'Confirmed');
      expect(confirmRes, isA<Success<void>>());

      // Update status: Confirmed -> Preparing
      final prepRes = await orderRepo.updateOrderStatus(order.id, 'Preparing');
      expect(prepRes, isA<Success<void>>());

      // Update status: Preparing -> OutForDelivery
      final outRes = await orderRepo.updateOrderStatus(order.id, 'OutForDelivery');
      expect(outRes, isA<Success<void>>());

      // Update status: OutForDelivery -> Delivered
      final deliverRes = await orderRepo.updateOrderStatus(order.id, 'Delivered');
      expect(deliverRes, isA<Success<void>>());

      // Re-fetch and check final status
      final listRes = await orderRepo.getOrders();
      final updatedOrder = (listRes as Success<List<OrderEntity>>).data.firstWhere((o) => o.id == order.id);
      expect(updatedOrder.status, 'Delivered');
    });

    test('Verify order cancellation', () async {
      final prefs = await SharedPreferences.getInstance();
      final orderRepo = MockOrderRepository(prefs);

      // Get pending order
      final ordersResult = await orderRepo.getOrders();
      final order = (ordersResult as Success<List<OrderEntity>>).data.firstWhere((o) => o.status == 'Pending');

      // Cancel order
      final cancelRes = await orderRepo.updateOrderStatus(order.id, 'Cancelled');
      expect(cancelRes, isA<Success<void>>());

      // Re-fetch and check status
      final listRes = await orderRepo.getOrders();
      final updatedOrder = (listRes as Success<List<OrderEntity>>).data.firstWhere((o) => o.id == order.id);
      expect(updatedOrder.status, 'Cancelled');
    });
  });
}
