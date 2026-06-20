import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/warehouse.entity.dart';
import '../../domain/entities/warehouse_inventory.entity.dart';
import '../../domain/entities/stock_transfer.entity.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../dto/warehouse.dto.dart';
import '../dto/warehouse_inventory.dto.dart';
import '../dto/stock_transfer.dto.dart';
import '../models/warehouse_model.dart';
import '../models/warehouse_inventory_model.dart';
import '../models/stock_transfer_model.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final FirebaseFirestore _firestore;

  WarehouseRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _warehousesCol => _firestore.collection('warehouses');
  CollectionReference get _inventoriesCol => _firestore.collection('warehouse_inventories');
  CollectionReference get _transfersCol => _firestore.collection('stock_transfers');

  @override
  Future<Result<List<WarehouseEntity>>> getWarehouses() async {
    try {
      final snapshot = await _warehousesCol.orderBy(FirestoreConstants.createdAt, descending: true).get();
      final list = snapshot.docs.map((doc) {
        final dto = WarehouseDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return WarehouseModel.fromDto(dto).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<WarehouseEntity>> watchWarehouses() {
    return _warehousesCol
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = WarehouseDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return WarehouseModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<WarehouseEntity>> createWarehouse(WarehouseEntity warehouse) async {
    try {
      final docRef = await _warehousesCol.add(
        WarehouseModel.fromEntity(warehouse).toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      final doc = await docRef.get();
      final dto = WarehouseDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(WarehouseModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<WarehouseEntity>> updateWarehouse(WarehouseEntity warehouse) async {
    try {
      await _warehousesCol.doc(warehouse.id).update(
        WarehouseModel.fromEntity(warehouse).toMap()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      return Success(warehouse);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteWarehouse(String warehouseId) async {
    try {
      await _warehousesCol.doc(warehouseId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getWarehouseInventories() async {
    try {
      final snapshot = await _inventoriesCol.get();
      final list = snapshot.docs.map((doc) {
        final dto = WarehouseInventoryDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return WarehouseInventoryModel.fromDto(dto).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<WarehouseInventoryEntity>> watchWarehouseInventories() {
    return _inventoriesCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = WarehouseInventoryDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return WarehouseInventoryModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForWarehouse(String warehouseId) async {
    try {
      final snapshot = await _inventoriesCol.where('warehouseId', isEqualTo: warehouseId).get();
      final list = snapshot.docs.map((doc) {
        final dto = WarehouseInventoryDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return WarehouseInventoryModel.fromDto(dto).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForProduct(String productId) async {
    try {
      final snapshot = await _inventoriesCol.where('productId', isEqualTo: productId).get();
      final list = snapshot.docs.map((doc) {
        final dto = WarehouseInventoryDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return WarehouseInventoryModel.fromDto(dto).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<WarehouseInventoryEntity>> updateInventoryQuantity(
    String warehouseId,
    String productId,
    int quantity,
  ) async {
    try {
      final id = '${warehouseId}_$productId';
      final docRef = _inventoriesCol.doc(id);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'quantity': quantity,
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'warehouseId': warehouseId,
          'productId': productId,
          'quantity': quantity,
          FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        });
      }

      final updatedDoc = await docRef.get();
      final dto = WarehouseInventoryDto.fromMap(updatedDoc.data() as Map<String, dynamic>, updatedDoc.id);
      return Success(WarehouseInventoryModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<List<StockTransferEntity>>> getStockTransfers() async {
    try {
      final snapshot = await _transfersCol.orderBy(FirestoreConstants.createdAt, descending: true).get();
      final list = snapshot.docs.map((doc) {
        final dto = StockTransferDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return StockTransferModel.fromDto(dto).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<StockTransferEntity>> watchStockTransfers() {
    return _transfersCol
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = StockTransferDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return StockTransferModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<StockTransferEntity>> transferStock({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    try {
      // Implement Firestore transactions for safety
      final result = await _firestore.runTransaction((transaction) async {
        final fromId = '${fromWarehouseId}_$productId';
        final toId = '${toWarehouseId}_$productId';

        final fromDocRef = _inventoriesCol.doc(fromId);
        final toDocRef = _inventoriesCol.doc(toId);

        final fromDoc = await transaction.get(fromDocRef);
        final currentFromQty = fromDoc.exists ? (fromDoc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0 : 0;

        if (currentFromQty < quantity) {
          throw Exception('Insufficient stock in source warehouse');
        }

        final toDoc = await transaction.get(toDocRef);
        final currentToQty = toDoc.exists ? (toDoc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0 : 0;

        transaction.set(fromDocRef, {
          'warehouseId': fromWarehouseId,
          'productId': productId,
          'quantity': currentFromQty - quantity,
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(toDocRef, {
          'warehouseId': toWarehouseId,
          'productId': productId,
          'quantity': currentToQty + quantity,
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final transferDocRef = _transfersCol.doc();
        final transferMap = {
          'fromWarehouseId': fromWarehouseId,
          'toWarehouseId': toWarehouseId,
          'productId': productId,
          'quantity': quantity,
          'transferDate': DateTime.now().toIso8601String(),
          'notes': notes,
          'status': 'Completed',
          FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        };

        transaction.set(transferDocRef, transferMap);

        return StockTransferDto(
          id: transferDocRef.id,
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
      });

      return Success(StockTransferModel.fromDto(result).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
