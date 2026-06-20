import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/warehouse.entity.dart';
import '../entities/warehouse_inventory.entity.dart';
import '../entities/stock_transfer.entity.dart';

abstract interface class WarehouseRepository {
  Future<Result<List<WarehouseEntity>>> getWarehouses();
  Stream<List<WarehouseEntity>> watchWarehouses();
  Future<Result<WarehouseEntity>> createWarehouse(WarehouseEntity warehouse);
  Future<Result<WarehouseEntity>> updateWarehouse(WarehouseEntity warehouse);
  Future<Result<void>> deleteWarehouse(String warehouseId);

  Future<Result<List<WarehouseInventoryEntity>>> getWarehouseInventories();
  Stream<List<WarehouseInventoryEntity>> watchWarehouseInventories();
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForWarehouse(String warehouseId);
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForProduct(String productId);
  Future<Result<WarehouseInventoryEntity>> updateInventoryQuantity(String warehouseId, String productId, int quantity);

  Future<Result<List<StockTransferEntity>>> getStockTransfers();
  Stream<List<StockTransferEntity>> watchStockTransfers();
  Future<Result<StockTransferEntity>> transferStock({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
    String? notes,
  });
}
