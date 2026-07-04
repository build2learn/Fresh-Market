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

class MockAuthRepository implements AuthRepository {
  static const String currentUserKey = 'mock_auth_current_user_id';
  static const String usersKey = 'mock_auth_users';

  final SharedPreferences _prefs;
  final _authStateController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  MockAuthRepository(this._prefs) {
    _init();
  }

  void _init() {
    final cachedUserId = _prefs.getString(currentUserKey);
    if (cachedUserId != null) {
      _currentUser = _getUserById(cachedUserId);
      debugPrint('[MOCK AUTH] Restored user session: ${_currentUser?.email}');
    }
    _authStateController.add(_currentUser);
  }

  List<UserDto> _getUsers() {
    final list = _prefs.getStringList(usersKey) ?? [];
    if (list.isEmpty) {
      // Seed default users
      final admin = UserDto(
        id: 'admin_user',
        email: 'admin@freshmarket.com',
        displayName: 'Admin User',
        role: 'admin',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final customer = UserDto(
        id: 'customer_user',
        email: 'customer@freshmarket.com',
        displayName: 'Customer User',
        role: 'customer',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final seeded = [admin, customer];
      _prefs.setStringList(usersKey, seeded.map((u) => mockEncode(u.toMap()..['id'] = u.id)).toList());
      return seeded;
    }
    return list.map((e) {
      final map = mockDecodeMap(e);
      return UserDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveUser(UserDto user) {
    final users = _getUsers();
    users.removeWhere((u) => u.id == user.id || u.email == user.email);
    users.add(user);
    _prefs.setStringList(usersKey, users.map((u) => mockEncode(u.toMap()..['id'] = u.id)).toList());
  }

  UserEntity? _getUserById(String uid) {
    try {
      final dto = _getUsers().firstWhere((u) => u.id == uid);
      return UserModel.fromDto(dto).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<UserEntity>> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final users = _getUsers();
      final dto = users.firstWhere((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase());
      // For simple mocking, password is correct
      final entity = UserModel.fromDto(dto).toEntity();
      _currentUser = entity;
      await _prefs.setString(currentUserKey, entity.id);
      _authStateController.add(entity);
      return Success(entity);
    } catch (e) {
      return Failure(AuthException(message: 'Invalid email or password'));
    }
  }

  @override
  Future<Result<UserEntity>> signUp(String email, String password, String? displayName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final users = _getUsers();
      if (users.any((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase())) {
        return Failure(AuthException(message: 'Email already in use'));
      }
      final newUid = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUserDto = UserDto(
        id: newUid,
        email: email,
        displayName: displayName ?? email.split('@')[0],
        role: 'customer',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _saveUser(newUserDto);
      final entity = UserModel.fromDto(newUserDto).toEntity();
      _currentUser = entity;
      await _prefs.setString(currentUserKey, entity.id);
      _authStateController.add(entity);
      return Success(entity);
    } catch (e) {
      return Failure(AuthException(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _prefs.remove(currentUserKey);
    _authStateController.add(null);
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    return Success(_currentUser);
  }

  @override
  Stream<UserEntity?> watchAuthState() {
    // Emit current state immediately
    Timer.run(() => _authStateController.add(_currentUser));
    return _authStateController.stream;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = _getUsers();
    if (!users.any((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase())) {
      throw AuthException(message: 'User not found');
    }
  }
}
