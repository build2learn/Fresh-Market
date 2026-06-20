import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/supplier.entity.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/entities/supplier_payment.entity.dart';
import 'package:fresh_market/domain/entities/stock_history.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Supplier Balance & Payments Unit Tests', () {
    test('Verify PO receipt increments balance & logs stock history', () async {
      final prefs = await SharedPreferences.getInstance();

      final supplierRepo = MockSupplierRepository(prefs);
      final poRepo = MockPurchaseOrderRepository(prefs);
      final prodRepo = MockProductRepository(prefs);
      final historyRepo = MockStockHistoryRepository(prefs);

      // Fetch initial supplier_1 balance
      final supRes = await supplierRepo.getSuppliers();
      expect(supRes, isA<Success<List<SupplierEntity>>>());
      final supplier = (supRes as Success<List<SupplierEntity>>).data.firstWhere((s) => s.id == 'supplier_1');
      expect(supplier.balance, 0.0);

      // Verify product initial stock (prod_chicken is seeded with stockQuantity = 4)
      final prodResult = await prodRepo.getProduct('prod_chicken');
      expect(prodResult, isA<Success<ProductEntity>>());
      final initialProduct = (prodResult as Success<ProductEntity>).data;
      expect(initialProduct.stockQuantity, 4);

      // Create purchase order for prod_chicken with unitCost
      final po = PurchaseOrderEntity(
        id: '',
        supplierId: 'supplier_1',
        supplierName: 'Cairo Fresh Farm',
        status: 'Ordered',
        items: const [
          PurchaseOrderItemEntity(
            productId: 'prod_chicken',
            productName: 'Fresh Chicken',
            quantityOrdered: 20,
            quantityReceived: 0,
            unitCost: 15.5,
          )
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final poCreateRes = await poRepo.createPurchaseOrder(po);
      final createdPo = (poCreateRes as Success<PurchaseOrderEntity>).data;

      // Receive the items (20 units received at 15.5 unit cost)
      final receiveRes = await poRepo.receivePurchaseOrderItems(createdPo.id, [
        const PurchaseOrderItemEntity(
          productId: 'prod_chicken',
          productName: 'Fresh Chicken',
          quantityOrdered: 20,
          quantityReceived: 20,
          unitCost: 15.5,
        )
      ]);
      expect(receiveRes, isA<Success<void>>());

      // Verify Supplier outstanding balance is incremented by 20 * 15.5 = 310.0
      final updatedSupRes = await supplierRepo.getSuppliers();
      final updatedSupplier = (updatedSupRes as Success<List<SupplierEntity>>).data.firstWhere((s) => s.id == 'supplier_1');
      expect(updatedSupplier.balance, 310.0);

      // Verify stock history log is created
      final historyRes = await historyRepo.getStockHistory(productId: 'prod_chicken');
      expect(historyRes, isA<Success<List<StockHistoryEntity>>>());
      final logs = (historyRes as Success<List<StockHistoryEntity>>).data;
      expect(logs.isNotEmpty, true);
      expect(logs.first.type, 'receipt');
      expect(logs.first.quantityChanged, 20);
      expect(logs.first.reasonEn.contains(createdPo.id), true);
    });

    test('Verify recording a payment decrements balance & deleting restores it', () async {
      final prefs = await SharedPreferences.getInstance();

      final supplierRepo = MockSupplierRepository(prefs);
      final paymentRepo = MockSupplierPaymentRepository(prefs);

      // Set initial balance manually to 500.0 by updating the mock list
      final initialSupplier = SupplierEntity(
        id: 'supplier_1',
        name: 'Cairo Fresh Farm',
        contactPerson: 'Ahmed Hassan',
        phone: '01012345678',
        email: 'cairo@freshfarm.com',
        address: 'Obour Market, Cairo',
        balance: 500.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await supplierRepo.updateSupplier(initialSupplier);

      final supResBefore = await supplierRepo.getSuppliers();
      final supplierBefore = (supResBefore as Success<List<SupplierEntity>>).data.firstWhere((s) => s.id == 'supplier_1');
      expect(supplierBefore.balance, 500.0);

      // Record a payment of 200.0
      final payment = SupplierPaymentEntity(
        id: '',
        supplierId: 'supplier_1',
        supplierName: 'Cairo Fresh Farm',
        amount: 200.0,
        paymentDate: DateTime.now(),
        paymentMethod: 'Cash',
        referenceNumber: 'REF-12345',
        notes: 'Test payment',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final payRes = await paymentRepo.createPayment(payment);
      expect(payRes, isA<Success<SupplierPaymentEntity>>());
      final createdPayment = (payRes as Success<SupplierPaymentEntity>).data;

      // Verify Supplier balance is decremented to 500.0 - 200.0 = 300.0
      final supResAfterPay = await supplierRepo.getSuppliers();
      final supplierAfterPay = (supResAfterPay as Success<List<SupplierEntity>>).data.firstWhere((s) => s.id == 'supplier_1');
      expect(supplierAfterPay.balance, 300.0);

      // Verify payment was saved in registry
      final getPaysRes = await paymentRepo.getPayments(supplierId: 'supplier_1');
      expect(getPaysRes, isA<Success<List<SupplierPaymentEntity>>>());
      final paymentsList = (getPaysRes as Success<List<SupplierPaymentEntity>>).data;
      expect(paymentsList.length, 1);
      expect(paymentsList.first.amount, 200.0);

      // Delete the payment record
      final delRes = await paymentRepo.deletePayment(createdPayment.id);
      expect(delRes, isA<Success<void>>());

      // Verify Supplier balance is restored back to 500.0
      final supResAfterDel = await supplierRepo.getSuppliers();
      final supplierAfterDel = (supResAfterDel as Success<List<SupplierEntity>>).data.firstWhere((s) => s.id == 'supplier_1');
      expect(supplierAfterDel.balance, 500.0);
    });
  });
}
