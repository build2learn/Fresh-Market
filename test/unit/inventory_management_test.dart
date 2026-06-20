import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/stock_history.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Inventory Management Unit Tests', () {
    test('Verify initial product inventory fields and compatibility getters', () async {
      final prefs = await SharedPreferences.getInstance();
      final productRepo = MockProductRepository(prefs);

      final result = await productRepo.getProduct('prod_chicken');
      expect(result, isA<Success<ProductEntity>>());
      final chicken = (result as Success<ProductEntity>).data;

      // Verify new fields
      expect(chicken.currentStock, 4);
      expect(chicken.reservedStock, 0);
      expect(chicken.availableStock, 4);
      expect(chicken.minimumStock, 2);
      expect(chicken.reorderLevel, 10);

      // Verify compatibility getters
      expect(chicken.stockQuantity, 4);
      expect(chicken.minStock, 2);
      expect(chicken.alertQuantity, 10);
    });

    test('Verify stock decreases (availableStock decreases, reservedStock increases) on Order Created', () async {
      final prefs = await SharedPreferences.getInstance();
      final productRepo = MockProductRepository(prefs);
      final orderRepo = MockOrderRepository(prefs);
      final historyRepo = MockStockHistoryRepository(prefs);

      // 1. Create a pending order with quantity 2
      final newOrder = OrderEntity(
        id: '',
        orderNumber: '',
        customerId: 'user_123',
        customerName: 'Test Customer',
        phone: '01234567890',
        address: 'Cairo, Egypt',
        subtotal: 170.0,
        deliveryFee: 10.0,
        total: 180.0,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'user_123',
        userEmail: 'test@example.com',
        totalAmount: 180.0,
        items: const [
          OrderItemEntity(
            productId: 'prod_chicken',
            productName: 'Fresh Chicken',
            quantity: 2,
            unitPrice: 85.0,
            totalPrice: 170.0,
            productNameAr: 'دجاج طازج',
            productNameEn: 'Fresh Chicken',
            price: 85.0,
          ),
        ],
      );

      final createRes = await orderRepo.createOrder(newOrder);
      expect(createRes, isA<Success<OrderEntity>>());
      final createdOrder = (createRes as Success<OrderEntity>).data;

      // 2. Verify stock levels on product after creation
      final prodRes = await productRepo.getProduct('prod_chicken');
      final chicken = (prodRes as Success<ProductEntity>).data;

      expect(chicken.currentStock, 4); // physical stock remains same
      expect(chicken.reservedStock, 2); // 2 units are reserved
      expect(chicken.availableStock, 2); // 4 - 2 = 2 available for sale
      expect(chicken.stockQuantity, 2); // compatibility getter also 2

      // 3. Verify stock history log is written
      final historyRes = await historyRepo.getStockHistory(productId: 'prod_chicken');
      expect(historyRes, isA<Success<List<StockHistoryEntity>>>());
      final logs = (historyRes as Success<List<StockHistoryEntity>>).data;

      expect(logs.isNotEmpty, true);
      final orderLog = logs.firstWhere((log) => log.type == 'order_created');
      expect(orderLog.quantityChanged, -2);
      expect(orderLog.previousStock, 4);
      expect(orderLog.newStock, 2);
      expect(orderLog.reasonEn.contains(createdOrder.orderNumber), true);
    });

    test('Verify stock is restored on Order Cancelled', () async {
      final prefs = await SharedPreferences.getInstance();
      final productRepo = MockProductRepository(prefs);
      final orderRepo = MockOrderRepository(prefs);
      final historyRepo = MockStockHistoryRepository(prefs);

      // 1. Create order
      final newOrder = OrderEntity(
        id: '',
        orderNumber: '',
        customerId: 'user_123',
        customerName: 'Test Customer',
        phone: '01234567890',
        address: 'Cairo, Egypt',
        subtotal: 170.0,
        deliveryFee: 10.0,
        total: 180.0,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'user_123',
        userEmail: 'test@example.com',
        totalAmount: 180.0,
        items: const [
          OrderItemEntity(
            productId: 'prod_chicken',
            productName: 'Fresh Chicken',
            quantity: 2,
            unitPrice: 85.0,
            totalPrice: 170.0,
            productNameAr: 'دجاج طازج',
            productNameEn: 'Fresh Chicken',
            price: 85.0,
          ),
        ],
      );

      final createRes = await orderRepo.createOrder(newOrder);
      final createdOrder = (createRes as Success<OrderEntity>).data;

      // Verify stock was reduced
      var prodRes = await productRepo.getProduct('prod_chicken');
      var chicken = (prodRes as Success<ProductEntity>).data;
      expect(chicken.availableStock, 2);
      expect(chicken.reservedStock, 2);

      // 2. Cancel order
      final cancelRes = await orderRepo.updateOrderStatus(createdOrder.id, 'Cancelled');
      expect(cancelRes, isA<Success<void>>());

      // 3. Verify stock is restored
      prodRes = await productRepo.getProduct('prod_chicken');
      chicken = (prodRes as Success<ProductEntity>).data;

      expect(chicken.currentStock, 4);
      expect(chicken.reservedStock, 0); // reservation cleared
      expect(chicken.availableStock, 4); // available stock restored

      // 4. Verify cancel history log
      final historyRes = await historyRepo.getStockHistory(productId: 'prod_chicken');
      final logs = (historyRes as Success<List<StockHistoryEntity>>).data;
      final cancelLog = logs.firstWhere((log) => log.type == 'order_cancelled');
      expect(cancelLog.quantityChanged, 2);
      expect(cancelLog.previousStock, 2);
      expect(cancelLog.newStock, 4);
    });

    test('Verify Manual Stock Adjustment and Receipt', () async {
      final prefs = await SharedPreferences.getInstance();
      final productRepo = MockProductRepository(prefs);
      final historyRepo = MockStockHistoryRepository(prefs);

      // 1. Adjust physical stock to 10
      final adjustRes = await productRepo.adjustStock('prod_chicken', 10, reasonEn: 'Inventory count correction');
      expect(adjustRes, isA<Success<void>>());

      var prodRes = await productRepo.getProduct('prod_chicken');
      var chicken = (prodRes as Success<ProductEntity>).data;
      expect(chicken.currentStock, 10);
      expect(chicken.availableStock, 10);
      expect(chicken.reservedStock, 0);

      // 2. Receive stock of 5 units
      final receiveRes = await productRepo.receiveStock('prod_chicken', 5, reasonEn: 'Supplier replenishment');
      expect(receiveRes, isA<Success<void>>());

      prodRes = await productRepo.getProduct('prod_chicken');
      chicken = (prodRes as Success<ProductEntity>).data;
      expect(chicken.currentStock, 15);
      expect(chicken.availableStock, 15);

      // 3. Verify logs are recorded in history
      final historyRes = await historyRepo.getStockHistory(productId: 'prod_chicken');
      final logs = (historyRes as Success<List<StockHistoryEntity>>).data;

      final adjustLog = logs.firstWhere((log) => log.type == 'adjustment');
      expect(adjustLog.quantityChanged, 6); // 10 - 4 = 6
      expect(adjustLog.newStock, 10);

      final receiveLog = logs.firstWhere((log) => log.type == 'receipt');
      expect(receiveLog.quantityChanged, 5);
      expect(receiveLog.newStock, 15);
    });
  });
}
