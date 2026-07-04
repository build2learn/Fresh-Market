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

class MockPurchaseOrderRepository implements PurchaseOrderRepository {
  static const String _posKey = 'mock_purchase_orders';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<PurchaseOrderEntity>>.broadcast();

  MockPurchaseOrderRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_posKey) ?? [];
    if (list.isEmpty) {
      final seeds = [
        {
          'id': 'po_1',
          'supplierId': 'supplier_1',
          'supplierName': 'Cairo Fresh Farm',
          'status': 'Ordered',
          'items': [
            {
              'productId': 'prod_chicken',
              'productName': 'Fresh Chicken',
              'quantityOrdered': 20,
              'quantityReceived': 0,
            }
          ],
          'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        }
      ];
      _prefs.setStringList(_posKey, seeds.map((e) => jsonEncode(e)).toList());
    }
  }

  List<PurchaseOrderDto> _getPurchaseOrders() {
    final list = _prefs.getStringList(_posKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return PurchaseOrderDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<PurchaseOrderDto> list) {
    _prefs.setStringList(_posKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => PurchaseOrderModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<PurchaseOrderEntity>>> getPurchaseOrders({String? supplierId, String? status}) async {
    var list = _getPurchaseOrders().map((dto) => PurchaseOrderModel.fromDto(dto).toEntity()).toList();
    if (supplierId != null && supplierId.isNotEmpty) {
      list = list.where((po) => po.supplierId == supplierId).toList();
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      list = list.where((po) => po.status == status).toList();
    }
    return Success(list);
  }

  @override
  Stream<List<PurchaseOrderEntity>> watchPurchaseOrders({String? supplierId, String? status}) {
    Timer.run(() {
      var list = _getPurchaseOrders().map((dto) => PurchaseOrderModel.fromDto(dto).toEntity()).toList();
      if (supplierId != null && supplierId.isNotEmpty) {
        list = list.where((po) => po.supplierId == supplierId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        list = list.where((po) => po.status == status).toList();
      }
      _controller.add(list);
    });
    return _controller.stream.map((all) {
      var list = all;
      if (supplierId != null && supplierId.isNotEmpty) {
        list = list.where((po) => po.supplierId == supplierId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        list = list.where((po) => po.status == status).toList();
      }
      return list;
    });
  }

  @override
  Future<Result<PurchaseOrderEntity>> createPurchaseOrder(PurchaseOrderEntity po) async {
    final all = _getPurchaseOrders();
    final newId = po.id.isEmpty ? 'po_${DateTime.now().millisecondsSinceEpoch}' : po.id;
    final finalPo = po.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(PurchaseOrderModel.fromEntity(finalPo));
    _saveAll(all);
    return Success(finalPo);
  }

  @override
  Future<Result<PurchaseOrderEntity>> updatePurchaseOrder(PurchaseOrderEntity po) async {
    final all = _getPurchaseOrders();
    final idx = all.indexWhere((p) => p.id == po.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Purchase Order not found'));
    final finalPo = po.copyWith(updatedAt: DateTime.now());
    all[idx] = PurchaseOrderModel.fromEntity(finalPo);
    _saveAll(all);
    return Success(finalPo);
  }

  @override
  Future<Result<void>> updatePurchaseOrderStatus(String poId, String status) async {
    final all = _getPurchaseOrders();
    final idx = all.indexWhere((p) => p.id == poId);
    if (idx == -1) return Failure(FirestoreException(message: 'Purchase Order not found'));
    
    final currentPoDto = all[idx];
    final currentPo = PurchaseOrderModel.fromDto(currentPoDto).toEntity();
    final oldStatus = currentPo.status;
    final updatedPo = currentPo.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    
    all[idx] = PurchaseOrderModel.fromEntity(updatedPo);
    _saveAll(all);
    
    if (status == 'Received' && oldStatus != 'Received') {
      double poCost = 0.0;
      final updatedItems = <PurchaseOrderItemEntity>[];
      try {
        final prodList = _prefs.getStringList('mock_products') ?? [];
        final updatedProds = prodList.map((e) {
          final map = jsonDecode(e) as Map<String, dynamic>;
          final prodId = map['id'] as String? ?? '';
          final matchedItem = currentPo.items.firstWhere((item) => item.productId == prodId, orElse: () => const PurchaseOrderItemEntity(productId: '', productName: '', quantityOrdered: 0, quantityReceived: 0));
          if (matchedItem.productId.isNotEmpty) {
            final qtyToReceive = matchedItem.quantityReceived > 0 ? 0 : matchedItem.quantityOrdered;
            if (qtyToReceive > 0) {
              final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 0;
              final av = map['availableStock'] as int? ?? map['stockQuantity'] as int? ?? 0;
              map['currentStock'] = cur + qtyToReceive;
              map['availableStock'] = av + qtyToReceive;
              map['stockQuantity'] = av + qtyToReceive;
              
              updatedItems.add(matchedItem.copyWith(quantityReceived: qtyToReceive));
              poCost += qtyToReceive * matchedItem.unitCost;
              
              // Log stock history
              mockLogStockHistory(
                prefs: _prefs,
                productId: prodId,
                productNameAr: map['nameAr'] as String? ?? '',
                productNameEn: map['nameEn'] as String? ?? map['name'] as String? ?? '',
                type: 'receipt',
                quantityChanged: qtyToReceive,
                previousStock: cur,
                newStock: cur + qtyToReceive,
                reasonAr: 'تم استلام المنتجات عبر أمر الشراء $poId',
                reasonEn: 'Received via purchase order $poId',
                createdBy: 'system',
              );
            } else {
              updatedItems.add(matchedItem);
              poCost += matchedItem.quantityReceived * matchedItem.unitCost;
            }
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_products', updatedProds);
      } catch (_) {}
      
      // Update PO items with quantityReceived if they were not set
      if (updatedItems.isNotEmpty) {
        final finalPo = updatedPo.copyWith(items: updatedItems);
        all[idx] = PurchaseOrderModel.fromEntity(finalPo);
        _saveAll(all);
      }

      // Increment supplier balance
      if (poCost > 0) {
        try {
          final supplierList = _prefs.getStringList('mock_suppliers') ?? [];
          final updatedSuppliers = supplierList.map((s) {
            final map = jsonDecode(s) as Map<String, dynamic>;
            if (map['id'] == currentPo.supplierId) {
              final curBal = (map['balance'] as num?)?.toDouble() ?? 0.0;
              map['balance'] = curBal + poCost;
            }
            return jsonEncode(map);
          }).toList();
          _prefs.setStringList('mock_suppliers', updatedSuppliers);
        } catch (_) {}
      }
    }
    
    return const Success(null);
  }

  @override
  Future<Result<void>> receivePurchaseOrderItems(String poId, List<PurchaseOrderItemEntity> receivedItems) async {
    final all = _getPurchaseOrders();
    final idx = all.indexWhere((p) => p.id == poId);
    if (idx == -1) return Failure(FirestoreException(message: 'Purchase Order not found'));
    
    final currentPoDto = all[idx];
    final currentPo = PurchaseOrderModel.fromDto(currentPoDto).toEntity();
    
    final updatedItems = currentPo.items.map((item) {
      final matched = receivedItems.firstWhere((ri) => ri.productId == item.productId, orElse: () => item);
      return item.copyWith(
        quantityReceived: matched.quantityReceived,
        unitCost: matched.unitCost > 0 ? matched.unitCost : item.unitCost,
      );
    }).toList();
    
    final updatedPo = currentPo.copyWith(
      status: 'Received',
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    
    all[idx] = PurchaseOrderModel.fromEntity(updatedPo);
    _saveAll(all);
    
    try {
      final prodList = _prefs.getStringList('mock_products') ?? [];
      final updatedProds = prodList.map((e) {
        final map = jsonDecode(e) as Map<String, dynamic>;
        final prodId = map['id'] as String? ?? '';
        final matchedItem = receivedItems.firstWhere((item) => item.productId == prodId, orElse: () => const PurchaseOrderItemEntity(productId: '', productName: '', quantityOrdered: 0, quantityReceived: 0));
        if (matchedItem.productId.isNotEmpty && matchedItem.quantityReceived > 0) {
          final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 0;
          final av = map['availableStock'] as int? ?? map['stockQuantity'] as int? ?? 0;
          map['currentStock'] = cur + matchedItem.quantityReceived;
          map['availableStock'] = av + matchedItem.quantityReceived;
          map['stockQuantity'] = av + matchedItem.quantityReceived;
          
          // Create batch record
          try {
            final batchList = _prefs.getStringList('mock_batches') ?? [];
            final bCode = (matchedItem.batchCode != null && matchedItem.batchCode!.isNotEmpty)
                ? matchedItem.batchCode!
                : 'B-${poId.replaceAll('po_', '')}-${prodId.replaceAll('prod_', '')}';
            final expDate = matchedItem.expiryDate ?? DateTime.now().add(const Duration(days: 30));
            final newBatchMap = {
              'id': 'batch_${DateTime.now().millisecondsSinceEpoch}_${prodId}',
              'productId': prodId,
              'batchCode': bCode,
              'initialQuantity': matchedItem.quantityReceived,
              'currentQuantity': matchedItem.quantityReceived,
              'availableQuantity': matchedItem.quantityReceived,
              'reservedQuantity': 0,
              'unitCost': matchedItem.unitCost,
              'manufactureDate': DateTime.now().toIso8601String(),
              'expiryDate': expDate.toIso8601String(),
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            };
            batchList.add(jsonEncode(newBatchMap));
            _prefs.setStringList('mock_batches', batchList);
          } catch (e) {
            debugPrint('[MOCK RECEIVE] Error creating batch: $e');
          }
          
          // Log stock movement to history (Goods Receiving)
          mockLogStockHistory(
            prefs: _prefs,
            productId: prodId,
            productNameAr: map['nameAr'] as String? ?? '',
            productNameEn: map['nameEn'] as String? ?? map['name'] as String? ?? '',
            type: 'receipt',
            quantityChanged: matchedItem.quantityReceived,
            previousStock: cur,
            newStock: cur + matchedItem.quantityReceived,
            reasonAr: 'تم استلام المنتجات عبر أمر الشراء $poId',
            reasonEn: 'Received via purchase order $poId',
            createdBy: 'system',
          );
        }
        return jsonEncode(map);
      }).toList();
      _prefs.setStringList('mock_products', updatedProds);
    } catch (_) {}

    // Increment supplier's outstanding balance
    try {
      double poCost = 0.0;
      for (final item in updatedItems) {
        poCost += item.quantityReceived * item.unitCost;
      }
      if (poCost > 0) {
        final supplierList = _prefs.getStringList('mock_suppliers') ?? [];
        final updatedSuppliers = supplierList.map((s) {
          final map = jsonDecode(s) as Map<String, dynamic>;
          if (map['id'] == currentPo.supplierId) {
            final curBal = (map['balance'] as num?)?.toDouble() ?? 0.0;
            map['balance'] = curBal + poCost;
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_suppliers', updatedSuppliers);
      }
    } catch (_) {}
    
    return const Success(null);
  }

  @override
  Future<Result<void>> deletePurchaseOrder(String poId) async {
    final all = _getPurchaseOrders();
    final idx = all.indexWhere((p) => p.id == poId);
    if (idx != -1) {
      final po = PurchaseOrderModel.fromDto(all[idx]).toEntity();
      if (po.status == 'Received') {
        double poCost = 0.0;
        for (final item in po.items) {
          poCost += item.quantityReceived * item.unitCost;
        }
        if (poCost > 0) {
          try {
            final supplierList = _prefs.getStringList('mock_suppliers') ?? [];
            final updatedSuppliers = supplierList.map((s) {
              final map = jsonDecode(s) as Map<String, dynamic>;
              if (map['id'] == po.supplierId) {
                final curBal = (map['balance'] as num?)?.toDouble() ?? 0.0;
                map['balance'] = curBal - poCost;
              }
              return jsonEncode(map);
            }).toList();
            _prefs.setStringList('mock_suppliers', updatedSuppliers);
          } catch (_) {}
        }
      }
      all.removeAt(idx);
      _saveAll(all);
    }
    return const Success(null);
  }
}
