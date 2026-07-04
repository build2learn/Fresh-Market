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
import 'package:fresh_market/core/mocks/mock_product_repository.dart';

class MockWarehouseRepository implements WarehouseRepository {
  static const String _warehousesKey = 'mock_warehouses';
  static const String _inventoriesKey = 'mock_warehouse_inventories';
  static const String _transfersKey = 'mock_stock_transfers';

  final SharedPreferences _prefs;
  final _warehouseController = StreamController<List<WarehouseEntity>>.broadcast();
  final _inventoryController = StreamController<List<WarehouseInventoryEntity>>.broadcast();
  final _transferController = StreamController<List<StockTransferEntity>>.broadcast();

  MockWarehouseRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final now = DateTime.now();
    
    // 1. Seed Warehouses
    final warehouseList = _prefs.getStringList(_warehousesKey) ?? [];
    if (warehouseList.isEmpty) {
      final seedWarehouses = [
        {
          'id': 'warehouse_cairo',
          'nameAr': 'مستودع القاهرة الرئيسي',
          'nameEn': 'Cairo Main Hub',
          'locationAr': 'القاهرة، مصر',
          'locationEn': 'Cairo, Egypt',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex',
          'nameAr': 'مستودع الإسكندرية السريع',
          'nameEn': 'Alexandria Express',
          'locationAr': 'الإسكندرية، مصر',
          'locationEn': 'Alexandria, Egypt',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_giza',
          'nameAr': 'مستودع الجيزة المبرد',
          'nameEn': 'Giza Cold Storage',
          'locationAr': 'الجيزة، مصر',
          'locationEn': 'Giza, Egypt',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
      _prefs.setStringList(_warehousesKey, seedWarehouses.map((e) => jsonEncode(e)).toList());
    }

    // 2. Seed Inventories
    final inventoryList = _prefs.getStringList(_inventoriesKey) ?? [];
    if (inventoryList.isEmpty) {
      final seedInventories = [
        // prod_minced_meat: Total 50
        {
          'id': 'warehouse_cairo_prod_minced_meat',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_minced_meat',
          'quantity': 30,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_minced_meat',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_minced_meat',
          'quantity': 20,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_meat_box: Total 20
        {
          'id': 'warehouse_cairo_prod_meat_box',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_meat_box',
          'quantity': 12,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_meat_box',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_meat_box',
          'quantity': 8,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_chicken: Total 50
        {
          'id': 'warehouse_cairo_prod_chicken',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_chicken',
          'quantity': 25,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_chicken',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_chicken',
          'quantity': 15,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_giza_prod_chicken',
          'warehouseId': 'warehouse_giza',
          'productId': 'prod_chicken',
          'quantity': 10,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_frozen_burger: Total 40 (based on seed 2 current=20 + seed 3 current=10 + seed 1 default=10?)
        {
          'id': 'warehouse_cairo_prod_frozen_burger',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_frozen_burger',
          'quantity': 20,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_frozen_burger',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_frozen_burger',
          'quantity': 20,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_fresh_milk: Total 50
        {
          'id': 'warehouse_cairo_prod_fresh_milk',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_fresh_milk',
          'quantity': 40,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_fresh_milk',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_fresh_milk',
          'quantity': 10,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
      _prefs.setStringList(_inventoriesKey, seedInventories.map((e) => jsonEncode(e)).toList());
    }

    // 3. Seed Transfers (Empty initially)
    final transferList = _prefs.getStringList(_transfersKey) ?? [];
    if (transferList.isEmpty) {
      _prefs.setStringList(_transfersKey, []);
    }
  }

  // Helper getters
  List<WarehouseDto> _getWarehouses() {
    final list = _prefs.getStringList(_warehousesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return WarehouseDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  List<WarehouseInventoryDto> _getInventories() {
    final list = _prefs.getStringList(_inventoriesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return WarehouseInventoryDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  List<StockTransferDto> _getTransfers() {
    final list = _prefs.getStringList(_transfersKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return StockTransferDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveWarehouses(List<WarehouseDto> list) {
    _prefs.setStringList(_warehousesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _warehouseController.add(list.map((dto) => WarehouseModel.fromDto(dto).toEntity()).toList());
  }

  void _saveInventories(List<WarehouseInventoryDto> list) {
    _prefs.setStringList(_inventoriesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _inventoryController.add(list.map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity()).toList());
  }

  void _saveTransfers(List<StockTransferDto> list) {
    _prefs.setStringList(_transfersKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _transferController.add(list.map((dto) => StockTransferModel.fromDto(dto).toEntity()).toList());
  }

  // Dynamically sync global product stock
  void _syncProductGlobalStock(String productId) {
    final inventories = _getInventories().where((i) => i.productId == productId);
    final totalStock = inventories.fold<int>(0, (sum, item) => sum + item.quantity);

    final prodList = _prefs.getStringList(MockProductRepository.productsKey) ?? [];
    final products = prodList.map((e) {
      final map = mockDecodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();

    final idx = products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final old = products[idx];
      final updated = ProductDto(
        id: old.id,
        nameAr: old.nameAr,
        nameEn: old.nameEn,
        descriptionAr: old.descriptionAr,
        descriptionEn: old.descriptionEn,
        price: old.price,
        weight: old.weight,
        weightUnitId: old.weightUnitId,
        imageUrl: old.imageUrl,
        imageThumbUrl: old.imageThumbUrl,
        categoryId: old.categoryId,
        isFeatured: old.isFeatured,
        isAvailable: old.isAvailable,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        currentStock: totalStock,
        reservedStock: old.reservedStock,
        availableStock: totalStock - old.reservedStock,
        minimumStock: old.minimumStock,
        reorderLevel: old.reorderLevel,
      );
      products[idx] = updated;
      _prefs.setStringList(MockProductRepository.productsKey, products.map((p) => mockEncode(p.toMap()..['id'] = p.id)).toList());
    }
  }

  // WAREHOUSE CRUD
  @override
  Future<Result<List<WarehouseEntity>>> getWarehouses() async {
    final all = _getWarehouses().map((dto) => WarehouseModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<WarehouseEntity>> watchWarehouses() {
    Timer.run(() {
      final all = _getWarehouses().map((dto) => WarehouseModel.fromDto(dto).toEntity()).toList();
      _warehouseController.add(all);
    });
    return _warehouseController.stream;
  }

  @override
  Future<Result<WarehouseEntity>> createWarehouse(WarehouseEntity warehouse) async {
    final all = _getWarehouses();
    final newId = warehouse.id.isEmpty ? 'warehouse_${DateTime.now().millisecondsSinceEpoch}' : warehouse.id;
    final finalWh = warehouse.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(WarehouseModel.fromEntity(finalWh));
    _saveWarehouses(all);
    return Success(finalWh);
  }

  @override
  Future<Result<WarehouseEntity>> updateWarehouse(WarehouseEntity warehouse) async {
    final all = _getWarehouses();
    final idx = all.indexWhere((w) => w.id == warehouse.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Warehouse not found'));
    final finalWh = warehouse.copyWith(updatedAt: DateTime.now());
    all[idx] = WarehouseModel.fromEntity(finalWh);
    _saveWarehouses(all);
    return Success(finalWh);
  }

  @override
  Future<Result<void>> deleteWarehouse(String warehouseId) async {
    final all = _getWarehouses();
    all.removeWhere((w) => w.id == warehouseId);
    _saveWarehouses(all);

    // Delete related inventory too
    final inventories = _getInventories();
    inventories.removeWhere((i) => i.warehouseId == warehouseId);
    _saveInventories(inventories);

    return const Success(null);
  }

  // INVENTORY
  @override
  Future<Result<List<WarehouseInventoryEntity>>> getWarehouseInventories() async {
    final all = _getInventories().map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<WarehouseInventoryEntity>> watchWarehouseInventories() {
    Timer.run(() {
      final all = _getInventories().map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity()).toList();
      _inventoryController.add(all);
    });
    return _inventoryController.stream;
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForWarehouse(String warehouseId) async {
    final filtered = _getInventories()
        .where((i) => i.warehouseId == warehouseId)
        .map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity())
        .toList();
    return Success(filtered);
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForProduct(String productId) async {
    final filtered = _getInventories()
        .where((i) => i.productId == productId)
        .map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity())
        .toList();
    return Success(filtered);
  }

  @override
  Future<Result<WarehouseInventoryEntity>> updateInventoryQuantity(
    String warehouseId,
    String productId,
    int quantity,
  ) async {
    final all = _getInventories();
    final id = '${warehouseId}_$productId';
    final idx = all.indexWhere((i) => i.id == id);

    // Fetch product details for logging
    final prodList = _prefs.getStringList(MockProductRepository.productsKey) ?? [];
    final products = prodList.map((e) {
      final map = mockDecodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
    final prod = products.firstWhere((p) => p.id == productId, orElse: () => ProductDto(
      id: productId, nameAr: 'منتج غير معروف', nameEn: 'Unknown Product', price: 0.0, weight: 0.0, weightUnitId: 'unit', categoryId: '', isFeatured: false, isAvailable: true, createdAt: DateTime.now(), updatedAt: DateTime.now(), currentStock: 0, availableStock: 0,
    ));

    final oldQty = idx != -1 ? all[idx].quantity : 0;

    final newDto = WarehouseInventoryDto(
      id: id,
      warehouseId: warehouseId,
      productId: productId,
      quantity: quantity,
      createdAt: idx != -1 ? all[idx].createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (idx != -1) {
      all[idx] = newDto;
    } else {
      all.add(newDto);
    }
    _saveInventories(all);
    _syncProductGlobalStock(productId);

    // Log stock history
    mockLogStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: prod.nameAr,
      productNameEn: prod.nameEn,
      type: 'adjustment',
      quantityChanged: quantity - oldQty,
      previousStock: oldQty,
      newStock: quantity,
      reasonAr: 'تعديل مخزون المستودع المباشر',
      reasonEn: 'Direct warehouse inventory adjustment',
      createdBy: 'admin',
    );

    return Success(WarehouseInventoryModel.fromDto(newDto).toEntity());
  }

  // TRANSFERS
  @override
  Future<Result<List<StockTransferEntity>>> getStockTransfers() async {
    final all = _getTransfers().map((dto) => StockTransferModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<StockTransferEntity>> watchStockTransfers() {
    Timer.run(() {
      final all = _getTransfers().map((dto) => StockTransferModel.fromDto(dto).toEntity()).toList();
      _transferController.add(all);
    });
    return _transferController.stream;
  }

  @override
  Future<Result<StockTransferEntity>> transferStock({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    if (quantity <= 0) {
      return Failure(FirestoreException(message: 'Quantity must be greater than 0'));
    }
    if (fromWarehouseId == toWarehouseId) {
      return Failure(FirestoreException(message: 'Source and destination warehouses must be different'));
    }

    final inventories = _getInventories();
    final fromId = '${fromWarehouseId}_$productId';
    final toId = '${toWarehouseId}_$productId';

    final fromIdx = inventories.indexWhere((i) => i.id == fromId);
    final currentFromQty = fromIdx != -1 ? inventories[fromIdx].quantity : 0;

    if (currentFromQty < quantity) {
      return Failure(FirestoreException(message: 'Insufficient stock in source warehouse'));
    }

    // Deduct from source
    final updatedFrom = inventories[fromIdx].copyWith(
      quantity: currentFromQty - quantity,
      updatedAt: DateTime.now(),
    );
    inventories[fromIdx] = updatedFrom;

    // Add to destination
    final toIdx = inventories.indexWhere((i) => i.id == toId);
    final currentToQty = toIdx != -1 ? inventories[toIdx].quantity : 0;
    if (toIdx != -1) {
      inventories[toIdx] = inventories[toIdx].copyWith(
        quantity: currentToQty + quantity,
        updatedAt: DateTime.now(),
      );
    } else {
      inventories.add(WarehouseInventoryDto(
        id: toId,
        warehouseId: toWarehouseId,
        productId: productId,
        quantity: quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Save inventories
    _saveInventories(inventories);
    _syncProductGlobalStock(productId);

    // Save transfer record
    final transfers = _getTransfers();
    final transferId = 'transfer_${DateTime.now().millisecondsSinceEpoch}';
    final newTransfer = StockTransferDto(
      id: transferId,
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      productId: productId,
      quantity: quantity,
      transferDate: DateTime.now(),
      notes: notes,
      status: 'Completed',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    transfers.add(newTransfer);
    _saveTransfers(transfers);

    // Resolve Names for Logging
    final warehouses = _getWarehouses();
    final fromWh = warehouses.firstWhere((w) => w.id == fromWarehouseId, orElse: () => WarehouseDto(id: fromWarehouseId, nameAr: 'مستودع مصدر', nameEn: 'Source Wh', locationAr: '', locationEn: '', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()));
    final toWh = warehouses.firstWhere((w) => w.id == toWarehouseId, orElse: () => WarehouseDto(id: toWarehouseId, nameAr: 'مستودع هدف', nameEn: 'Target Wh', locationAr: '', locationEn: '', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()));

    final prodList = _prefs.getStringList(MockProductRepository.productsKey) ?? [];
    final products = prodList.map((e) {
      final map = mockDecodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
    final prod = products.firstWhere((p) => p.id == productId, orElse: () => ProductDto(
      id: productId, nameAr: 'منتج غير معروف', nameEn: 'Unknown Product', price: 0.0, weight: 0.0, weightUnitId: 'unit', categoryId: '', isFeatured: false, isAvailable: true, createdAt: DateTime.now(), updatedAt: DateTime.now(), currentStock: 0, availableStock: 0,
    ));

    // Log double entry stock histories
    mockLogStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: prod.nameAr,
      productNameEn: prod.nameEn,
      type: 'transfer_out',
      quantityChanged: -quantity,
      previousStock: currentFromQty,
      newStock: currentFromQty - quantity,
      reasonAr: 'نقل مخزون خارج إلى ${toWh.nameAr}',
      reasonEn: 'Transfer stock out to ${toWh.nameEn}',
      createdBy: 'admin',
    );

    mockLogStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: prod.nameAr,
      productNameEn: prod.nameEn,
      type: 'transfer_in',
      quantityChanged: quantity,
      previousStock: currentToQty,
      newStock: currentToQty + quantity,
      reasonAr: 'استلام مخزون من ${fromWh.nameAr}',
      reasonEn: 'Received stock transfer from ${fromWh.nameEn}',
      createdBy: 'admin',
    );

    return Success(StockTransferModel.fromDto(newTransfer).toEntity());
  }
}
