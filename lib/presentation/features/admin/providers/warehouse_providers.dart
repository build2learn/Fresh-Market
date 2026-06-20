import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/warehouse.entity.dart';
import '../../../../domain/entities/warehouse_inventory.entity.dart';
import '../../../../domain/entities/stock_transfer.entity.dart';
import '../../../../data/providers/warehouse_repository_provider.dart';
import '../../../../core/utils/result.dart';

final warehousesListStreamProvider = StreamProvider.autoDispose<List<WarehouseEntity>>((ref) {
  final repo = ref.watch(warehouseRepositoryProvider);
  return repo.watchWarehouses();
});

final warehouseInventoriesStreamProvider = StreamProvider.autoDispose<List<WarehouseInventoryEntity>>((ref) {
  final repo = ref.watch(warehouseRepositoryProvider);
  return repo.watchWarehouseInventories();
});

final stockTransfersStreamProvider = StreamProvider.autoDispose<List<StockTransferEntity>>((ref) {
  final repo = ref.watch(warehouseRepositoryProvider);
  return repo.watchStockTransfers();
});

final selectedWarehouseIdProvider = StateProvider<String?>((ref) => null);

class WarehouseNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  WarehouseNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createWarehouse(WarehouseEntity warehouse) async {
    state = const AsyncValue.loading();
    final repo = _ref.read(warehouseRepositoryProvider);
    final result = await repo.createWarehouse(warehouse);
    if (result is Success<WarehouseEntity>) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error((result as Failure).error, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateWarehouse(WarehouseEntity warehouse) async {
    state = const AsyncValue.loading();
    final repo = _ref.read(warehouseRepositoryProvider);
    final result = await repo.updateWarehouse(warehouse);
    if (result is Success<WarehouseEntity>) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error((result as Failure).error, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteWarehouse(String id) async {
    state = const AsyncValue.loading();
    final repo = _ref.read(warehouseRepositoryProvider);
    final result = await repo.deleteWarehouse(id);
    if (result is Success<void>) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error((result as Failure).error, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateInventory(String warehouseId, String productId, int quantity) async {
    state = const AsyncValue.loading();
    final repo = _ref.read(warehouseRepositoryProvider);
    final result = await repo.updateInventoryQuantity(warehouseId, productId, quantity);
    if (result is Success<WarehouseInventoryEntity>) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error((result as Failure).error, StackTrace.current);
      return false;
    }
  }

  Future<bool> transferStock({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    final repo = _ref.read(warehouseRepositoryProvider);
    final result = await repo.transferStock(
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      productId: productId,
      quantity: quantity,
      notes: notes,
    );
    if (result is Success<StockTransferEntity>) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      state = AsyncValue.error((result as Failure).error, StackTrace.current);
      return false;
    }
  }
}

final warehouseNotifierProvider = StateNotifierProvider<WarehouseNotifier, AsyncValue<void>>((ref) {
  return WarehouseNotifier(ref);
});
