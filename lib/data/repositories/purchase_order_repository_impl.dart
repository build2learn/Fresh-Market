import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/purchase_order.entity.dart';
import '../../domain/repositories/purchase_order_repository.dart';
import '../dto/purchase_order.dto.dart';
import '../models/purchase_order_model.dart';

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final FirebaseFirestore _firestore;

  PurchaseOrderRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posCol => _firestore.collection('purchase_orders');
  CollectionReference get _productsCol => _firestore.collection(FirestoreConstants.products);

  @override
  Future<Result<List<PurchaseOrderEntity>>> getPurchaseOrders({String? supplierId, String? status}) async {
    try {
      Query query = _posCol.orderBy(FirestoreConstants.createdAt, descending: true);
      if (supplierId != null && supplierId.isNotEmpty) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        query = query.where('status', isEqualTo: status);
      }
      final snapshot = await query.get();
      final pos = snapshot.docs.map((doc) {
        final dto = PurchaseOrderDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return PurchaseOrderModel.fromDto(dto).toEntity();
      }).toList();
      return Success(pos);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<PurchaseOrderEntity>> watchPurchaseOrders({String? supplierId, String? status}) {
    Query query = _posCol.orderBy(FirestoreConstants.createdAt, descending: true);
    if (supplierId != null && supplierId.isNotEmpty) {
      query = query.where('supplierId', isEqualTo: supplierId);
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = PurchaseOrderDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return PurchaseOrderModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<PurchaseOrderEntity>> createPurchaseOrder(PurchaseOrderEntity po) async {
    try {
      final docRef = await _posCol.add(
        PurchaseOrderModel.fromEntity(po).toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      final doc = await docRef.get();
      final dto = PurchaseOrderDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(PurchaseOrderModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<PurchaseOrderEntity>> updatePurchaseOrder(PurchaseOrderEntity po) async {
    try {
      await _posCol.doc(po.id).update(
        PurchaseOrderModel.fromEntity(po).toMap()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      return Success(po);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updatePurchaseOrderStatus(String poId, String status) async {
    try {
      await _posCol.doc(poId).update({
        'status': status,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> receivePurchaseOrderItems(String poId, List<PurchaseOrderItemEntity> receivedItems) async {
    try {
      final poDoc = await _posCol.doc(poId).get();
      if (!poDoc.exists) {
        return Failure(FirestoreException(message: 'Purchase Order not found'));
      }
      final poData = poDoc.data() as Map<String, dynamic>;
      final supplierId = poData['supplierId'] as String? ?? '';

      await _firestore.runTransaction((transaction) async {
        // Read Phase: Get all product documents for accurate stock tracking
        final productSnapshots = <String, DocumentSnapshot>{};
        for (final item in receivedItems) {
          final prodRef = _productsCol.doc(item.productId);
          productSnapshots[item.productId] = await transaction.get(prodRef);
        }

        double poCost = 0.0;

        // Write Phase: Update products, create batches, log history
        for (final item in receivedItems) {
          if (item.quantityReceived <= 0) continue;

          final prodRef = _productsCol.doc(item.productId);
          final prodSnap = productSnapshots[item.productId]!;
          final prodData = prodSnap.exists ? prodSnap.data() as Map<String, dynamic> : <String, dynamic>{};

          final curStock = prodData['currentStock'] as int? ?? prodData['stockQuantity'] as int? ?? 0;
          final avStock = prodData['availableStock'] as int? ?? prodData['stockQuantity'] as int? ?? curStock;
          final newCurrent = curStock + item.quantityReceived;
          final newAvailable = avStock + item.quantityReceived;

          transaction.update(prodRef, {
            'currentStock': newCurrent,
            'availableStock': newAvailable,
            'stockQuantity': newAvailable, // legacy sync
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });

          poCost += item.quantityReceived * item.unitCost;

          // Create batch document in the batches collection
          final batchRef = _firestore.collection('batches').doc();
          final batchCode = (item.batchCode != null && item.batchCode!.isNotEmpty)
              ? item.batchCode!
              : 'B-PO-$poId-${item.productId}';
          final expiryDate = item.expiryDate ?? DateTime.now().add(const Duration(days: 30));

          transaction.set(batchRef, {
            'productId': item.productId,
            'batchCode': batchCode,
            'initialQuantity': item.quantityReceived,
            'currentQuantity': item.quantityReceived,
            'availableQuantity': item.quantityReceived,
            'reservedQuantity': 0,
            'unitCost': item.unitCost,
            'manufactureDate': FieldValue.serverTimestamp(),
            'expiryDate': Timestamp.fromDate(expiryDate),
            FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });

          // Write accurate stock history
          final historyRef = _firestore.collection('stock_history').doc();
          transaction.set(historyRef, {
            'id': historyRef.id,
            'productId': item.productId,
            'productNameAr': prodData['nameAr'] as String? ?? '',
            'productNameEn': item.productName,
            'type': 'receipt',
            'quantityChanged': item.quantityReceived,
            'previousStock': curStock,
            'newStock': newCurrent,
            'batchCode': batchCode,
            'reasonAr': 'تم استلام المنتجات عبر أمر الشراء $poId',
            'reasonEn': 'Received via purchase order $poId',
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': 'system',
          });
        }

        // Update PO status and items
        final poRef = _posCol.doc(poId);
        final rawItems = receivedItems.map((e) => {
          'productId': e.productId,
          'productName': e.productName,
          'quantityOrdered': e.quantityOrdered,
          'quantityReceived': e.quantityReceived,
          'unitCost': e.unitCost,
        }).toList();

        transaction.update(poRef, {
          'status': 'Received',
          'items': rawItems,
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        });

        // Update supplier balance
        if (supplierId.isNotEmpty && poCost > 0) {
          final supplierRef = _firestore.collection('suppliers').doc(supplierId);
          transaction.update(supplierRef, {
            'balance': FieldValue.increment(poCost),
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        }
      });

      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePurchaseOrder(String poId) async {
    try {
      final poDoc = await _posCol.doc(poId).get();
      if (poDoc.exists) {
        final poData = poDoc.data() as Map<String, dynamic>;
        final status = poData['status'] as String? ?? 'Pending';
        final supplierId = poData['supplierId'] as String? ?? '';
        
        final batch = _firestore.batch();
        batch.delete(_posCol.doc(poId));
        
        if (status == 'Received' && supplierId.isNotEmpty) {
          final itemsRaw = poData['items'] as List? ?? [];
          double poCost = 0.0;
          for (final itemMap in itemsRaw) {
            final qtyRec = itemMap['quantityReceived'] as int? ?? 0;
            final cost = (itemMap['unitCost'] as num?)?.toDouble() ?? 0.0;
            poCost += qtyRec * cost;
          }
          if (poCost > 0) {
            final supplierRef = _firestore.collection('suppliers').doc(supplierId);
            batch.update(supplierRef, {
              'balance': FieldValue.increment(-poCost),
              FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
            });
          }
        }
        await batch.commit();
      }
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
