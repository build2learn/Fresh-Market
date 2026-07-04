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

class MockWeightUnitRepository implements WeightUnitRepository {
  static const String _unitsKey = 'mock_weight_units';
  final SharedPreferences _prefs;

  MockWeightUnitRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_unitsKey) ?? [];
    if (list.isEmpty) {
      final u1 = WeightUnitDto(
        id: 'gram',
        nameAr: 'جرام',
        nameEn: 'Gram',
        abbr: 'جم',
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final u2 = WeightUnitDto(
        id: 'kg',
        nameAr: 'كيلوجرام',
        nameEn: 'Kilogram',
        abbr: 'كجم',
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final u3 = WeightUnitDto(
        id: 'box',
        nameAr: 'صندوق',
        nameEn: 'Box',
        abbr: 'صندوق',
        sortOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final u4 = WeightUnitDto(
        id: 'pc',
        nameAr: 'قطعة',
        nameEn: 'Piece',
        abbr: 'قطعة',
        sortOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _saveAll([u1, u2, u3, u4]);
    }
  }

  List<WeightUnitDto> _getUnits() {
    final list = _prefs.getStringList(_unitsKey) ?? [];
    return list.map((e) {
      final map = mockDecodeMap(e);
      return WeightUnitDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<WeightUnitDto> units) {
    _prefs.setStringList(_unitsKey, units.map((u) => mockEncode(u.toMap()..['id'] = u.id)).toList());
  }

  @override
  Future<Result<List<WeightUnitEntity>>> getWeightUnits() async {
    final list = _getUnits().map((u) => WeightUnitModel.fromDto(u).toEntity()).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Success(list);
  }

  @override
  Future<Result<WeightUnitEntity>> createWeightUnit(WeightUnitEntity unit) async {
    final all = _getUnits();
    final newId = unit.id.isEmpty ? 'unit_${DateTime.now().millisecondsSinceEpoch}' : unit.id;
    final dto = WeightUnitDto(
      id: newId,
      nameAr: unit.nameAr,
      nameEn: unit.nameEn,
      abbr: unit.abbr,
      sortOrder: unit.sortOrder == 0 ? all.length : unit.sortOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(dto);
    _saveAll(all);
    return Success(WeightUnitModel.fromDto(dto).toEntity());
  }

  @override
  Future<Result<WeightUnitEntity>> updateWeightUnit(WeightUnitEntity unit) async {
    final all = _getUnits();
    final idx = all.indexWhere((u) => u.id == unit.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Weight unit not found'));
    final dto = WeightUnitDto(
      id: unit.id,
      nameAr: unit.nameAr,
      nameEn: unit.nameEn,
      abbr: unit.abbr,
      sortOrder: unit.sortOrder,
      createdAt: all[idx].createdAt,
      updatedAt: DateTime.now(),
    );
    all[idx] = dto;
    _saveAll(all);
    return Success(WeightUnitModel.fromDto(dto).toEntity());
  }

  @override
  Future<Result<void>> deleteWeightUnit(String id) async {
    final all = _getUnits();
    all.removeWhere((u) => u.id == id);
    _saveAll(all);
    return const Success(null);
  }
}
