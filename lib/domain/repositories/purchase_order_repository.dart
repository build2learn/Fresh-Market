import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/purchase_order.entity.dart';

abstract interface class PurchaseOrderRepository {
  Future<Result<List<PurchaseOrderEntity>>> getPurchaseOrders({String? supplierId, String? status});
  Stream<List<PurchaseOrderEntity>> watchPurchaseOrders({String? supplierId, String? status});
  Future<Result<PurchaseOrderEntity>> createPurchaseOrder(PurchaseOrderEntity po);
  Future<Result<PurchaseOrderEntity>> updatePurchaseOrder(PurchaseOrderEntity po);
  Future<Result<void>> updatePurchaseOrderStatus(String poId, String status);
  Future<Result<void>> receivePurchaseOrderItems(String poId, List<PurchaseOrderItemEntity> receivedItems);
  Future<Result<void>> deletePurchaseOrder(String poId);
}
