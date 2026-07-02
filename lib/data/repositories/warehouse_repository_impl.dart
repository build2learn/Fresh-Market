import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth;

  WarehouseRepositoryImpl({
    required FirebaseFirestore firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth ?? FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? 'system';

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
      return Success(warehouse.copyWith(id: docRef.id));
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
      await _firestore.runTransaction((transaction) async {
        // Check for inventory records with stock > 0
        final inventorySnap = await _inventoriesCol
            .where('warehouseId', isEqualTo: warehouseId)
            .get();

        for (final doc in inventorySnap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final qty = data['quantity'] as int? ?? 0;
          if (qty > 0) {
            throw FirestoreException(
              message: 'Cannot delete warehouse with active inventory (product has $qty units)',
            );
          }
        }

        // Clean up zero-quantity inventory docs
        for (final doc in inventorySnap.docs) {
          transaction.delete(doc.reference);
        }

        // Delete the warehouse itself
        transaction.delete(_warehousesCol.doc(warehouseId));
      });
      return const Success(null);
    } on FirestoreException catch (e) {
      return Failure(e);
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
    if (quantity < 0) {
      return Failure(FirestoreException(message: 'Inventory quantity cannot be negative'));
    }
    try {
      final id = '${warehouseId}_$productId';
      final docRef = _inventoriesCol.doc(id);
      final productRef = _firestore.collection(FirestoreConstants.products).doc(productId);

      final result = await _firestore.runTransaction((transaction) async {
        final invDoc = await transaction.get(docRef);
        final productDoc = await transaction.get(productRef);

        final oldQuantity = invDoc.exists
            ? ((invDoc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0)
            : 0;
        final delta = quantity - oldQuantity;

        // Validate product stock won't go negative
        if (productDoc.exists && delta < 0) {
          final pData = productDoc.data() as Map<String, dynamic>;
          final avStock = pData['availableStock'] as int? ?? pData['stockQuantity'] as int? ?? 0;
          if (avStock + delta < 0) {
            throw FirestoreException(
              message: 'Cannot reduce warehouse stock: would cause negative available stock',
            );
          }
        }

        // Update warehouse inventory
        if (invDoc.exists) {
          transaction.update(docRef, {
            'quantity': quantity,
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(docRef, {
            'warehouseId': warehouseId,
            'productId': productId,
            'quantity': quantity,
            FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        }

        // Sync global product stock if product exists and delta != 0
        if (productDoc.exists && delta != 0) {
          transaction.update(productRef, {
            'currentStock': FieldValue.increment(delta),
            'availableStock': FieldValue.increment(delta),
            'stockQuantity': FieldValue.increment(delta), // legacy sync
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        }

        // Audit: Log stock_history for warehouse inventory change
        if (delta != 0) {
          final pData = productDoc.exists ? productDoc.data() as Map<String, dynamic> : <String, dynamic>{};
          final historyRef = _firestore.collection('stock_history').doc();
          transaction.set(historyRef, {
            'id': historyRef.id,
            'productId': productId,
            'productNameAr': pData['nameAr'] as String? ?? '',
            'productNameEn': pData['nameEn'] as String? ?? '',
            'warehouseId': warehouseId,
            'type': 'warehouse_adjustment',
            'quantityChanged': delta,
            'previousStock': oldQuantity,
            'newStock': quantity,
            'reasonAr': 'تعديل مخزون المستودع',
            'reasonEn': 'Warehouse inventory adjustment',
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': _currentUserId,
          });
        }

        return WarehouseInventoryEntity(
          id: id,
          warehouseId: warehouseId,
          productId: productId,
          quantity: quantity,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      return Success(result);
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
    if (quantity <= 0) {
      return Failure(FirestoreException(message: 'Transfer quantity must be greater than zero'));
    }
    if (fromWarehouseId == toWarehouseId) {
      return Failure(FirestoreException(message: 'Source and destination warehouses must be different'));
    }
    try {
      final result = await _firestore.runTransaction((transaction) async {
        final fromId = '${fromWarehouseId}_$productId';
        final toId = '${toWarehouseId}_$productId';

        final fromDocRef = _inventoriesCol.doc(fromId);
        final toDocRef = _inventoriesCol.doc(toId);

        final fromDoc = await transaction.get(fromDocRef);
        final currentFromQty = fromDoc.exists ? (fromDoc.data() as Map<String, dynamic>)['quantity'] as int? ?? 0 : 0;

        if (currentFromQty < quantity) {
          throw Exception('Insufficient stock in source warehouse (available: $currentFromQty, requested: $quantity)');
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
          'transferDate': FieldValue.serverTimestamp(),
          'notes': notes,
          'status': 'Completed',
          FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        };

        transaction.set(transferDocRef, transferMap);

        // Log stock_history for source warehouse (outbound)
        final historyOutRef = _firestore.collection('stock_history').doc();
        transaction.set(historyOutRef, {
          'id': historyOutRef.id,
          'productId': productId,
          'warehouseId': fromWarehouseId,
          'transferId': transferDocRef.id,
          'type': 'transfer_out',
          'quantityChanged': -quantity,
          'previousStock': currentFromQty,
          'newStock': currentFromQty - quantity,
          'reasonEn': 'Transferred out to warehouse $toWarehouseId',
          'reasonAr': 'تم النقل إلى مستودع $toWarehouseId',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _currentUserId,
        });

        // Log stock_history for destination warehouse (inbound)
        final historyInRef = _firestore.collection('stock_history').doc();
        transaction.set(historyInRef, {
          'id': historyInRef.id,
          'productId': productId,
          'warehouseId': toWarehouseId,
          'transferId': transferDocRef.id,
          'type': 'transfer_in',
          'quantityChanged': quantity,
          'previousStock': currentToQty,
          'newStock': currentToQty + quantity,
          'reasonEn': 'Received transfer from warehouse $fromWarehouseId',
          'reasonAr': 'تم الاستلام من مستودع $fromWarehouseId',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _currentUserId,
        });

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
