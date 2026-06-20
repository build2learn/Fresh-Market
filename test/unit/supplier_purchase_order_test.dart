import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/supplier.entity.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Supplier Repository Tests', () {
    test('Supplier CRUD test', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = MockSupplierRepository(prefs);

      // 1. Initial seeds
      final initialResult = await repo.getSuppliers();
      expect(initialResult, isA<Success<List<SupplierEntity>>>());
      final initialData = (initialResult as Success<List<SupplierEntity>>).data;
      expect(initialData.length, 2); // Seeded supplier_1 and supplier_2

      // 2. Create supplier
      final newSupplier = SupplierEntity(
        id: '',
        name: 'Alex Vegetables',
        contactPerson: 'Kareem Aly',
        phone: '01233344455',
        email: 'alex@veg.com',
        address: 'Alexandria, Egypt',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final createResult = await repo.createSupplier(newSupplier);
      expect(createResult, isA<Success<SupplierEntity>>());
      final created = (createResult as Success<SupplierEntity>).data;
      expect(created.id.isNotEmpty, true);
      expect(created.name, 'Alex Vegetables');

      // 3. Update supplier
      final updatedSupplier = created.copyWith(contactPerson: 'Kareem Aly Updated');
      final updateResult = await repo.updateSupplier(updatedSupplier);
      expect(updateResult, isA<Success<SupplierEntity>>());
      final updated = (updateResult as Success<SupplierEntity>).data;
      expect(updated.contactPerson, 'Kareem Aly Updated');

      // 4. Verify in list
      final listResult = await repo.getSuppliers();
      final listData = (listResult as Success<List<SupplierEntity>>).data;
      expect(listData.length, 3);
      expect(listData.any((s) => s.id == created.id && s.contactPerson == 'Kareem Aly Updated'), true);

      // 5. Delete supplier
      final deleteResult = await repo.deleteSupplier(created.id);
      expect(deleteResult, isA<Success<void>>());

      // 6. Verify deleted
      final listResultAfterDelete = await repo.getSuppliers();
      final listDataAfterDelete = (listResultAfterDelete as Success<List<SupplierEntity>>).data;
      expect(listDataAfterDelete.length, 2);
      expect(listDataAfterDelete.any((s) => s.id == created.id), false);
    });
  });

  group('Purchase Order Repository Tests', () {
    test('Purchase Order Stock Receiving and Reconcile test', () async {
      final prefs = await SharedPreferences.getInstance();
      
      // Initialize repositories
      final prodRepo = MockProductRepository(prefs);
      final poRepo = MockPurchaseOrderRepository(prefs);

      // Verify initial product stock (prod_chicken is seeded with stockQuantity = 4)
      final prodResult = await prodRepo.getProduct('prod_chicken');
      expect(prodResult, isA<Success<ProductEntity>>());
      final initialProduct = (prodResult as Success<ProductEntity>).data;
      expect(initialProduct.stockQuantity, 4);

      // Create purchase order for prod_chicken (qty ordered: 30)
      final po = PurchaseOrderEntity(
        id: '',
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
      final createdPo = (poCreateRes as Success<PurchaseOrderEntity>).data;
      expect(createdPo.id.isNotEmpty, true);

      // Receive the items (quantityReceived = 30)
      final receiveRes = await poRepo.receivePurchaseOrderItems(createdPo.id, [
        const PurchaseOrderItemEntity(
          productId: 'prod_chicken',
          productName: 'Fresh Chicken',
          quantityOrdered: 30,
          quantityReceived: 30,
        )
      ]);
      expect(receiveRes, isA<Success<void>>());

      // Verify PO status updated to Received
      final posResult = await poRepo.getPurchaseOrders();
      final updatedPo = (posResult as Success<List<PurchaseOrderEntity>>).data.firstWhere((p) => p.id == createdPo.id);
      expect(updatedPo.status, 'Received');
      expect(updatedPo.items[0].quantityReceived, 30);

      // Verify product stock quantity is incremented by 30 (4 + 30 = 34)
      final updatedProdResult = await prodRepo.getProduct('prod_chicken');
      expect(updatedProdResult, isA<Success<ProductEntity>>());
      final updatedProduct = (updatedProdResult as Success<ProductEntity>).data;
      expect(updatedProduct.stockQuantity, 34);
    });
  });
}
