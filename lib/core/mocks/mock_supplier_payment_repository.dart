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

class MockSupplierPaymentRepository implements SupplierPaymentRepository {
  static const String _paymentsKey = 'mock_supplier_payments';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<SupplierPaymentEntity>>.broadcast();

  MockSupplierPaymentRepository(this._prefs);

  List<SupplierPaymentDto> _getPayments() {
    final list = _prefs.getStringList(_paymentsKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return SupplierPaymentDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<SupplierPaymentDto> list) {
    _prefs.setStringList(_paymentsKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => SupplierPaymentModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<SupplierPaymentEntity>>> getPayments({String? supplierId}) async {
    var list = _getPayments().map((dto) => SupplierPaymentModel.fromDto(dto).toEntity()).toList();
    if (supplierId != null && supplierId.isNotEmpty) {
      list = list.where((p) => p.supplierId == supplierId).toList();
    }
    return Success(list);
  }

  @override
  Stream<List<SupplierPaymentEntity>> watchPayments({String? supplierId}) {
    Timer.run(() {
      var list = _getPayments().map((dto) => SupplierPaymentModel.fromDto(dto).toEntity()).toList();
      if (supplierId != null && supplierId.isNotEmpty) {
        list = list.where((p) => p.supplierId == supplierId).toList();
      }
      _controller.add(list);
    });
    return _controller.stream.map((all) {
      var list = all;
      if (supplierId != null && supplierId.isNotEmpty) {
        list = list.where((p) => p.supplierId == supplierId).toList();
      }
      return list;
    });
  }

  @override
  Future<Result<SupplierPaymentEntity>> createPayment(SupplierPaymentEntity payment) async {
    final all = _getPayments();
    final newId = payment.id.isEmpty ? 'pay_${DateTime.now().millisecondsSinceEpoch}' : payment.id;
    final finalPayment = payment.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(SupplierPaymentModel.fromEntity(finalPayment));
    _saveAll(all);

    // Update supplier balance
    try {
      final supplierList = _prefs.getStringList('mock_suppliers') ?? [];
      final updatedSuppliers = supplierList.map((s) {
        final map = jsonDecode(s) as Map<String, dynamic>;
        if (map['id'] == payment.supplierId) {
          final curBal = (map['balance'] as num?)?.toDouble() ?? 0.0;
          map['balance'] = curBal - payment.amount;
        }
        return jsonEncode(map);
      }).toList();
      _prefs.setStringList('mock_suppliers', updatedSuppliers);
    } catch (_) {}

    return Success(finalPayment);
  }

  @override
  Future<Result<void>> deletePayment(String paymentId) async {
    final all = _getPayments();
    final idx = all.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      final payment = SupplierPaymentModel.fromDto(all[idx]).toEntity();
      all.removeAt(idx);
      _saveAll(all);

      // Restore supplier balance (increment back)
      try {
        final supplierList = _prefs.getStringList('mock_suppliers') ?? [];
        final updatedSuppliers = supplierList.map((s) {
          final map = jsonDecode(s) as Map<String, dynamic>;
          if (map['id'] == payment.supplierId) {
            final curBal = (map['balance'] as num?)?.toDouble() ?? 0.0;
            map['balance'] = curBal + payment.amount;
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_suppliers', updatedSuppliers);
      } catch (_) {}
    }
    return const Success(null);
  }
}
