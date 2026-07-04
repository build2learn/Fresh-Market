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

class MockAddressRepository implements AddressRepository {
  static const String _addressesKey = 'mock_addresses';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<AddressEntity>>.broadcast();

  MockAddressRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_addressesKey) ?? [];
    if (list.isEmpty) {
      final seed = [
        {
          'id': 'addr_1',
          'userId': 'customer_user',
          'name': 'Home / المنزل',
          'phone': '01012345678',
          'address': '9 El Maadi St, Floor 4, Apt 12',
          'city': 'Cairo / القاهرة',
          'notes': 'Ring the bell / رن الجرس',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        }
      ];
      _prefs.setStringList(_addressesKey, seed.map((e) => jsonEncode(e)).toList());
    }
  }

  List<AddressDto> _getAddresses() {
    final list = _prefs.getStringList(_addressesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return AddressDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<AddressDto> list) {
    _prefs.setStringList(_addressesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    final userId = 'customer_user';
    final entities = list.map((dto) => AddressModel.fromDto(dto)).toList();
    _controller.add(entities.where((a) => a.userId == userId).toList());
  }

  @override
  Future<Result<List<AddressEntity>>> getAddresses(String userId) async {
    final list = _getAddresses().where((a) => a.userId == userId).map((dto) => AddressModel.fromDto(dto)).toList();
    return Success(list);
  }

  @override
  Stream<List<AddressEntity>> watchAddresses(String userId) {
    Timer.run(() {
      final list = _getAddresses().where((a) => a.userId == userId).map((dto) => AddressModel.fromDto(dto)).toList();
      _controller.add(list);
    });
    return _controller.stream.map((list) => list.where((a) => a.userId == userId).toList());
  }

  @override
  Future<Result<AddressEntity>> createAddress(AddressEntity address) async {
    final all = _getAddresses();
    final newId = address.id.isEmpty ? 'addr_${DateTime.now().millisecondsSinceEpoch}' : address.id;
    final finalAddress = address.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(AddressModel.fromEntity(finalAddress));
    _saveAll(all);
    return Success(finalAddress);
  }

  @override
  Future<Result<AddressEntity>> updateAddress(AddressEntity address) async {
    final all = _getAddresses();
    final idx = all.indexWhere((a) => a.id == address.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Address not found'));
    final finalAddress = address.copyWith(updatedAt: DateTime.now());
    all[idx] = AddressModel.fromEntity(finalAddress);
    _saveAll(all);
    return Success(finalAddress);
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    final all = _getAddresses();
    final idx = all.indexWhere((a) => a.id == id);
    if (idx == -1) return Failure(FirestoreException(message: 'Address not found'));
    all.removeAt(idx);
    _saveAll(all);
    return const Success(null);
  }
}
