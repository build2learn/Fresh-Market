import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/warehouse.entity.dart';
import 'package:fresh_market/domain/entities/warehouse_inventory.entity.dart';
import 'package:fresh_market/domain/entities/stock_transfer.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Warehouse Repository CRUD Tests', () {
    test('Verify Warehouse CRUD operations and default seeds', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = MockWarehouseRepository(prefs);

      // 1. Verify default seeds
      final getRes = await repo.getWarehouses();
      expect(getRes, isA<Success<List<WarehouseEntity>>>());
      final list = (getRes as Success<List<WarehouseEntity>>).data;
      expect(list.length, 3);
      expect(list.any((w) => w.id == 'warehouse_cairo'), true);
      expect(list.any((w) => w.id == 'warehouse_alex'), true);
      expect(list.any((w) => w.id == 'warehouse_giza'), true);

      // 2. Create a new warehouse
      final newWh = WarehouseEntity(
        id: '',
        nameAr: 'مستودع المنصورة',
        nameEn: 'Mansoura Storage',
        locationAr: 'المنصورة، الدقهلية',
        locationEn: 'Mansoura, Dakahlia',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final createRes = await repo.createWarehouse(newWh);
      expect(createRes, isA<Success<WarehouseEntity>>());
      final created = (createRes as Success<WarehouseEntity>).data;
      expect(created.id.isNotEmpty, true);
      expect(created.nameEn, 'Mansoura Storage');

      // 3. Update the warehouse
      final updatedWh = created.copyWith(nameEn: 'Mansoura Express', isActive: false);
      final updateRes = await repo.updateWarehouse(updatedWh);
      expect(updateRes, isA<Success<WarehouseEntity>>());
      final updated = (updateRes as Success<WarehouseEntity>).data;
      expect(updated.nameEn, 'Mansoura Express');
      expect(updated.isActive, false);

      // 4. Verify in list
      final listRes = await repo.getWarehouses();
      final listData = (listRes as Success<List<WarehouseEntity>>).data;
      expect(listData.length, 4);
      expect(listData.any((w) => w.id == created.id && w.nameEn == 'Mansoura Express'), true);

      // 5. Delete warehouse
      final deleteRes = await repo.deleteWarehouse(created.id);
      expect(deleteRes, isA<Success<void>>());

      // 6. Verify deleted
      final finalRes = await repo.getWarehouses();
      final finalList = (finalRes as Success<List<WarehouseEntity>>).data;
      expect(finalList.length, 3);
      expect(finalList.any((w) => w.id == created.id), false);
    });
  });

  group('Warehouse Inventory & Stock Transfer Tests', () {
    test('Verify initial inventory seeds, stock transfers, validation, and global product stock sync', () async {
      final prefs = await SharedPreferences.getInstance();

      // Seed mock products in prefs so product sync doesn't crash and works correctly
      final now = DateTime.now();
      final mockProducts = [
        {
          'id': 'prod_minced_meat',
          'nameAr': 'لحمة مفرومة',
          'nameEn': 'Minced Meat',
          'price': 60.0,
          'weight': 400.0,
          'weightUnitId': 'gram',
          'categoryId': 'cat_meat',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'currentStock': 50,
          'reservedStock': 0,
          'availableStock': 50,
          'minimumStock': 5,
          'reorderLevel': 10,
        }
      ];
      await prefs.setStringList('mock_products', mockProducts.map((p) => jsonEncode(p)).toList());

      // Initialize repository (will trigger seeds)
      final repo = MockWarehouseRepository(prefs);
      final productRepo = MockProductRepository(prefs);

      // 1. Verify initial seeded inventory for Cairo and Alex
      final cairoInvRes = await repo.getInventoryForWarehouse('warehouse_cairo');
      final cairoInvList = (cairoInvRes as Success<List<WarehouseInventoryEntity>>).data;
      final cairoMeat = cairoInvList.firstWhere((i) => i.productId == 'prod_minced_meat');
      expect(cairoMeat.quantity, 30);

      final alexInvRes = await repo.getInventoryForWarehouse('warehouse_alex');
      final alexInvList = (alexInvRes as Success<List<WarehouseInventoryEntity>>).data;
      final alexMeat = alexInvList.firstWhere((i) => i.productId == 'prod_minced_meat');
      expect(alexMeat.quantity, 20);

      // 2. Perform a valid transfer (10 units Cairo -> Alex)
      final transferRes = await repo.transferStock(
        fromWarehouseId: 'warehouse_cairo',
        toWarehouseId: 'warehouse_alex',
        productId: 'prod_minced_meat',
        quantity: 10,
        notes: 'Transfer 10 units for event',
      );
      expect(transferRes, isA<Success<StockTransferEntity>>());
      final transfer = (transferRes as Success<StockTransferEntity>).data;
      expect(transfer.quantity, 10);
      expect(transfer.fromWarehouseId, 'warehouse_cairo');
      expect(transfer.toWarehouseId, 'warehouse_alex');

      // 3. Verify quantities updated
      final postCairoRes = await repo.getInventoryForWarehouse('warehouse_cairo');
      final postCairoMeat = (postCairoRes as Success<List<WarehouseInventoryEntity>>).data
          .firstWhere((i) => i.productId == 'prod_minced_meat');
      expect(postCairoMeat.quantity, 20); // 30 - 10 = 20

      final postAlexRes = await repo.getInventoryForWarehouse('warehouse_alex');
      final postAlexMeat = (postAlexRes as Success<List<WarehouseInventoryEntity>>).data
          .firstWhere((i) => i.productId == 'prod_minced_meat');
      expect(postAlexMeat.quantity, 30); // 20 + 10 = 30

      // 4. Verify global product stock is still 50 and synced (sum of 20 + 30)
      final prodRes = await productRepo.getProduct('prod_minced_meat');
      final product = (prodRes as Success<ProductEntity>).data;
      expect(product.currentStock, 50);
      expect(product.availableStock, 50);

      // 5. Test invalid transfer (transfer 100 units from Cairo which has only 20)
      final invalidTransferRes = await repo.transferStock(
        fromWarehouseId: 'warehouse_cairo',
        toWarehouseId: 'warehouse_alex',
        productId: 'prod_minced_meat',
        quantity: 100,
      );
      expect(invalidTransferRes, isA<Failure<StockTransferEntity>>());

      // Verify Cairo and Alex quantities remain unchanged (20 and 30)
      final finalCairoRes = await repo.getInventoryForWarehouse('warehouse_cairo');
      final finalCairoMeat = (finalCairoRes as Success<List<WarehouseInventoryEntity>>).data
          .firstWhere((i) => i.productId == 'prod_minced_meat');
      expect(finalCairoMeat.quantity, 20);

      final finalAlexRes = await repo.getInventoryForWarehouse('warehouse_alex');
      final finalAlexMeat = (finalAlexRes as Success<List<WarehouseInventoryEntity>>).data
          .firstWhere((i) => i.productId == 'prod_minced_meat');
      expect(finalAlexMeat.quantity, 30);
    });

    test('Verify manual inventory quantity adjustment updates global product stock', () async {
      final prefs = await SharedPreferences.getInstance();

      // Seed mock products in prefs
      final now = DateTime.now();
      final mockProducts = [
        {
          'id': 'prod_minced_meat',
          'nameAr': 'لحمة مفرومة',
          'nameEn': 'Minced Meat',
          'price': 60.0,
          'weight': 400.0,
          'weightUnitId': 'gram',
          'categoryId': 'cat_meat',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'currentStock': 50,
          'reservedStock': 0,
          'availableStock': 50,
          'minimumStock': 5,
          'reorderLevel': 10,
        }
      ];
      await prefs.setStringList('mock_products', mockProducts.map((p) => jsonEncode(p)).toList());

      final repo = MockWarehouseRepository(prefs);
      final productRepo = MockProductRepository(prefs);

      // Adjust Cairo stock to 50 (from 30)
      final adjustRes = await repo.updateInventoryQuantity('warehouse_cairo', 'prod_minced_meat', 50);
      expect(adjustRes, isA<Success<WarehouseInventoryEntity>>());
      final adjusted = (adjustRes as Success<WarehouseInventoryEntity>).data;
      expect(adjusted.quantity, 50);

      // Alex has 20, Cairo has 50. Total = 70.
      // Verify global product stock is updated to 70.
      final prodRes = await productRepo.getProduct('prod_minced_meat');
      final product = (prodRes as Success<ProductEntity>).data;
      expect(product.currentStock, 70);
      expect(product.availableStock, 70);
    });
  });
}
