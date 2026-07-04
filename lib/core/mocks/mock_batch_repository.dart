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

class MockBatchRepository implements BatchRepository {
  static const String _batchesKey = 'mock_batches';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<BatchEntity>>.broadcast();

  MockBatchRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_batchesKey) ?? [];
    if (list.isEmpty) {
      final now = DateTime.now();
      final seedBatches = [
        {
          'id': 'batch_seed_1',
          'productId': 'prod_minced_meat',
          'batchCode': 'B-MEAT-001',
          'initialQuantity': 50,
          'currentQuantity': 30,
          'availableQuantity': 30,
          'reservedQuantity': 0,
          'unitCost': 40.0,
          'manufactureDate': now.subtract(const Duration(days: 10)).toIso8601String(),
          'expiryDate': now.add(const Duration(days: 20)).toIso8601String(),
          'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        },
        {
          'id': 'batch_seed_2',
          'productId': 'prod_frozen_burger',
          'batchCode': 'B-BURG-001',
          'initialQuantity': 40,
          'currentQuantity': 20,
          'availableQuantity': 20,
          'reservedQuantity': 0,
          'unitCost': 30.0,
          'manufactureDate': now.subtract(const Duration(days: 5)).toIso8601String(),
          'expiryDate': now.add(const Duration(days: 4)).toIso8601String(), // Near Expiry
          'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        },
        {
          'id': 'batch_seed_3',
          'productId': 'prod_frozen_burger',
          'batchCode': 'B-BURG-EXPIRED',
          'initialQuantity': 20,
          'currentQuantity': 10,
          'availableQuantity': 10,
          'reservedQuantity': 0,
          'unitCost': 30.0,
          'manufactureDate': now.subtract(const Duration(days: 30)).toIso8601String(),
          'expiryDate': now.subtract(const Duration(days: 2)).toIso8601String(), // Expired
          'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        }
      ];
      _prefs.setStringList(_batchesKey, seedBatches.map((e) => jsonEncode(e)).toList());
    }
  }

  List<BatchDto> _getBatches() {
    final list = _prefs.getStringList(_batchesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return BatchDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<BatchDto> list) {
    _prefs.setStringList(_batchesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => BatchModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<BatchEntity>>> getBatches() async {
    final all = _getBatches().map((dto) => BatchModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<BatchEntity>> watchBatches() {
    Timer.run(() {
      final all = _getBatches().map((dto) => BatchModel.fromDto(dto).toEntity()).toList();
      _controller.add(all);
    });
    return _controller.stream;
  }

  @override
  Future<Result<BatchEntity>> createBatch(BatchEntity batch) async {
    final all = _getBatches();
    final newId = batch.id.isEmpty ? 'batch_${DateTime.now().millisecondsSinceEpoch}' : batch.id;
    final finalBatch = batch.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(BatchModel.fromEntity(finalBatch));
    _saveAll(all);
    return Success(finalBatch);
  }

  @override
  Future<Result<BatchEntity>> updateBatch(BatchEntity batch) async {
    final all = _getBatches();
    final idx = all.indexWhere((b) => b.id == batch.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Batch not found'));
    final finalBatch = batch.copyWith(updatedAt: DateTime.now());
    all[idx] = BatchModel.fromEntity(finalBatch);
    _saveAll(all);
    return Success(finalBatch);
  }

  @override
  Future<Result<void>> deleteBatch(String batchId) async {
    final all = _getBatches();
    all.removeWhere((b) => b.id == batchId);
    _saveAll(all);
    return const Success(null);
  }
}
