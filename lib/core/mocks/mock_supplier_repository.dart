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

class MockSupplierRepository implements SupplierRepository {
  static const String _suppliersKey = 'mock_suppliers';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<SupplierEntity>>.broadcast();

  MockSupplierRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_suppliersKey) ?? [];
    if (list.isEmpty) {
      final seeds = [
        {
          'id': 'supplier_1',
          'name': 'Cairo Fresh Farm',
          'contactPerson': 'Ahmed Hassan',
          'phone': '01012345678',
          'email': 'cairo@freshfarm.com',
          'address': 'Obour Market, Cairo',
          'balance': 0.0,
          'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        },
        {
          'id': 'supplier_2',
          'name': 'Giza Meat Importers',
          'contactPerson': 'Mohamed Ibrahim',
          'phone': '01198765432',
          'email': 'giza@meatimports.com',
          'address': '6th of October City, Giza',
          'balance': 0.0,
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        }
      ];
      _prefs.setStringList(_suppliersKey, seeds.map((e) => jsonEncode(e)).toList());
    }
  }

  List<SupplierDto> _getSuppliers() {
    final list = _prefs.getStringList(_suppliersKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return SupplierDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<SupplierDto> list) {
    _prefs.setStringList(_suppliersKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => SupplierModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<SupplierEntity>>> getSuppliers() async {
    final list = _getSuppliers().map((dto) => SupplierModel.fromDto(dto).toEntity()).toList();
    return Success(list);
  }

  @override
  Stream<List<SupplierEntity>> watchSuppliers() {
    Timer.run(() {
      final list = _getSuppliers().map((dto) => SupplierModel.fromDto(dto).toEntity()).toList();
      _controller.add(list);
    });
    return _controller.stream;
  }

  @override
  Future<Result<SupplierEntity>> createSupplier(SupplierEntity supplier) async {
    final all = _getSuppliers();
    final newId = supplier.id.isEmpty ? 'supplier_${DateTime.now().millisecondsSinceEpoch}' : supplier.id;
    final finalSupplier = supplier.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(SupplierModel.fromEntity(finalSupplier));
    _saveAll(all);
    return Success(finalSupplier);
  }

  @override
  Future<Result<SupplierEntity>> updateSupplier(SupplierEntity supplier) async {
    final all = _getSuppliers();
    final idx = all.indexWhere((s) => s.id == supplier.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Supplier not found'));
    final finalSupplier = supplier.copyWith(updatedAt: DateTime.now());
    all[idx] = SupplierModel.fromEntity(finalSupplier);
    _saveAll(all);
    return Success(finalSupplier);
  }

  @override
  Future<Result<void>> deleteSupplier(String supplierId) async {
    final all = _getSuppliers();
    all.removeWhere((s) => s.id == supplierId);
    _saveAll(all);
    return const Success(null);
  }
}
