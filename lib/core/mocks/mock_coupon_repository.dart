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

class MockCouponRepository implements CouponRepository {
  static const String couponsKey = 'mock_coupons';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<CouponEntity>>.broadcast();

  MockCouponRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(couponsKey) ?? [];
    if (list.isEmpty) {
      final seeds = [
        {
          'id': 'coupon_1',
          'code': 'SAVE10',
          'type': 'Percentage',
          'discountValue': 10.0,
          'minOrderAmount': 100.0,
          'isActive': true,
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'usageLimit': 100,
          'usedCount': 0,
        },
        {
          'id': 'coupon_2',
          'code': 'EID50',
          'type': 'FixedAmount',
          'discountValue': 50.0,
          'minOrderAmount': 300.0,
          'isActive': true,
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'usageLimit': 50,
          'usedCount': 0,
        },
        {
          'id': 'coupon_3',
          'code': 'SUMMER20',
          'type': 'Percentage',
          'discountValue': 20.0,
          'minOrderAmount': 200.0,
          'isActive': true,
          'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'usageLimit': 200,
          'usedCount': 0,
        }
      ];
      _prefs.setStringList(couponsKey, seeds.map((e) => jsonEncode(e)).toList());
    }
  }

  List<CouponDto> _getCoupons() {
    final list = _prefs.getStringList(couponsKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return CouponDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<CouponDto> list) {
    _prefs.setStringList(couponsKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => CouponModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<CouponEntity>>> getCoupons() async {
    final list = _getCoupons().map((dto) => CouponModel.fromDto(dto).toEntity()).toList();
    return Success(list);
  }

  @override
  Stream<List<CouponEntity>> watchCoupons() {
    Timer.run(() {
      final list = _getCoupons().map((dto) => CouponModel.fromDto(dto).toEntity()).toList();
      _controller.add(list);
    });
    return _controller.stream;
  }

  @override
  Future<Result<CouponEntity>> getCouponByCode(String code) async {
    try {
      final coupon = _getCoupons().firstWhere((c) => c.code.trim().toUpperCase() == code.trim().toUpperCase() && c.isActive);
      return Success(CouponModel.fromDto(coupon).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'Coupon not found or inactive'));
    }
  }

  @override
  Future<Result<CouponEntity>> createCoupon(CouponEntity coupon) async {
    final all = _getCoupons();
    final newId = coupon.id.isEmpty ? 'coupon_${DateTime.now().millisecondsSinceEpoch}' : coupon.id;
    final finalCoupon = coupon.copyWith(id: newId, code: coupon.code.trim().toUpperCase());
    all.add(CouponModel.fromEntity(finalCoupon));
    _saveAll(all);
    return Success(finalCoupon);
  }

  @override
  Future<Result<CouponEntity>> updateCoupon(CouponEntity coupon) async {
    final all = _getCoupons();
    final idx = all.indexWhere((c) => c.id == coupon.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Coupon not found'));
    all[idx] = CouponModel.fromEntity(coupon);
    _saveAll(all);
    return Success(coupon);
  }

  @override
  Future<Result<void>> deleteCoupon(String couponId) async {
    final all = _getCoupons();
    all.removeWhere((c) => c.id == couponId);
    _saveAll(all);
    return const Success(null);
  }
}
