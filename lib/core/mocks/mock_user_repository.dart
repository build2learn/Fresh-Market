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
import 'package:fresh_market/core/mocks/mock_auth_repository.dart';

class MockUserRepository implements UserRepository {
  final SharedPreferences _prefs;

  MockUserRepository(this._prefs);

  List<UserDto> _getUsers() {
    final list = _prefs.getStringList(MockAuthRepository.usersKey) ?? [];
    return list.map((e) {
      final map = mockDecodeMap(e);
      return UserDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveUser(UserDto user) {
    final users = _getUsers();
    users.removeWhere((u) => u.id == user.id);
    users.add(user);
    _prefs.setStringList(MockAuthRepository.usersKey, users.map((u) => mockEncode(u.toMap()..['id'] = u.id)).toList());
  }

  @override
  Future<Result<List<UserEntity>>> getUsers({required int limit, dynamic lastDoc}) async {
    final users = _getUsers().map((u) => UserModel.fromDto(u).toEntity()).toList();
    return Success(users.take(limit).toList());
  }

  @override
  Future<Result<UserEntity>> getUser(String id) async {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == id);
      return Success(UserModel.fromDto(dto).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'User not found'));
    }
  }

  @override
  Future<Result<UserEntity>> updateUserRole(String userId, String role) async {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == userId);
      final updated = dto.copyWith(role: role, updatedAt: DateTime.now());
      _saveUser(updated);
      return Success(UserModel.fromDto(updated).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'User not found'));
    }
  }

  @override
  Future<Result<UserEntity>> toggleUserActive(String userId, bool isActive) async {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == userId);
      final updated = dto.copyWith(isActive: isActive, updatedAt: DateTime.now());
      _saveUser(updated);
      return Success(UserModel.fromDto(updated).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'User not found'));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? fcmToken,
  }) async {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == userId);
      final updated = dto.copyWith(
        displayName: displayName ?? dto.displayName,
        phoneNumber: phoneNumber ?? dto.phoneNumber,
        photoUrl: photoUrl ?? dto.photoUrl,
        fcmToken: fcmToken ?? dto.fcmToken,
        updatedAt: DateTime.now(),
      );
      _saveUser(updated);
      return Success(UserModel.fromDto(updated).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'User not found'));
    }
  }

  @override
  Future<Result<UserEntity>> updateFcmToken(String userId, String token) async {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == userId);
      final updated = dto.copyWith(fcmToken: token, updatedAt: DateTime.now());
      _saveUser(updated);
      debugPrint('[MOCK FCM] Token updated for user $userId: $token');
      return Success(UserModel.fromDto(updated).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'User not found'));
    }
  }

  @override
  Future<Result<UserEntity>> updateLoyalty(
    String userId, {
    required int loyaltyPoints,
    required int lifetimePoints,
    required String membershipLevel,
  }) async {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == userId);
      final updated = dto.copyWith(
        loyaltyPoints: loyaltyPoints,
        lifetimePoints: lifetimePoints,
        membershipLevel: membershipLevel,
        updatedAt: DateTime.now(),
      );
      _saveUser(updated);
      return Success(UserModel.fromDto(updated).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'User not found'));
    }
  }
}
