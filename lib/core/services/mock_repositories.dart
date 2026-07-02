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
import 'notification_service.dart';

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

String _encode(dynamic value) {
  return jsonEncode(value, toEncodable: (item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    try {
      if (item.runtimeType.toString().contains('Timestamp')) {
        return (item as dynamic).toDate().toIso8601String();
      }
    } catch (_) {}
    return item;
  });
}

Map<String, dynamic> _decodeMap(String jsonStr) {
  final rawMap = jsonDecode(jsonStr) as Map<String, dynamic>;
  final map = Map<String, dynamic>.from(rawMap);
  final dateKeys = ['createdAt', 'updatedAt', 'lastLoginAt', 'startDate', 'endDate'];
  for (final key in dateKeys) {
    if (map[key] is String) {
      final parsed = DateTime.tryParse(map[key] as String);
      if (parsed != null) {
        map[key] = parsed;
      }
    }
  }
  return map;
}

// ==========================================
// 1. MOCK AUTH REPOSITORY
// ==========================================
class MockAuthRepository implements AuthRepository {
  static const String _currentUserKey = 'mock_auth_current_user_id';
  static const String _usersKey = 'mock_auth_users';

  final SharedPreferences _prefs;
  final _authStateController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  MockAuthRepository(this._prefs) {
    _init();
  }

  void _init() {
    final cachedUserId = _prefs.getString(_currentUserKey);
    if (cachedUserId != null) {
      _currentUser = _getUserById(cachedUserId);
      debugPrint('[MOCK AUTH] Restored user session: ${_currentUser?.email}');
    }
    _authStateController.add(_currentUser);
  }

  List<UserDto> _getUsers() {
    final list = _prefs.getStringList(_usersKey) ?? [];
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
      _prefs.setStringList(_usersKey, seeded.map((u) => _encode(u.toMap()..['id'] = u.id)).toList());
      return seeded;
    }
    return list.map((e) {
      final map = _decodeMap(e);
      return UserDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveUser(UserDto user) {
    final users = _getUsers();
    users.removeWhere((u) => u.id == user.id || u.email == user.email);
    users.add(user);
    _prefs.setStringList(_usersKey, users.map((u) => _encode(u.toMap()..['id'] = u.id)).toList());
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
      await _prefs.setString(_currentUserKey, entity.id);
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
      await _prefs.setString(_currentUserKey, entity.id);
      _authStateController.add(entity);
      return Success(entity);
    } catch (e) {
      return Failure(AuthException(message: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _prefs.remove(_currentUserKey);
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

// ==========================================
// 2. MOCK CATEGORY REPOSITORY
// ==========================================
class MockCategoryRepository implements CategoryRepository {
  static const String _categoriesKey = 'mock_categories';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<CategoryEntity>>.broadcast();

  MockCategoryRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_categoriesKey) ?? [];
    if (list.isEmpty) {
      final c1 = CategoryDto(
        id: 'cat_meat',
        nameAr: 'لحوم',
        nameEn: 'Meat',
        imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
        isVisible: true,
        isActive: true,
        isDeleted: false,
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final c2 = CategoryDto(
        id: 'cat_poultry',
        nameAr: 'دواجن',
        nameEn: 'Poultry',
        imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
        isVisible: true,
        isActive: true,
        isDeleted: false,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final c3 = CategoryDto(
        id: 'cat_frozen',
        nameAr: 'مجمدات',
        nameEn: 'Frozen',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        isVisible: true,
        isActive: true,
        isDeleted: false,
        sortOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final c4 = CategoryDto(
        id: 'cat_processed',
        nameAr: 'مصنعات',
        nameEn: 'Processed Foods',
        imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=500',
        isVisible: true,
        isActive: true,
        isDeleted: false,
        sortOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _saveAll([c1, c2, c3, c4]);
    }
  }

  List<CategoryDto> _getCategories() {
    final list = _prefs.getStringList(_categoriesKey) ?? [];
    return list.map((e) {
      final map = _decodeMap(e);
      return CategoryDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<CategoryDto> categories) {
    _prefs.setStringList(_categoriesKey, categories.map((c) => _encode(c.toMap()..['id'] = c.id)).toList());
    _controller.add(categories.where((c) => !c.isDeleted).map((c) => CategoryModel.fromDto(c).toEntity()).toList());
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    final list = _getCategories().where((c) => !c.isDeleted).map((c) => CategoryModel.fromDto(c).toEntity()).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Success(list);
  }

  @override
  Future<Result<List<CategoryEntity>>> getVisibleCategories() async {
    final list = _getCategories()
        .where((c) => !c.isDeleted && c.isVisible)
        .map((c) => CategoryModel.fromDto(c).toEntity())
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Success(list);
  }

  @override
  Future<Result<List<CategoryEntity>>> getDeletedCategories() async {
    final list = _getCategories().where((c) => c.isDeleted).map((c) => CategoryModel.fromDto(c).toEntity()).toList();
    return Success(list);
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    Timer.run(() {
      final list = _getCategories().where((c) => !c.isDeleted).map((c) => CategoryModel.fromDto(c).toEntity()).toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _controller.add(list);
    });
    return _controller.stream;
  }

  @override
  Future<Result<CategoryEntity>> createCategory(CategoryEntity category, {String? imagePath}) async {
    final all = _getCategories();
    final newId = category.id.isEmpty ? 'cat_${DateTime.now().millisecondsSinceEpoch}' : category.id;
    final defaultImg = category.imageUrl ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500';
    final dto = CategoryDto(
      id: newId,
      nameAr: category.nameAr,
      nameEn: category.nameEn,
      imageUrl: defaultImg,
      isVisible: category.isVisible,
      sortOrder: category.sortOrder == 0 ? all.length : category.sortOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(dto);
    _saveAll(all);
    return Success(CategoryModel.fromDto(dto).toEntity());
  }

  @override
  Future<Result<CategoryEntity>> updateCategory(CategoryEntity category, {String? imagePath}) async {
    final all = _getCategories();
    final idx = all.indexWhere((c) => c.id == category.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Category not found'));
    final updated = CategoryDto(
      id: category.id,
      nameAr: category.nameAr,
      nameEn: category.nameEn,
      imageUrl: category.imageUrl ?? all[idx].imageUrl,
      isVisible: category.isVisible,
      isDeleted: category.isDeleted,
      isActive: category.isActive,
      sortOrder: category.sortOrder,
      createdAt: all[idx].createdAt,
      updatedAt: DateTime.now(),
    );
    all[idx] = updated;
    _saveAll(all);
    return Success(CategoryModel.fromDto(updated).toEntity());
  }

  @override
  Future<Result<void>> toggleVisibility(String categoryId, bool isVisible) async {
    final all = _getCategories();
    final idx = all.indexWhere((c) => c.id == categoryId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(isVisible: isVisible, updatedAt: DateTime.now());
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> reorderCategories(List<String> categoryIds) async {
    final all = _getCategories();
    for (var i = 0; i < categoryIds.length; i++) {
      final idx = all.indexWhere((c) => c.id == categoryIds[i]);
      if (idx != -1) {
        all[idx] = all[idx].copyWith(sortOrder: i, updatedAt: DateTime.now());
      }
    }
    _saveAll(all);
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteCategory(String categoryId) async {
    final all = _getCategories();
    final idx = all.indexWhere((c) => c.id == categoryId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(isDeleted: true, isVisible: false, updatedAt: DateTime.now());
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> restoreCategory(String categoryId) async {
    final all = _getCategories();
    final idx = all.indexWhere((c) => c.id == categoryId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(isDeleted: false, isVisible: true, updatedAt: DateTime.now());
      _saveAll(all);
    }
    return const Success(null);
  }
}

// ==========================================
// 3. MOCK PRODUCT REPOSITORY
// ==========================================
class MockProductRepository implements ProductRepository {
  static const String _productsKey = 'mock_products';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<ProductEntity>>.broadcast();

  MockProductRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_productsKey) ?? [];
    if (list.isEmpty) {
      final p1 = ProductDto(
        id: 'prod_minced_meat',
        nameAr: 'لحمة مفرومة',
        nameEn: 'Minced Meat',
        descriptionAr: 'لحمة بقر مفرومة طازجة عالية الجودة',
        descriptionEn: 'Fresh premium quality minced beef',
        price: 60.0,
        weight: 400.0,
        weightUnitId: 'gram',
        imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
        categoryId: 'cat_meat',
        isFeatured: true,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentStock: 50,
        reservedStock: 0,
        availableStock: 50,
        minimumStock: 5,
        reorderLevel: 10,
      );
      final p2 = ProductDto(
        id: 'prod_meat_box',
        nameAr: 'صندوق لحوم',
        nameEn: 'Meat Box',
        descriptionAr: 'صندوق لحوم مختلطة طازجة ومجمدة',
        descriptionEn: 'Assorted fresh and frozen meat box',
        price: 500.0,
        weight: 1.0,
        weightUnitId: 'box',
        imageUrl: 'https://images.unsplash.com/photo-1602470521006-aaea8b2a7939?w=500',
        categoryId: 'cat_meat',
        isFeatured: true,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentStock: 20,
        reservedStock: 0,
        availableStock: 20,
        minimumStock: 3,
        reorderLevel: 5,
      );
      final p3 = ProductDto(
        id: 'prod_chicken',
        nameAr: 'دجاج طازج',
        nameEn: 'Fresh Chicken',
        descriptionAr: 'دجاج طازج مذبوح يومياً',
        descriptionEn: 'Freshly slaughtered chicken',
        price: 85.0,
        weight: 1.0,
        weightUnitId: 'kg',
        imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500',
        categoryId: 'cat_poultry',
        isFeatured: true,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentStock: 4, // Starts below alertQuantity (10) for warning badge testing
        reservedStock: 0,
        availableStock: 4,
        minimumStock: 2,
        reorderLevel: 10,
      );
      final p4 = ProductDto(
        id: 'prod_frozen_burger',
        nameAr: 'برجر مجمد',
        nameEn: 'Frozen Burger',
        descriptionAr: 'طباق برجر مجمد جاهز للشوي',
        descriptionEn: 'Ready-to-grill frozen burger patties',
        price: 45.0,
        weight: 400.0,
        weightUnitId: 'gram',
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
        categoryId: 'cat_frozen',
        isFeatured: false,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentStock: 0, // Starts at 0 for out-of-stock testing
        reservedStock: 0,
        availableStock: 0,
        minimumStock: 5,
        reorderLevel: 10,
      );
      _saveAll([p1, p2, p3, p4]);
    }
  }

  List<ProductDto> _getProducts() {
    final list = _prefs.getStringList(_productsKey) ?? [];
    return list.map((e) {
      final map = _decodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<ProductDto> products) {
    _prefs.setStringList(_productsKey, products.map((p) => _encode(p.toMap()..['id'] = p.id)).toList());
    _controller.add(products.map((p) => ProductModel.fromDto(p).toEntity()).toList());
  }

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    required int limit,
    dynamic lastDoc,
    String? categoryId,
  }) async {
    var list = _getProducts();
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    final entities = list.map((p) => ProductModel.fromDto(p).toEntity()).toList();
    return Success(entities.take(limit).toList());
  }

  @override
  Future<Result<ProductEntity>> getProduct(String id) async {
    try {
      final dto = _getProducts().firstWhere((p) => p.id == id);
      return Success(ProductModel.fromDto(dto).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'Product not found'));
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getFeaturedProducts({int limit = 20}) async {
    final list = _getProducts()
        .where((p) => p.isFeatured)
        .map((p) => ProductModel.fromDto(p).toEntity())
        .take(limit)
        .toList();
    return Success(list);
  }

  @override
  Stream<List<ProductEntity>> watchProducts({int limit = 20}) {
    Timer.run(() {
      _controller.add(_getProducts().map((p) => ProductModel.fromDto(p).toEntity()).take(limit).toList());
    });
    return _controller.stream;
  }

  @override
  Stream<List<ProductEntity>> watchFeaturedProducts({int limit = 20}) {
    final featuredController = StreamController<List<ProductEntity>>.broadcast();
    Timer.run(() {
      final list = _getProducts()
          .where((p) => p.isFeatured)
          .map((p) => ProductModel.fromDto(p).toEntity())
          .take(limit)
          .toList();
      featuredController.add(list);
    });
    return featuredController.stream;
  }

  @override
  Future<Result<ProductEntity>> createProduct(ProductEntity product, {String? imagePath}) async {
    final all = _getProducts();
    final newId = product.id.isEmpty ? 'prod_${DateTime.now().millisecondsSinceEpoch}' : product.id;
    final defaultImg = product.imageUrl ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500';
    final dto = ProductDto(
      id: newId,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      descriptionAr: product.descriptionAr,
      descriptionEn: product.descriptionEn,
      price: product.price,
      weight: product.weight,
      weightUnitId: product.weightUnitId,
      imageUrl: defaultImg,
      categoryId: product.categoryId,
      isFeatured: product.isFeatured,
      isAvailable: product.isAvailable,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productType: product.productType,
      status: product.status,
      currentStock: product.currentStock,
      reservedStock: product.reservedStock,
      availableStock: product.availableStock,
      minimumStock: product.minimumStock,
      reorderLevel: product.reorderLevel,
    );
    all.add(dto);
    _saveAll(all);
    return Success(ProductModel.fromDto(dto).toEntity());
  }

  @override
  Future<Result<ProductEntity>> updateProduct(ProductEntity product, {String? imagePath}) async {
    final all = _getProducts();
    final idx = all.indexWhere((p) => p.id == product.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Product not found'));
    final updated = ProductDto(
      id: product.id,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      descriptionAr: product.descriptionAr,
      descriptionEn: product.descriptionEn,
      price: product.price,
      weight: product.weight,
      weightUnitId: product.weightUnitId,
      imageUrl: product.imageUrl ?? all[idx].imageUrl,
      categoryId: product.categoryId,
      isFeatured: product.isFeatured,
      isAvailable: product.isAvailable,
      createdAt: all[idx].createdAt,
      updatedAt: DateTime.now(),
      productType: product.productType,
      status: product.status,
      currentStock: product.currentStock,
      reservedStock: product.reservedStock,
      availableStock: product.availableStock,
      minimumStock: product.minimumStock,
      reorderLevel: product.reorderLevel,
    );
    all[idx] = updated;
    _saveAll(all);
    return Success(ProductModel.fromDto(updated).toEntity());
  }

  @override
  Future<Result<void>> deleteProduct(String productId) async {
    final all = _getProducts();
    all.removeWhere((p) => p.id == productId);
    _saveAll(all);
    return const Success(null);
  }

  @override
  Future<Result<void>> toggleFeatured(String productId, bool isFeatured) async {
    final all = _getProducts();
    final idx = all.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(isFeatured: isFeatured, updatedAt: DateTime.now());
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> toggleAvailability(String productId, bool isAvailable) async {
    final all = _getProducts();
    final idx = all.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(isAvailable: isAvailable, updatedAt: DateTime.now());
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<List<ProductEntity>>> searchProducts(String query) async {
    final list = _getProducts();
    final lowercaseQuery = query.toLowerCase();
    final filtered = list
        .where((p) {
          return p.nameAr.toLowerCase().contains(lowercaseQuery) ||
              p.nameEn.toLowerCase().contains(lowercaseQuery) ||
              (p.descriptionAr?.toLowerCase().contains(lowercaseQuery) ?? false) ||
              (p.descriptionEn?.toLowerCase().contains(lowercaseQuery) ?? false);
        })
        .map((p) => ProductModel.fromDto(p).toEntity())
        .toList();
    return Success(filtered);
  }

  @override
  Future<Result<void>> adjustStock(String productId, int newQuantity, {String? reasonEn, String? reasonAr}) async {
    final all = _getProducts();
    final idx = all.indexWhere((p) => p.id == productId);
    if (idx == -1) return Failure(FirestoreException(message: 'Product not found'));
    final old = all[idx];

    final cur = old.currentStock;
    final res = old.reservedStock;
    final newAv = newQuantity - res;

    final updated = old.copyWith(
      currentStock: newQuantity,
      availableStock: newAv,
    );
    all[idx] = updated;
    _saveAll(all);

    _logMockStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: old.nameAr,
      productNameEn: old.nameEn,
      type: 'adjustment',
      quantityChanged: newQuantity - cur,
      previousStock: cur,
      newStock: newQuantity,
      reasonAr: reasonAr ?? 'تعديل المخزون بواسطة المسؤول',
      reasonEn: reasonEn ?? 'Stock adjusted by admin',
      createdBy: 'admin',
    );

    return const Success(null);
  }

  @override
  Future<Result<void>> receiveStock(String productId, int quantityToAdd, {String? reasonEn, String? reasonAr}) async {
    final all = _getProducts();
    final idx = all.indexWhere((p) => p.id == productId);
    if (idx == -1) return Failure(FirestoreException(message: 'Product not found'));
    final old = all[idx];

    final cur = old.currentStock;
    final av = old.availableStock;
    final newCur = cur + quantityToAdd;
    final newAv = av + quantityToAdd;

    final updated = old.copyWith(
      currentStock: newCur,
      availableStock: newAv,
    );
    all[idx] = updated;
    _saveAll(all);

    _logMockStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: old.nameAr,
      productNameEn: old.nameEn,
      type: 'receipt',
      quantityChanged: quantityToAdd,
      previousStock: cur,
      newStock: newCur,
      reasonAr: reasonAr ?? 'استلام مخزون جديد بواسطة المسؤول',
      reasonEn: reasonEn ?? 'Stock received by admin',
      createdBy: 'admin',
    );

    return const Success(null);
  }
}

// ==========================================
// 4. MOCK OFFER REPOSITORY
// ==========================================
class MockOfferRepository implements OfferRepository {
  static const String _offersKey = 'mock_offers';
  static const String _offerProductsKey = 'mock_offer_products';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<OfferEntity>>.broadcast();

  MockOfferRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_offersKey) ?? [];
    if (list.isEmpty) {
      final o1 = OfferDto(
        id: 'offer_summer',
        titleAr: 'عرض الصيف',
        titleEn: 'Summer Offer',
        descriptionAr: 'خصم ٢٠٪ على جميع اللحوم الطازجة',
        descriptionEn: '20% discount on all fresh meats',
        imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=500',
        isActive: true,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _prefs.setStringList(_offersKey, [_encode(o1.toMap()..['id'] = o1.id)]);
      _prefs.setStringList(_offerProductsKey, [
        _encode({'id': 'op1', 'offerId': 'offer_summer', 'productId': 'prod_minced_meat', 'createdAt': DateTime.now().toIso8601String()}),
        _encode({'id': 'op2', 'offerId': 'offer_summer', 'productId': 'prod_meat_box', 'createdAt': DateTime.now().toIso8601String()}),
      ]);
    }
  }

  List<OfferDto> _getOffers() {
    final list = _prefs.getStringList(_offersKey) ?? [];
    return list.map((e) {
      final map = _decodeMap(e);
      return OfferDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  List<Map<String, dynamic>> _getOfferProducts() {
    final list = _prefs.getStringList(_offerProductsKey) ?? [];
    return list.map((e) => _decodeMap(e)).toList();
  }

  void _saveAll(List<OfferDto> offers) {
    _prefs.setStringList(_offersKey, offers.map((o) => _encode(o.toMap()..['id'] = o.id)).toList());
    _controller.add(offers.map((o) => OfferModel.fromDto(o).toEntity()).toList());
  }

  @override
  Future<Result<List<OfferEntity>>> getOffers() async {
    final list = _getOffers().map((o) => OfferModel.fromDto(o).toEntity()).toList();
    return Success(list);
  }

  @override
  Future<Result<List<OfferEntity>>> getActiveOffers() async {
    final list = _getOffers()
        .where((o) => o.isActive && o.endDate.isAfter(DateTime.now()))
        .map((o) => OfferModel.fromDto(o).toEntity())
        .toList();
    return Success(list);
  }

  @override
  Future<Result<OfferEntity>> getOffer(String id) async {
    try {
      final dto = _getOffers().firstWhere((o) => o.id == id);
      return Success(OfferModel.fromDto(dto).toEntity());
    } catch (_) {
      return Failure(FirestoreException(message: 'Offer not found'));
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getOfferProducts(String offerId) async {
    final maps = _getOfferProducts().where((m) => m['offerId'] == offerId).toList();
    final productIds = maps.map((m) => m['productId'] as String).toList();
    
    // Retrieve product details using a mock product fetcher
    final prodKey = _prefs.getStringList(MockProductRepository._productsKey) ?? [];
    final allProds = prodKey.map((e) {
      final map = _decodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
    
    final matchedProds = allProds
        .where((p) => productIds.contains(p.id))
        .map((p) => ProductModel.fromDto(p).toEntity())
        .toList();
    return Success(matchedProds);
  }

  @override
  Stream<List<OfferEntity>> watchActiveOffers() {
    Timer.run(() {
      final list = _getOffers()
          .where((o) => o.isActive && o.endDate.isAfter(DateTime.now()))
          .map((o) => OfferModel.fromDto(o).toEntity())
          .toList();
      _controller.add(list);
    });
    return _controller.stream;
  }

  @override
  Future<Result<OfferEntity>> createOffer(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  }) async {
    final all = _getOffers();
    final newId = offer.id.isEmpty ? 'offer_${DateTime.now().millisecondsSinceEpoch}' : offer.id;
    final defaultImg = offer.imageUrl ?? 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=500';
    final dto = OfferDto(
      id: newId,
      titleAr: offer.titleAr,
      titleEn: offer.titleEn,
      descriptionAr: offer.descriptionAr,
      descriptionEn: offer.descriptionEn,
      imageUrl: defaultImg,
      isActive: offer.isActive,
      startDate: offer.startDate,
      endDate: offer.endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(dto);
    _saveAll(all);

    // Save mappings
    final mappings = _getOfferProducts();
    mappings.removeWhere((m) => m['offerId'] == newId);
    for (final pid in productIds) {
      mappings.add({
        'id': 'op_${newId}_$pid',
        'offerId': newId,
        'productId': pid,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    _prefs.setStringList(_offerProductsKey, mappings.map((m) => _encode(m)).toList());

    return Success(OfferModel.fromDto(dto).toEntity());
  }

  @override
  Future<Result<OfferEntity>> updateOffer(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  }) async {
    final all = _getOffers();
    final idx = all.indexWhere((o) => o.id == offer.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Offer not found'));
    final updated = OfferDto(
      id: offer.id,
      titleAr: offer.titleAr,
      titleEn: offer.titleEn,
      descriptionAr: offer.descriptionAr,
      descriptionEn: offer.descriptionEn,
      imageUrl: offer.imageUrl ?? all[idx].imageUrl,
      isActive: offer.isActive,
      startDate: offer.startDate,
      endDate: offer.endDate,
      createdAt: all[idx].createdAt,
      updatedAt: DateTime.now(),
    );
    all[idx] = updated;
    _saveAll(all);

    // Update mappings
    final mappings = _getOfferProducts();
    mappings.removeWhere((m) => m['offerId'] == offer.id);
    for (final pid in productIds) {
      mappings.add({
        'id': 'op_${offer.id}_$pid',
        'offerId': offer.id,
        'productId': pid,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    _prefs.setStringList(_offerProductsKey, mappings.map((m) => _encode(m)).toList());

    return Success(OfferModel.fromDto(updated).toEntity());
  }

  @override
  Future<Result<void>> toggleActive(String offerId, bool isActive) async {
    final all = _getOffers();
    final idx = all.indexWhere((o) => o.id == offerId);
    if (idx != -1) {
      all[idx] = all[idx].copyWith(isActive: isActive, updatedAt: DateTime.now());
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteOffer(String offerId) async {
    final all = _getOffers();
    all.removeWhere((o) => o.id == offerId);
    _saveAll(all);

    final mappings = _getOfferProducts();
    mappings.removeWhere((m) => m['offerId'] == offerId);
    _prefs.setStringList(_offerProductsKey, mappings.map((m) => _encode(m)).toList());

    return const Success(null);
  }
}

// ==========================================
// 5. MOCK WEIGHT UNIT REPOSITORY
// ==========================================
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
      final map = _decodeMap(e);
      return WeightUnitDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<WeightUnitDto> units) {
    _prefs.setStringList(_unitsKey, units.map((u) => _encode(u.toMap()..['id'] = u.id)).toList());
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

// ==========================================
// 6. MOCK SETTINGS REPOSITORY
// ==========================================
class MockSettingsRepository implements SettingsRepository {
  static const String _settingsKey = 'mock_app_settings';
  final SharedPreferences _prefs;

  MockSettingsRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final jsonStr = _prefs.getString(_settingsKey);
    if (jsonStr == null) {
      final defaultSettings = {
        'storeName': 'Fresh Market',
        'currencyCode': 'EGP',
        'currencySymbol': 'E£',
        'phone': '',
        'whatsapp': '',
        'facebook': '',
        'instagram': '',
        'maintenanceMode': false,
      };
      _prefs.setString(_settingsKey, _encode(defaultSettings));
    }
  }

  Map<String, dynamic> _getSettingsMap() {
    final jsonStr = _prefs.getString(_settingsKey);
    if (jsonStr == null) return {};
    return _decodeMap(jsonStr);
  }

  void _saveSettingsMap(Map<String, dynamic> map) {
    _prefs.setString(_settingsKey, _encode(map));
  }

  @override
  Future<Result<List<SettingEntity>>> getSettings() async {
    final map = _getSettingsMap();
    final list = <SettingEntity>[];
    map.forEach((key, val) {
      SettingType type = SettingType.string;
      if (val is bool) {
        type = SettingType.bool;
      } else if (val is num) {
        type = SettingType.number;
      } else if (val is Map) {
        type = SettingType.json;
      }
      list.add(SettingEntity(
        id: key,
        value: val,
        type: type,
        updatedAt: DateTime.now(),
      ));
    });
    return Success(list);
  }

  @override
  Future<Result<SettingEntity?>> getSetting(String key) async {
    final map = _getSettingsMap();
    if (!map.containsKey(key)) return const Success(null);
    final val = map[key];
    SettingType type = SettingType.string;
    if (val is bool) {
      type = SettingType.bool;
    } else if (val is num) {
      type = SettingType.number;
    } else if (val is Map) {
      type = SettingType.json;
    }
    return Success(SettingEntity(
      id: key,
      value: val,
      type: type,
      updatedAt: DateTime.now(),
    ));
  }

  @override
  Future<Result<SettingEntity>> updateSetting(SettingEntity setting) async {
    final map = _getSettingsMap();
    map[setting.id] = setting.value;
    _saveSettingsMap(map);
    return Success(setting);
  }
}

// ==========================================
// 7. MOCK USER REPOSITORY
// ==========================================
class MockUserRepository implements UserRepository {
  final SharedPreferences _prefs;

  MockUserRepository(this._prefs);

  List<UserDto> _getUsers() {
    final list = _prefs.getStringList(MockAuthRepository._usersKey) ?? [];
    return list.map((e) {
      final map = _decodeMap(e);
      return UserDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveUser(UserDto user) {
    final users = _getUsers();
    users.removeWhere((u) => u.id == user.id);
    users.add(user);
    _prefs.setStringList(MockAuthRepository._usersKey, users.map((u) => _encode(u.toMap()..['id'] = u.id)).toList());
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

// ==========================================
// 8. MOCK NOTIFICATION REPOSITORY
// ==========================================
class MockNotificationRepository implements NotificationRepository {
  static const String _notificationsKey = 'mock_notifications';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<NotificationEntity>>.broadcast();

  MockNotificationRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_notificationsKey) ?? [];
    if (list.isEmpty) {
      final testNotification = {
        'id': 'notif_welcome',
        'userId': 'customer_user',
        'title': 'Welcome to Fresh Market! / أهلاً بك في فريش ماركت!',
        'body': 'Enjoy our fresh meat and offers. / استمتع باللحوم الطازجة والعروض.',
        'type': 'system',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      };
      _prefs.setStringList(_notificationsKey, [jsonEncode(testNotification)]);
    }
  }

  List<Map<String, dynamic>> _getNotificationsRaw() {
    final list = _prefs.getStringList(_notificationsKey) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  void _saveAll(List<Map<String, dynamic>> list) {
    _prefs.setStringList(_notificationsKey, list.map((e) => jsonEncode(e)).toList());
    _emit(list);
  }

  void _emit(List<Map<String, dynamic>> list) {
    final entities = list.map((m) => _mapToEntity(m)).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _controller.add(entities);
  }

  NotificationEntity _mapToEntity(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.fromString(map['type'] as String? ?? 'system'),
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  Future<Result<List<NotificationEntity>>> getNotifications(String userId, {int limit = 50}) async {
    final all = _getNotificationsRaw().where((n) => n['userId'] == userId || n['userId'] == 'all').toList();
    final entities = all.map((m) => _mapToEntity(m)).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(entities.take(limit).toList());
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    Timer.run(() {
      final all = _getNotificationsRaw().where((n) => n['userId'] == userId || n['userId'] == 'all').toList();
      _emit(all);
    });
    return _controller.stream.map((list) => list.where((n) => n.userId == userId || n.userId == 'all').toList());
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    final all = _getNotificationsRaw();
    final idx = all.indexWhere((n) => n['id'] == notificationId);
    if (idx != -1) {
      all[idx]['isRead'] = true;
      _saveAll(all);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllAsRead(String userId) async {
    final all = _getNotificationsRaw();
    for (var i = 0; i < all.length; i++) {
      if (all[i]['userId'] == userId || all[i]['userId'] == 'all') {
        all[i]['isRead'] = true;
      }
    }
    _saveAll(all);
    return const Success(null);
  }

  @override
  Future<Result<NotificationEntity>> createNotification(NotificationEntity notification) async {
    final all = _getNotificationsRaw();
    final newId = notification.id.isEmpty ? 'notif_${DateTime.now().millisecondsSinceEpoch}' : notification.id;
    final map = {
      'id': newId,
      'userId': notification.userId,
      'title': notification.title,
      'body': notification.body,
      'type': notification.type.value,
      'isRead': notification.isRead,
      'createdAt': DateTime.now().toIso8601String(),
      if (notification.data != null) 'data': notification.data,
    };
    all.add(map);
    _saveAll(all);

    // Trigger local simulation so foreground listener can intercept it!
    NotificationService.instance.simulateNotification(
      title: notification.title,
      body: notification.body,
      data: notification.data,
    );

    return Success(_mapToEntity(map));
  }
}

// ==========================================
// 9. MOCK LOOKUP REPOSITORY
// ==========================================
class MockLookupRepository implements LookupRepository {
  static const String _lookupsKey = 'mock_lookups';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<LookupEntity>>.broadcast();

  MockLookupRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_lookupsKey) ?? [];
    if (list.isEmpty) {
      final List<LookupDto> seeds = [];
      int currentId = 1;

      // 1. Weight Units
      final weightUnits = [
        {'code': 'gram', 'nameAr': 'جرام', 'nameEn': 'Gram'},
        {'code': 'kg', 'nameAr': 'كيلوجرام', 'nameEn': 'Kilogram'},
        {'code': 'piece', 'nameAr': 'قطعة', 'nameEn': 'Piece'},
        {'code': 'box', 'nameAr': 'صندوق', 'nameEn': 'Box'},
        {'code': 'pack', 'nameAr': 'عبوة', 'nameEn': 'Pack'},
      ];
      for (var i = 0; i < weightUnits.length; i++) {
        final u = weightUnits[i];
        seeds.add(LookupDto(
          id: currentId++,
          lookupType: 'WeightUnit',
          code: u['code']!,
          nameAr: u['nameAr']!,
          nameEn: u['nameEn']!,
          isActive: true,
          sortOrder: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // 2. Categories
      final categories = [
        {'code': 'cat_meat', 'nameAr': 'لحوم', 'nameEn': 'Meat', 'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500'},
        {'code': 'cat_poultry', 'nameAr': 'دواجن', 'nameEn': 'Poultry', 'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500'},
        {'code': 'cat_frozen', 'nameAr': 'مجمدات', 'nameEn': 'Frozen', 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500'},
        {'code': 'cat_processed', 'nameAr': 'مصنعات', 'nameEn': 'Processed Foods', 'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=500'},
        {'code': 'cat_dairy', 'nameAr': 'ألبان', 'nameEn': 'Dairy', 'imageUrl': 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500'},
        {'code': 'cat_beverages', 'nameAr': 'مشروبات', 'nameEn': 'Beverages', 'imageUrl': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500'},
        {'code': 'cat_vegetables', 'nameAr': 'خضروات', 'nameEn': 'Vegetables', 'imageUrl': 'https://images.unsplash.com/photo-1566385101042-1a0a09022c61?w=500'},
        {'code': 'cat_fruits', 'nameAr': 'فواكه', 'nameEn': 'Fruits', 'imageUrl': 'https://images.unsplash.com/photo-1619546813926-a78fa6372cd2?w=500'},
      ];
      for (var i = 0; i < categories.length; i++) {
        final c = categories[i];
        seeds.add(LookupDto(
          id: currentId++,
          lookupType: 'Category',
          code: c['code']!,
          nameAr: c['nameAr']!,
          nameEn: c['nameEn']!,
          isActive: true,
          sortOrder: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageUrl: c['imageUrl'],
        ));
      }

      // 3. Product Status
      final productStatuses = [
        {'code': 'Available', 'nameAr': 'متوفر', 'nameEn': 'Available'},
        {'code': 'OutOfStock', 'nameAr': 'غير متوفر', 'nameEn': 'Out of Stock'},
        {'code': 'ComingSoon', 'nameAr': 'قريباً', 'nameEn': 'Coming Soon'},
        {'code': 'Hidden', 'nameAr': 'مخفي', 'nameEn': 'Hidden'},
      ];
      for (var i = 0; i < productStatuses.length; i++) {
        final s = productStatuses[i];
        seeds.add(LookupDto(
          id: currentId++,
          lookupType: 'ProductStatus',
          code: s['code']!,
          nameAr: s['nameAr']!,
          nameEn: s['nameEn']!,
          isActive: true,
          sortOrder: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // 4. Product Type
      final productTypes = [
        {'code': 'Fresh', 'nameAr': 'طازج', 'nameEn': 'Fresh'},
        {'code': 'Frozen', 'nameAr': 'مجمد', 'nameEn': 'Frozen'},
        {'code': 'Processed', 'nameAr': 'مصنع', 'nameEn': 'Processed'},
        {'code': 'Imported', 'nameAr': 'مستورد', 'nameEn': 'Imported'},
        {'code': 'Local', 'nameAr': 'محلي', 'nameEn': 'Local'},
      ];
      for (var i = 0; i < productTypes.length; i++) {
        final t = productTypes[i];
        seeds.add(LookupDto(
          id: currentId++,
          lookupType: 'ProductType',
          code: t['code']!,
          nameAr: t['nameAr']!,
          nameEn: t['nameEn']!,
          isActive: true,
          sortOrder: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // 5. Offer Type
      final offerTypes = [
        {'code': 'PercentageDiscount', 'nameAr': 'خصم نسبة مئوية', 'nameEn': 'Percentage Discount'},
        {'code': 'FixedDiscount', 'nameAr': 'خصم ثابت', 'nameEn': 'Fixed Discount'},
        {'code': 'BuyOneGetOne', 'nameAr': 'اشتري واحد واحصل على الثاني مجاناً', 'nameEn': 'Buy One Get One'},
        {'code': 'SpecialOffer', 'nameAr': 'عرض خاص', 'nameEn': 'Special Offer'},
      ];
      for (var i = 0; i < offerTypes.length; i++) {
        final o = offerTypes[i];
        seeds.add(LookupDto(
          id: currentId++,
          lookupType: 'OfferType',
          code: o['code']!,
          nameAr: o['nameAr']!,
          nameEn: o['nameEn']!,
          isActive: true,
          sortOrder: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // 6. User Role
      final userRoles = [
        {'code': 'Admin', 'nameAr': 'مدير النظام', 'nameEn': 'Admin'},
        {'code': 'Manager', 'nameAr': 'مدير', 'nameEn': 'Manager'},
        {'code': 'Employee', 'nameAr': 'موظف', 'nameEn': 'Employee'},
        {'code': 'Customer', 'nameAr': 'عميل', 'nameEn': 'Customer'},
      ];
      for (var i = 0; i < userRoles.length; i++) {
        final r = userRoles[i];
        seeds.add(LookupDto(
          id: currentId++,
          lookupType: 'UserRole',
          code: r['code']!,
          nameAr: r['nameAr']!,
          nameEn: r['nameEn']!,
          isActive: true,
          sortOrder: i,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      _saveAll(seeds);
    }
  }

  List<LookupDto> _getLookups() {
    final list = _prefs.getStringList(_lookupsKey) ?? [];
    return list.map((e) {
      final map = _decodeMap(e);
      return LookupDto.fromMap(map, map['id']?.toString() ?? '');
    }).toList();
  }

  void _saveAll(List<LookupDto> list) {
    _prefs.setStringList(_lookupsKey, list.map((e) => _encode(e.toMap()..['id'] = e.id)).toList());
  }

  @override
  Future<Result<List<LookupEntity>>> getLookups(String lookupType) async {
    final list = _getLookups()
        .where((l) => l.lookupType == lookupType)
        .map((l) => LookupModel.fromDto(l).toEntity())
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Success(list);
  }

  @override
  Stream<List<LookupEntity>> watchLookups(String lookupType) {
    Timer.run(() {
      final list = _getLookups()
          .map((l) => LookupModel.fromDto(l).toEntity())
          .toList();
      _controller.add(list);
    });
    return _controller.stream.map((list) {
      final filtered = list.where((l) => l.lookupType == lookupType).toList();
      filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return filtered;
    });
  }

  @override
  Future<Result<LookupEntity>> createLookup(LookupEntity lookup) async {
    final all = _getLookups();
    final newId = lookup.id == 0 ? (all.isEmpty ? 1 : all.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1) : lookup.id;
    final typeLookupsCount = all.where((l) => l.lookupType == lookup.lookupType).length;
    final dto = LookupDto(
      id: newId,
      lookupType: lookup.lookupType,
      code: lookup.code,
      nameAr: lookup.nameAr,
      nameEn: lookup.nameEn,
      isActive: lookup.isActive,
      sortOrder: lookup.sortOrder == 0 ? typeLookupsCount : lookup.sortOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: lookup.imageUrl,
    );
    all.add(dto);
    _saveAll(all);
    final entity = LookupModel.fromDto(dto).toEntity();
    _controller.add(all.map((l) => LookupModel.fromDto(l).toEntity()).toList());
    return Success(entity);
  }

  @override
  Future<Result<LookupEntity>> updateLookup(LookupEntity lookup) async {
    final all = _getLookups();
    final idx = all.indexWhere((l) => l.id == lookup.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Lookup not found'));
    final dto = LookupDto(
      id: lookup.id,
      lookupType: lookup.lookupType,
      code: lookup.code,
      nameAr: lookup.nameAr,
      nameEn: lookup.nameEn,
      isActive: lookup.isActive,
      sortOrder: lookup.sortOrder,
      createdAt: all[idx].createdAt,
      updatedAt: DateTime.now(),
      imageUrl: lookup.imageUrl ?? all[idx].imageUrl,
    );
    all[idx] = dto;
    _saveAll(all);
    final entity = LookupModel.fromDto(dto).toEntity();
    _controller.add(all.map((l) => LookupModel.fromDto(l).toEntity()).toList());
    return Success(entity);
  }

  @override
  Future<Result<void>> deleteLookup(int id) async {
    final all = _getLookups();
    all.removeWhere((l) => l.id == id);
    _saveAll(all);
    _controller.add(all.map((l) => LookupModel.fromDto(l).toEntity()).toList());
    return const Success(null);
  }

  @override
  Future<Result<void>> reorderLookups(String lookupType, List<int> ids) async {
    final all = _getLookups();
    for (var i = 0; i < ids.length; i++) {
      final idx = all.indexWhere((l) => l.id == ids[i]);
      if (idx != -1) {
        all[idx] = all[idx].copyWith(sortOrder: i, updatedAt: DateTime.now());
      }
    }
    _saveAll(all);
    _controller.add(all.map((l) => LookupModel.fromDto(l).toEntity()).toList());
    return const Success(null);
  }
}

// ==========================================
// 10. MOCK ORDER REPOSITORY
// ==========================================
class MockOrderRepository implements OrderRepository {
  static const String _ordersKey = 'mock_orders';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<OrderEntity>>.broadcast();

  MockOrderRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_ordersKey) ?? [];
    if (list.isEmpty) {
      final now = DateTime.now();
      final seedOrders = [
        {
          'id': 'order_1',
          'userId': 'customer_user',
          'userEmail': 'customer@freshmarket.com',
          'status': 'Pending',
          'totalAmount': 105.0,
          'createdAt': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'items': [
            {
              'productId': 'prod_minced_meat',
              'productNameAr': 'لحمة مفرومة',
              'productNameEn': 'Minced Meat',
              'price': 60.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1588168333986-5078647ac9ab?w=500',
              'weight': 400.0,
              'weightUnitId': 'gram',
            },
            {
              'productId': 'prod_frozen_burger',
              'productNameAr': 'برجر مجمد',
              'productNameEn': 'Frozen Burger',
              'price': 45.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
              'weight': 400.0,
              'weightUnitId': 'gram',
            }
          ],
        },
        {
          'id': 'order_2',
          'userId': 'customer_user',
          'userEmail': 'customer@freshmarket.com',
          'status': 'Delivered',
          'totalAmount': 500.0,
          'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
          'items': [
            {
              'productId': 'prod_meat_box',
              'productNameAr': 'صندوق لحوم',
              'productNameEn': 'Meat Box',
              'price': 500.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500',
              'weight': 1.0,
              'weightUnitId': 'box',
            }
          ],
        }
      ];
      _prefs.setStringList(_ordersKey, seedOrders.map((e) => jsonEncode(e)).toList());
    }
  }

  List<OrderDto> _getOrders() {
    final list = _prefs.getStringList(_ordersKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return OrderDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<OrderDto> list) {
    _prefs.setStringList(_ordersKey, list.map((e) => _encode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => OrderModel.fromDto(dto)).toList());
  }

  @override
  Future<Result<List<OrderEntity>>> getOrders({
    String? userId,
    String? status,
    String? searchQuery,
  }) async {
    var all = _getOrders();
    if (userId != null && userId.isNotEmpty) {
      all = all.where((o) => o.userId == userId).toList();
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      all = all.where((o) => o.status == status).toList();
    }
    var entities = all.map((dto) => OrderModel.fromDto(dto)).toList();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      entities = entities.where((o) =>
          o.id.toLowerCase().contains(query) ||
          o.orderNumber.toLowerCase().contains(query) ||
          o.customerName.toLowerCase().contains(query) ||
          o.phone.toLowerCase().contains(query) ||
          o.address.toLowerCase().contains(query) ||
          o.userEmail.toLowerCase().contains(query)).toList();
    }
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Success(entities);
  }

  @override
  Stream<List<OrderEntity>> watchOrders({
    String? userId,
    String? status,
    String? searchQuery,
  }) {
    Timer.run(() {
      var all = _getOrders();
      if (userId != null && userId.isNotEmpty) {
        all = all.where((o) => o.userId == userId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        all = all.where((o) => o.status == status).toList();
      }
      var entities = all.map((dto) => OrderModel.fromDto(dto)).toList();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        entities = entities.where((o) =>
            o.id.toLowerCase().contains(query) ||
            o.orderNumber.toLowerCase().contains(query) ||
            o.customerName.toLowerCase().contains(query) ||
            o.phone.toLowerCase().contains(query) ||
            o.address.toLowerCase().contains(query) ||
            o.userEmail.toLowerCase().contains(query)).toList();
      }
      entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _controller.add(entities);
    });

    return _controller.stream.map((list) {
      var filtered = list;
      if (userId != null && userId.isNotEmpty) {
        filtered = filtered.where((o) => o.userId == userId).toList();
      }
      if (status != null && status.isNotEmpty && status != 'All') {
        filtered = filtered.where((o) => o.status == status).toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered.where((o) =>
            o.id.toLowerCase().contains(query) ||
            o.orderNumber.toLowerCase().contains(query) ||
            o.customerName.toLowerCase().contains(query) ||
            o.phone.toLowerCase().contains(query) ||
            o.address.toLowerCase().contains(query) ||
            o.userEmail.toLowerCase().contains(query)).toList();
      }
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  @override
  Stream<OrderEntity?> watchOrder(String orderId) {
    return watchOrders().map((list) {
      try {
        return list.firstWhere((o) => o.id == orderId);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<Result<OrderEntity>> createOrder(OrderEntity order) async {
    final all = _getOrders();
    final newId = order.id.isEmpty ? 'order_${DateTime.now().millisecondsSinceEpoch}' : order.id;
    final generatedNum = order.orderNumber.isEmpty 
        ? 'ORD-${DateTime.now().millisecondsSinceEpoch}' 
        : order.orderNumber;

    // Reserve stock from batches using FIFO
    final batchAllocations = <String, Map<String, int>>{};
    try {
      final batchListStr = _prefs.getStringList('mock_batches') ?? [];
      final allBatches = batchListStr.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();

      for (final orderItem in order.items) {
        final pid = orderItem.productId;
        int qtyRemaining = orderItem.quantity;
        final itemAllocations = <String, int>{};

        // Filter batches for this product that are not expired
        final productBatches = allBatches.where((b) {
          final isSameProduct = b['productId'] == pid;
          if (!isSameProduct) return false;
          final expStr = b['expiryDate'] as String? ?? '';
          if (expStr.isEmpty) return true;
          try {
            final exp = DateTime.parse(expStr);
            return exp.isAfter(DateTime.now());
          } catch (_) {
            return true;
          }
        }).toList();

        // Sort by expiryDate ascending (FIFO)
        productBatches.sort((a, b) {
          final expA = DateTime.tryParse(a['expiryDate'] as String? ?? '') ?? DateTime.now();
          final expB = DateTime.tryParse(b['expiryDate'] as String? ?? '') ?? DateTime.now();
          return expA.compareTo(expB);
        });

        for (final batch in productBatches) {
          if (qtyRemaining <= 0) break;
          final avQty = batch['availableQuantity'] as int? ?? 0;
          if (avQty <= 0) continue;

          final deduct = qtyRemaining < avQty ? qtyRemaining : avQty;
          batch['availableQuantity'] = avQty - deduct;
          batch['reservedQuantity'] = (batch['reservedQuantity'] as int? ?? 0) + deduct;
          batch['updatedAt'] = DateTime.now().toIso8601String();

          itemAllocations[batch['id'] as String] = deduct;
          qtyRemaining -= deduct;
        }

        if (itemAllocations.isNotEmpty) {
          batchAllocations[pid] = itemAllocations;
        }
      }

      // Save updated batches back to preferences
      _prefs.setStringList('mock_batches', allBatches.map((b) => jsonEncode(b)).toList());
    } catch (e) {
      debugPrint('[MOCK ORDER BATCH FIFO] Error reserving batch stock: $e');
    }

    final finalOrder = order.copyWith(
      id: newId,
      orderNumber: generatedNum,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      batchAllocations: batchAllocations,
    );
    final dto = OrderModel.fromEntity(finalOrder);
    all.add(dto);
    _saveAll(all);

    // Increment coupon usedCount if applicable
    if (order.couponCode != null && order.couponCode!.isNotEmpty) {
      try {
        final couponListStr = _prefs.getStringList(MockCouponRepository._couponsKey) ?? [];
        final couponIdx = couponListStr.indexWhere((cStr) {
          final decoded = jsonDecode(cStr) as Map;
          return (decoded['code'] as String).trim().toUpperCase() == order.couponCode!.trim().toUpperCase();
        });
        if (couponIdx != -1) {
          final couponMap = Map<String, dynamic>.from(jsonDecode(couponListStr[couponIdx]) as Map);
          int usedCount = couponMap['usedCount'] as int? ?? 0;
          couponMap['usedCount'] = usedCount + 1;
          couponListStr[couponIdx] = jsonEncode(couponMap);
          _prefs.setStringList(MockCouponRepository._couponsKey, couponListStr);
        }
      } catch (e) {
        debugPrint('[MOCK ORDER REPO] Failed to increment coupon count: $e');
      }
    }

    // Adjust loyalty points for the user
    try {
      final userListStr = _prefs.getStringList(MockAuthRepository._usersKey) ?? [];
      final userIdx = userListStr.indexWhere((uStr) {
        final decoded = jsonDecode(uStr) as Map;
        return decoded['id'] == order.userId;
      });
      if (userIdx != -1) {
        final userMap = Map<String, dynamic>.from(jsonDecode(userListStr[userIdx]) as Map);
        int loyaltyPoints = userMap['loyaltyPoints'] as int? ?? 0;
        int lifetimePoints = userMap['lifetimePoints'] as int? ?? 0;
        
        // 1. Subtract redeemed points
        if (order.loyaltyPointsRedeemed != null && order.loyaltyPointsRedeemed! > 0) {
          loyaltyPoints -= order.loyaltyPointsRedeemed!;
        }
        
        // 2. Add earned points
        if (order.loyaltyPointsEarned != null && order.loyaltyPointsEarned! > 0) {
          loyaltyPoints += order.loyaltyPointsEarned!;
          lifetimePoints += order.loyaltyPointsEarned!;
        }
        
        // 3. Re-evaluate membership level
        String level = 'Bronze';
        if (lifetimePoints >= 5000) {
          level = 'Platinum';
        } else if (lifetimePoints >= 1500) {
          level = 'Gold';
        } else if (lifetimePoints >= 500) {
          level = 'Silver';
        }
        
        userMap['loyaltyPoints'] = loyaltyPoints;
        userMap['lifetimePoints'] = lifetimePoints;
        userMap['membershipLevel'] = level;
        userMap['updatedAt'] = DateTime.now().toIso8601String();
        
        userListStr[userIdx] = jsonEncode(userMap);
        _prefs.setStringList(MockAuthRepository._usersKey, userListStr);
        debugPrint('[MOCK LOYALTY] Updated user points: balance=$loyaltyPoints, lifetime=$lifetimePoints, tier=$level');
      }
    } catch (e) {
      debugPrint('[MOCK LOYALTY] Error updating points: $e');
    }

    // Reserve stock for each item in the order
    try {
      final prodListStr = _prefs.getStringList('mock_products') ?? [];
      final updatedProds = prodListStr.map((itemStr) {
        final map = jsonDecode(itemStr) as Map<String, dynamic>;
        final pid = map['id'] as String;
        
        final orderItem = order.items.cast<OrderItemEntity?>().firstWhere((oi) => oi?.productId == pid, orElse: () => null);
        if (orderItem != null) {
          final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 50;
          final res = map['reservedStock'] as int? ?? 0;
          final av = map['availableStock'] as int? ?? map['stockQuantity'] as int? ?? (cur - res);
          
          final newAv = (av - orderItem.quantity).clamp(0, 999999);
          final newRes = res + orderItem.quantity;
          
          map['availableStock'] = newAv;
          map['reservedStock'] = newRes;
          map['stockQuantity'] = newAv; // sync legacy stockQuantity
          
          _logMockStockHistory(
            prefs: _prefs,
            productId: pid,
            productNameAr: map['nameAr'] as String? ?? orderItem.productNameAr,
            productNameEn: map['nameEn'] as String? ?? orderItem.productNameEn,
            type: 'order_created',
            quantityChanged: -orderItem.quantity,
            previousStock: av,
            newStock: newAv,
            reasonAr: 'تم حجز المخزون لطلب جديد رقم ${finalOrder.orderNumber}',
            reasonEn: 'Stock reserved for new order #${finalOrder.orderNumber}',
            createdBy: order.customerId,
          );

          final alertQty = map['reorderLevel'] as int? ?? map['alertQuantity'] as int? ?? 10;
          final nameAr = map['nameAr'] as String? ?? '';
          final nameEn = map['nameEn'] as String? ?? '';
          
          if (newAv == 0) {
            NotificationService.instance.simulateNotification(
              title: 'Out of Stock Alert / تنبيه نفاد المخزون',
              body: 'Product ${nameEn} is out of stock! / المنتج ${nameAr} نفد من المخزون!',
              data: {
                'type': 'system',
                'titleAr': 'تنبيه نفاد المخزون',
                'bodyAr': 'المنتج ${nameAr} نفد من المخزون تماماً!',
                'titleEn': 'Out of Stock Alert',
                'bodyEn': 'Product ${nameEn} is out of stock!',
              },
            );
          } else if (newAv <= alertQty) {
            NotificationService.instance.simulateNotification(
              title: 'Low Stock Alert / تنبيه انخفاض المخزون',
              body: 'Product ${nameEn} is running low (${newAv} remaining). / المنتج ${nameAr} يقترب من النفاد (${newAv} متبقي).',
              data: {
                'type': 'system',
                'titleAr': 'تنبيه انخفاض المخزون',
                'bodyAr': 'المنتج ${nameAr} يقترب من النفاد (${newAv} متبقي).',
                'titleEn': 'Low Stock Alert',
                'bodyEn': 'Product ${nameEn} is running low (${newAv} remaining).',
              },
            );
          }
        }
        return jsonEncode(map);
      }).toList();
      _prefs.setStringList('mock_products', updatedProds);
    } catch (_) {}

    // Simulate notification when order is created
    NotificationService.instance.simulateNotification(
      title: 'Order Placed! / تم تقديم الطلب!',
      body: 'Your order #${newId} is being processed. / طلبك رقم #${newId} قيد المعالجة الآن.',
      data: {
        'type': 'order',
        'orderId': newId,
        'titleAr': 'تم تقديم الطلب!',
        'bodyAr': 'طلبك رقم #${newId} قيد المعالجة الآن.',
        'titleEn': 'Order Placed!',
        'bodyEn': 'Your order #${newId} is being processed.',
      },
    );

    return Success(finalOrder);
  }

  @override
  Future<Result<void>> updateOrderStatus(String orderId, String status) async {
    final all = _getOrders();
    final idx = all.indexWhere((o) => o.id == orderId);
    if (idx == -1) return Failure(FirestoreException(message: 'Order not found'));
    final old = all[idx];
    final oldStatus = old.status;

    if (oldStatus == status) {
      return const Success(null);
    }

    final updated = OrderDto(
      id: old.id,
      orderNumber: old.orderNumber,
      customerId: old.customerId,
      customerName: old.customerName,
      phone: old.phone,
      address: old.address,
      subtotal: old.subtotal,
      deliveryFee: old.deliveryFee,
      total: old.total,
      status: status,
      createdAt: old.createdAt,
      userId: old.userId,
      userEmail: old.userEmail,
      totalAmount: old.totalAmount,
      updatedAt: DateTime.now(),
      items: old.items,
      shippingAddress: old.shippingAddress,
      couponCode: old.couponCode,
      discountAmount: old.discountAmount,
      loyaltyPointsEarned: old.loyaltyPointsEarned,
      loyaltyPointsRedeemed: old.loyaltyPointsRedeemed,
      loyaltyDiscount: old.loyaltyDiscount,
    );
    all[idx] = updated;
    _saveAll(all);

    // Stock allocation rules on transitions
    final isOldStatusReserving = (oldStatus == 'Pending' || oldStatus == 'Confirmed' || oldStatus == 'Preparing' || oldStatus == 'OutForDelivery');

    if (status == 'Cancelled' && isOldStatusReserving) {
      try {
        final prodListStr = _prefs.getStringList('mock_products') ?? [];
        final updatedProds = prodListStr.map((itemStr) {
          final map = jsonDecode(itemStr) as Map<String, dynamic>;
          final pid = map['id'] as String;
          
          final orderItems = old.items.where((oi) => oi.productId == pid).toList();
          if (orderItems.isNotEmpty) {
            final orderItem = orderItems.first;
            final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 50;
            final res = map['reservedStock'] as int? ?? 0;
            final av = map['availableStock'] as int? ?? map['stockQuantity'] as int? ?? (cur - res);
            
            final newAv = av + orderItem.quantity;
            final newRes = (res - orderItem.quantity).clamp(0, 999999);
            
            map['availableStock'] = newAv;
            map['reservedStock'] = newRes;
            map['stockQuantity'] = newAv; // sync legacy stockQuantity
            
            _logMockStockHistory(
              prefs: _prefs,
              productId: pid,
              productNameAr: map['nameAr'] as String? ?? orderItem.productNameAr,
              productNameEn: map['nameEn'] as String? ?? orderItem.productNameEn,
              type: 'order_cancelled',
              quantityChanged: orderItem.quantity,
              previousStock: av,
              newStock: newAv,
              reasonAr: 'تم إرجاع المخزون لإلغاء الطلب رقم ${old.orderNumber}',
              reasonEn: 'Stock restored due to cancellation of order #${old.orderNumber}',
              createdBy: old.customerId,
            );
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_products', updatedProds);
      } catch (_) {}

      // Restore allocated batch stock on Cancellation
      try {
        if (old.batchAllocations != null && old.batchAllocations!.isNotEmpty) {
          final batchListStr = _prefs.getStringList('mock_batches') ?? [];
          final allBatches = batchListStr.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();

          old.batchAllocations!.forEach((productId, allocations) {
            allocations.forEach((batchId, qty) {
              final batchIdx = allBatches.indexWhere((b) => b['id'] == batchId);
              if (batchIdx != -1) {
                final b = allBatches[batchIdx];
                final av = b['availableQuantity'] as int? ?? 0;
                final res = b['reservedQuantity'] as int? ?? 0;
                b['availableQuantity'] = av + qty;
                b['reservedQuantity'] = (res - qty).clamp(0, 999999);
                b['updatedAt'] = DateTime.now().toIso8601String();
              }
            });
          });
          _prefs.setStringList('mock_batches', allBatches.map((b) => jsonEncode(b)).toList());
        }
      } catch (e) {
        debugPrint('[MOCK BATCH CANCEL] Error restoring batch stock: $e');
      }
    } else if (status == 'Delivered' && isOldStatusReserving) {
      try {
        final prodListStr = _prefs.getStringList('mock_products') ?? [];
        final updatedProds = prodListStr.map((itemStr) {
          final map = jsonDecode(itemStr) as Map<String, dynamic>;
          final pid = map['id'] as String;
          
          final orderItems = old.items.where((oi) => oi.productId == pid).toList();
          if (orderItems.isNotEmpty) {
            final orderItem = orderItems.first;
            final cur = map['currentStock'] as int? ?? map['stockQuantity'] as int? ?? 50;
            final res = map['reservedStock'] as int? ?? 0;
            
            final newCur = (cur - orderItem.quantity).clamp(0, 999999);
            final newRes = (res - orderItem.quantity).clamp(0, 999999);
            
            map['currentStock'] = newCur;
            map['reservedStock'] = newRes;
            
            _logMockStockHistory(
              prefs: _prefs,
              productId: pid,
              productNameAr: map['nameAr'] as String? ?? orderItem.productNameAr,
              productNameEn: map['nameEn'] as String? ?? orderItem.productNameEn,
              type: 'fulfillment',
              quantityChanged: -orderItem.quantity,
              previousStock: cur,
              newStock: newCur,
              reasonAr: 'تم تسليم المنتجات وتعديل المخزون الفعلي للطلب رقم ${old.orderNumber}',
              reasonEn: 'Physical stock decremented upon delivery of order #${old.orderNumber}',
              createdBy: 'system',
            );
          }
          return jsonEncode(map);
        }).toList();
        _prefs.setStringList('mock_products', updatedProds);
      } catch (_) {}

      // Finalize batch stock deduction on Delivery
      try {
        if (old.batchAllocations != null && old.batchAllocations!.isNotEmpty) {
          final batchListStr = _prefs.getStringList('mock_batches') ?? [];
          final allBatches = batchListStr.map((s) => Map<String, dynamic>.from(jsonDecode(s) as Map)).toList();

          old.batchAllocations!.forEach((productId, allocations) {
            allocations.forEach((batchId, qty) {
              final batchIdx = allBatches.indexWhere((b) => b['id'] == batchId);
              if (batchIdx != -1) {
                final b = allBatches[batchIdx];
                final cur = b['currentQuantity'] as int? ?? 0;
                final res = b['reservedQuantity'] as int? ?? 0;
                b['currentQuantity'] = (cur - qty).clamp(0, 999999);
                b['reservedQuantity'] = (res - qty).clamp(0, 999999);
                b['updatedAt'] = DateTime.now().toIso8601String();
              }
            });
          });
          _prefs.setStringList('mock_batches', allBatches.map((b) => jsonEncode(b)).toList());
        }
      } catch (e) {
        debugPrint('[MOCK BATCH DELIVER] Error deducting actual batch stock: $e');
      }
    }

    // Localized status names for notifications
    final statusAr = _getStatusAr(status);
    final statusEn = status;

    NotificationService.instance.simulateNotification(
      title: 'Order Status Updated / تحديث حالة الطلب',
      body: 'Order #${orderId} is now ${statusEn}. / حالة الطلب #${orderId} أصبحت ${statusAr}.',
      data: {
        'type': 'order',
        'orderId': orderId,
        'titleAr': 'تحديث حالة الطلب',
        'bodyAr': 'حالة الطلب #${orderId} أصبحت ${statusAr}.',
        'titleEn': 'Order Status Updated',
        'bodyEn': 'Order #${orderId} is now ${statusEn}.',
      },
    );

    return const Success(null);
  }

  String _getStatusAr(String status) {
    switch (status) {
      case 'Pending': return 'قيد الانتظار';
      case 'Confirmed': return 'تم التأكيد';
      case 'Preparing': return 'قيد التجهيز';
      case 'OutForDelivery': return 'خارج للتوصيل';
      case 'Delivered': return 'تم التوصيل';
      case 'Cancelled': return 'ملغي';
      default: return status;
    }
  }
}

// ==========================================
// 11. MOCK ADDRESS REPOSITORY
// ==========================================
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

// ==========================================
// 12. MOCK COUPON REPOSITORY
// ==========================================
class MockCouponRepository implements CouponRepository {
  static const String _couponsKey = 'mock_coupons';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<CouponEntity>>.broadcast();

  MockCouponRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_couponsKey) ?? [];
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
      _prefs.setStringList(_couponsKey, seeds.map((e) => jsonEncode(e)).toList());
    }
  }

  List<CouponDto> _getCoupons() {
    final list = _prefs.getStringList(_couponsKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return CouponDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<CouponDto> list) {
    _prefs.setStringList(_couponsKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
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

// ==========================================
// 13. MOCK AUDIT LOG REPOSITORY
// ==========================================
class MockAuditLogRepository implements AuditLogRepository {
  static const String _auditLogsKey = 'mock_audit_logs';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<AuditLogEntity>>.broadcast();

  MockAuditLogRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_auditLogsKey) ?? [];
    if (list.isEmpty) {
      final testLog = {
        'id': 'log_init',
        'userId': 'admin_user',
        'userEmail': 'admin@freshmarket.com',
        'action': 'System Setup',
        'details': 'Fresh Market systems initialized.',
        'timestamp': DateTime.now().toIso8601String(),
      };
      _prefs.setStringList(_auditLogsKey, [jsonEncode(testLog)]);
    }
  }

  List<AuditLogDto> _getLogs() {
    final list = _prefs.getStringList(_auditLogsKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return AuditLogDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<AuditLogDto> list) {
    _prefs.setStringList(_auditLogsKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => AuditLogModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<AuditLogEntity>>> getAuditLogs({int limit = 100}) async {
    final list = _getLogs().map((dto) => AuditLogModel.fromDto(dto).toEntity()).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return Success(list.take(limit).toList());
  }

  @override
  Future<Result<AuditLogEntity>> createAuditLog(AuditLogEntity log) async {
    final all = _getLogs();
    final newId = log.id.isEmpty ? 'log_${DateTime.now().millisecondsSinceEpoch}' : log.id;
    final finalLog = log.copyWith(id: newId, timestamp: DateTime.now());
    all.add(AuditLogModel.fromEntity(finalLog));
    _saveAll(all);
    return Success(finalLog);
  }

  @override
  Stream<List<AuditLogEntity>> watchAuditLogs({int limit = 100}) {
    Timer.run(() {
      final list = _getLogs().map((dto) => AuditLogModel.fromDto(dto).toEntity()).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _controller.add(list.take(limit).toList());
    });
    return _controller.stream;
  }
}

// ==========================================
// 14. MOCK SUPPLIER REPOSITORY
// ==========================================
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

// ==========================================
// 15. MOCK PURCHASE ORDER REPOSITORY
// ==========================================
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
              _logMockStockHistory(
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
          _logMockStockHistory(
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

// ==========================================
// 16. MOCK SUPPLIER PAYMENT REPOSITORY
// ==========================================
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

void _logMockStockHistory({
  required SharedPreferences prefs,
  required String productId,
  required String productNameAr,
  required String productNameEn,
  required String type,
  required int quantityChanged,
  required int previousStock,
  required int newStock,
  required String reasonAr,
  required String reasonEn,
  required String createdBy,
}) {
  final list = prefs.getStringList('mock_stock_history') ?? [];
  final entry = {
    'id': 'log_${DateTime.now().millisecondsSinceEpoch}_${productId.hashCode}',
    'productId': productId,
    'productNameAr': productNameAr,
    'productNameEn': productNameEn,
    'type': type,
    'quantityChanged': quantityChanged,
    'previousStock': previousStock,
    'newStock': newStock,
    'reasonAr': reasonAr,
    'reasonEn': reasonEn,
    'createdAt': DateTime.now().toIso8601String(),
    'createdBy': createdBy.isNotEmpty ? createdBy : 'system',
  };
  list.insert(0, jsonEncode(entry));
  prefs.setStringList('mock_stock_history', list);
}

// ==========================================
// 15. MOCK STOCK HISTORY REPOSITORY
// ==========================================
class MockStockHistoryRepository implements StockHistoryRepository {
  final SharedPreferences _prefs;
  final _controller = StreamController<List<StockHistoryEntity>>.broadcast();

  MockStockHistoryRepository(this._prefs);

  List<StockHistoryEntity> _getLogs() {
    final list = _prefs.getStringList('mock_stock_history') ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return StockHistoryDto.fromMap(map, map['id'] as String).toEntity();
    }).toList();
  }

  @override
  Future<Result<List<StockHistoryEntity>>> getStockHistory({String? productId}) async {
    var logs = _getLogs();
    if (productId != null && productId.isNotEmpty) {
      logs = logs.where((l) => l.productId == productId).toList();
    }
    return Success(logs);
  }

  @override
  Stream<List<StockHistoryEntity>> watchStockHistory({String? productId}) {
    Timer.run(() {
      var logs = _getLogs();
      if (productId != null && productId.isNotEmpty) {
        logs = logs.where((l) => l.productId == productId).toList();
      }
      _controller.add(logs);
    });
    return _controller.stream;
  }

  @override
  Future<Result<void>> logStockMovement(StockHistoryEntity entry) async {
    final list = _prefs.getStringList('mock_stock_history') ?? [];
    final dto = StockHistoryDto.fromEntity(entry);
    final map = dto.toMap();
    final newId = entry.id.isEmpty ? 'log_${DateTime.now().millisecondsSinceEpoch}' : entry.id;
    map['id'] = newId;
    map['createdAt'] = DateTime.now().toIso8601String();
    
    list.insert(0, jsonEncode(map));
    _prefs.setStringList('mock_stock_history', list);
    
    _controller.add(_getLogs());
    return const Success(null);
  }
}

// ==========================================
// 17. MOCK BATCH REPOSITORY
// ==========================================
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

// 18. MOCK EXPENSE REPOSITORY
// ==========================================
class MockExpenseRepository implements ExpenseRepository {
  static const String _expensesKey = 'mock_expenses';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<ExpenseEntity>>.broadcast();

  MockExpenseRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(_expensesKey) ?? [];
    if (list.isEmpty) {
      final now = DateTime.now();
      final seedExpenses = [
        {
          'id': 'expense_seed_1',
          'category': 'Rent',
          'amount': 12000.0,
          'currency': 'EGP',
          'expenseDate': now.subtract(const Duration(days: 10)).toIso8601String(),
          'description': 'Store monthly rent',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_2',
          'category': 'Salaries',
          'amount': 35000.0,
          'currency': 'E£',
          'expenseDate': now.subtract(const Duration(days: 5)).toIso8601String(),
          'description': 'June salaries layout',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_3',
          'category': 'Electricity',
          'amount': 2200.0,
          'currency': 'EGP',
          'expenseDate': now.subtract(const Duration(days: 3)).toIso8601String(),
          'description': 'Main warehouse bill',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_4',
          'category': 'Internet',
          'amount': 600.0,
          'currency': 'EGP',
          'expenseDate': now.subtract(const Duration(days: 2)).toIso8601String(),
          'description': 'Fiber internet subscription',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_5',
          'category': 'Fuel',
          'amount': 1500.0,
          'currency': 'E£',
          'expenseDate': now.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'Delivery bikes fuel allowance',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'expense_seed_6',
          'category': 'Maintenance',
          'amount': 1800.0,
          'currency': 'EGP',
          'expenseDate': now.toIso8601String(),
          'description': 'Fridge repair works',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
      _prefs.setStringList(_expensesKey, seedExpenses.map((e) => jsonEncode(e)).toList());
    }
  }

  List<ExpenseDto> _getExpenses() {
    final list = _prefs.getStringList(_expensesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return ExpenseDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveAll(List<ExpenseDto> list) {
    _prefs.setStringList(_expensesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _controller.add(list.map((dto) => ExpenseModel.fromDto(dto).toEntity()).toList());
  }

  @override
  Future<Result<List<ExpenseEntity>>> getExpenses() async {
    final all = _getExpenses()
        .map((dto) => ExpenseModel.fromDto(dto).toEntity())
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return Success(all);
  }

  @override
  Stream<List<ExpenseEntity>> watchExpenses() {
    Timer.run(() {
      final all = _getExpenses()
          .map((dto) => ExpenseModel.fromDto(dto).toEntity())
          .toList()
        ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      _controller.add(all);
    });
    return _controller.stream;
  }

  @override
  Future<Result<ExpenseEntity>> createExpense(ExpenseEntity expense) async {
    final all = _getExpenses();
    final newId = expense.id.isEmpty ? 'expense_${DateTime.now().millisecondsSinceEpoch}' : expense.id;
    final finalExpense = expense.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(ExpenseModel.fromEntity(finalExpense));
    _saveAll(all);
    return Success(finalExpense);
  }

  @override
  Future<Result<ExpenseEntity>> updateExpense(ExpenseEntity expense) async {
    final all = _getExpenses();
    final idx = all.indexWhere((e) => e.id == expense.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Expense not found'));
    final finalExpense = expense.copyWith(updatedAt: DateTime.now());
    all[idx] = ExpenseModel.fromEntity(finalExpense);
    _saveAll(all);
    return Success(finalExpense);
  }

  @override
  Future<Result<void>> deleteExpense(String expenseId) async {
    final all = _getExpenses();
    all.removeWhere((e) => e.id == expenseId);
    _saveAll(all);
    return const Success(null);
  }
}

// ==========================================
// 19. MOCK WAREHOUSE REPOSITORY
// ==========================================
class MockWarehouseRepository implements WarehouseRepository {
  static const String _warehousesKey = 'mock_warehouses';
  static const String _inventoriesKey = 'mock_warehouse_inventories';
  static const String _transfersKey = 'mock_stock_transfers';

  final SharedPreferences _prefs;
  final _warehouseController = StreamController<List<WarehouseEntity>>.broadcast();
  final _inventoryController = StreamController<List<WarehouseInventoryEntity>>.broadcast();
  final _transferController = StreamController<List<StockTransferEntity>>.broadcast();

  MockWarehouseRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final now = DateTime.now();
    
    // 1. Seed Warehouses
    final warehouseList = _prefs.getStringList(_warehousesKey) ?? [];
    if (warehouseList.isEmpty) {
      final seedWarehouses = [
        {
          'id': 'warehouse_cairo',
          'nameAr': 'مستودع القاهرة الرئيسي',
          'nameEn': 'Cairo Main Hub',
          'locationAr': 'القاهرة، مصر',
          'locationEn': 'Cairo, Egypt',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex',
          'nameAr': 'مستودع الإسكندرية السريع',
          'nameEn': 'Alexandria Express',
          'locationAr': 'الإسكندرية، مصر',
          'locationEn': 'Alexandria, Egypt',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_giza',
          'nameAr': 'مستودع الجيزة المبرد',
          'nameEn': 'Giza Cold Storage',
          'locationAr': 'الجيزة، مصر',
          'locationEn': 'Giza, Egypt',
          'isActive': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
      _prefs.setStringList(_warehousesKey, seedWarehouses.map((e) => jsonEncode(e)).toList());
    }

    // 2. Seed Inventories
    final inventoryList = _prefs.getStringList(_inventoriesKey) ?? [];
    if (inventoryList.isEmpty) {
      final seedInventories = [
        // prod_minced_meat: Total 50
        {
          'id': 'warehouse_cairo_prod_minced_meat',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_minced_meat',
          'quantity': 30,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_minced_meat',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_minced_meat',
          'quantity': 20,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_meat_box: Total 20
        {
          'id': 'warehouse_cairo_prod_meat_box',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_meat_box',
          'quantity': 12,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_meat_box',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_meat_box',
          'quantity': 8,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_chicken: Total 50
        {
          'id': 'warehouse_cairo_prod_chicken',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_chicken',
          'quantity': 25,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_chicken',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_chicken',
          'quantity': 15,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_giza_prod_chicken',
          'warehouseId': 'warehouse_giza',
          'productId': 'prod_chicken',
          'quantity': 10,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_frozen_burger: Total 40 (based on seed 2 current=20 + seed 3 current=10 + seed 1 default=10?)
        {
          'id': 'warehouse_cairo_prod_frozen_burger',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_frozen_burger',
          'quantity': 20,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_frozen_burger',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_frozen_burger',
          'quantity': 20,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        // prod_fresh_milk: Total 50
        {
          'id': 'warehouse_cairo_prod_fresh_milk',
          'warehouseId': 'warehouse_cairo',
          'productId': 'prod_fresh_milk',
          'quantity': 40,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
        {
          'id': 'warehouse_alex_prod_fresh_milk',
          'warehouseId': 'warehouse_alex',
          'productId': 'prod_fresh_milk',
          'quantity': 10,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      ];
      _prefs.setStringList(_inventoriesKey, seedInventories.map((e) => jsonEncode(e)).toList());
    }

    // 3. Seed Transfers (Empty initially)
    final transferList = _prefs.getStringList(_transfersKey) ?? [];
    if (transferList.isEmpty) {
      _prefs.setStringList(_transfersKey, []);
    }
  }

  // Helper getters
  List<WarehouseDto> _getWarehouses() {
    final list = _prefs.getStringList(_warehousesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return WarehouseDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  List<WarehouseInventoryDto> _getInventories() {
    final list = _prefs.getStringList(_inventoriesKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return WarehouseInventoryDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  List<StockTransferDto> _getTransfers() {
    final list = _prefs.getStringList(_transfersKey) ?? [];
    return list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return StockTransferDto.fromMap(map, map['id'] as String? ?? '');
    }).toList();
  }

  void _saveWarehouses(List<WarehouseDto> list) {
    _prefs.setStringList(_warehousesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _warehouseController.add(list.map((dto) => WarehouseModel.fromDto(dto).toEntity()).toList());
  }

  void _saveInventories(List<WarehouseInventoryDto> list) {
    _prefs.setStringList(_inventoriesKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _inventoryController.add(list.map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity()).toList());
  }

  void _saveTransfers(List<StockTransferDto> list) {
    _prefs.setStringList(_transfersKey, list.map((e) => jsonEncode(e.toMap()..['id'] = e.id)).toList());
    _transferController.add(list.map((dto) => StockTransferModel.fromDto(dto).toEntity()).toList());
  }

  // Dynamically sync global product stock
  void _syncProductGlobalStock(String productId) {
    final inventories = _getInventories().where((i) => i.productId == productId);
    final totalStock = inventories.fold<int>(0, (sum, item) => sum + item.quantity);

    final prodList = _prefs.getStringList(MockProductRepository._productsKey) ?? [];
    final products = prodList.map((e) {
      final map = _decodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();

    final idx = products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final old = products[idx];
      final updated = ProductDto(
        id: old.id,
        nameAr: old.nameAr,
        nameEn: old.nameEn,
        descriptionAr: old.descriptionAr,
        descriptionEn: old.descriptionEn,
        price: old.price,
        weight: old.weight,
        weightUnitId: old.weightUnitId,
        imageUrl: old.imageUrl,
        imageThumbUrl: old.imageThumbUrl,
        categoryId: old.categoryId,
        isFeatured: old.isFeatured,
        isAvailable: old.isAvailable,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        currentStock: totalStock,
        reservedStock: old.reservedStock,
        availableStock: totalStock - old.reservedStock,
        minimumStock: old.minimumStock,
        reorderLevel: old.reorderLevel,
      );
      products[idx] = updated;
      _prefs.setStringList(MockProductRepository._productsKey, products.map((p) => _encode(p.toMap()..['id'] = p.id)).toList());
    }
  }

  // WAREHOUSE CRUD
  @override
  Future<Result<List<WarehouseEntity>>> getWarehouses() async {
    final all = _getWarehouses().map((dto) => WarehouseModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<WarehouseEntity>> watchWarehouses() {
    Timer.run(() {
      final all = _getWarehouses().map((dto) => WarehouseModel.fromDto(dto).toEntity()).toList();
      _warehouseController.add(all);
    });
    return _warehouseController.stream;
  }

  @override
  Future<Result<WarehouseEntity>> createWarehouse(WarehouseEntity warehouse) async {
    final all = _getWarehouses();
    final newId = warehouse.id.isEmpty ? 'warehouse_${DateTime.now().millisecondsSinceEpoch}' : warehouse.id;
    final finalWh = warehouse.copyWith(
      id: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    all.add(WarehouseModel.fromEntity(finalWh));
    _saveWarehouses(all);
    return Success(finalWh);
  }

  @override
  Future<Result<WarehouseEntity>> updateWarehouse(WarehouseEntity warehouse) async {
    final all = _getWarehouses();
    final idx = all.indexWhere((w) => w.id == warehouse.id);
    if (idx == -1) return Failure(FirestoreException(message: 'Warehouse not found'));
    final finalWh = warehouse.copyWith(updatedAt: DateTime.now());
    all[idx] = WarehouseModel.fromEntity(finalWh);
    _saveWarehouses(all);
    return Success(finalWh);
  }

  @override
  Future<Result<void>> deleteWarehouse(String warehouseId) async {
    final all = _getWarehouses();
    all.removeWhere((w) => w.id == warehouseId);
    _saveWarehouses(all);

    // Delete related inventory too
    final inventories = _getInventories();
    inventories.removeWhere((i) => i.warehouseId == warehouseId);
    _saveInventories(inventories);

    return const Success(null);
  }

  // INVENTORY
  @override
  Future<Result<List<WarehouseInventoryEntity>>> getWarehouseInventories() async {
    final all = _getInventories().map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<WarehouseInventoryEntity>> watchWarehouseInventories() {
    Timer.run(() {
      final all = _getInventories().map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity()).toList();
      _inventoryController.add(all);
    });
    return _inventoryController.stream;
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForWarehouse(String warehouseId) async {
    final filtered = _getInventories()
        .where((i) => i.warehouseId == warehouseId)
        .map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity())
        .toList();
    return Success(filtered);
  }

  @override
  Future<Result<List<WarehouseInventoryEntity>>> getInventoryForProduct(String productId) async {
    final filtered = _getInventories()
        .where((i) => i.productId == productId)
        .map((dto) => WarehouseInventoryModel.fromDto(dto).toEntity())
        .toList();
    return Success(filtered);
  }

  @override
  Future<Result<WarehouseInventoryEntity>> updateInventoryQuantity(
    String warehouseId,
    String productId,
    int quantity,
  ) async {
    final all = _getInventories();
    final id = '${warehouseId}_$productId';
    final idx = all.indexWhere((i) => i.id == id);

    // Fetch product details for logging
    final prodList = _prefs.getStringList(MockProductRepository._productsKey) ?? [];
    final products = prodList.map((e) {
      final map = _decodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
    final prod = products.firstWhere((p) => p.id == productId, orElse: () => ProductDto(
      id: productId, nameAr: 'منتج غير معروف', nameEn: 'Unknown Product', price: 0.0, weight: 0.0, weightUnitId: 'unit', categoryId: '', isFeatured: false, isAvailable: true, createdAt: DateTime.now(), updatedAt: DateTime.now(), currentStock: 0, availableStock: 0,
    ));

    final oldQty = idx != -1 ? all[idx].quantity : 0;

    final newDto = WarehouseInventoryDto(
      id: id,
      warehouseId: warehouseId,
      productId: productId,
      quantity: quantity,
      createdAt: idx != -1 ? all[idx].createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (idx != -1) {
      all[idx] = newDto;
    } else {
      all.add(newDto);
    }
    _saveInventories(all);
    _syncProductGlobalStock(productId);

    // Log stock history
    _logMockStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: prod.nameAr,
      productNameEn: prod.nameEn,
      type: 'adjustment',
      quantityChanged: quantity - oldQty,
      previousStock: oldQty,
      newStock: quantity,
      reasonAr: 'تعديل مخزون المستودع المباشر',
      reasonEn: 'Direct warehouse inventory adjustment',
      createdBy: 'admin',
    );

    return Success(WarehouseInventoryModel.fromDto(newDto).toEntity());
  }

  // TRANSFERS
  @override
  Future<Result<List<StockTransferEntity>>> getStockTransfers() async {
    final all = _getTransfers().map((dto) => StockTransferModel.fromDto(dto).toEntity()).toList();
    return Success(all);
  }

  @override
  Stream<List<StockTransferEntity>> watchStockTransfers() {
    Timer.run(() {
      final all = _getTransfers().map((dto) => StockTransferModel.fromDto(dto).toEntity()).toList();
      _transferController.add(all);
    });
    return _transferController.stream;
  }

  @override
  Future<Result<StockTransferEntity>> transferStock({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    if (quantity <= 0) {
      return Failure(FirestoreException(message: 'Quantity must be greater than 0'));
    }
    if (fromWarehouseId == toWarehouseId) {
      return Failure(FirestoreException(message: 'Source and destination warehouses must be different'));
    }

    final inventories = _getInventories();
    final fromId = '${fromWarehouseId}_$productId';
    final toId = '${toWarehouseId}_$productId';

    final fromIdx = inventories.indexWhere((i) => i.id == fromId);
    final currentFromQty = fromIdx != -1 ? inventories[fromIdx].quantity : 0;

    if (currentFromQty < quantity) {
      return Failure(FirestoreException(message: 'Insufficient stock in source warehouse'));
    }

    // Deduct from source
    final updatedFrom = inventories[fromIdx].copyWith(
      quantity: currentFromQty - quantity,
      updatedAt: DateTime.now(),
    );
    inventories[fromIdx] = updatedFrom;

    // Add to destination
    final toIdx = inventories.indexWhere((i) => i.id == toId);
    final currentToQty = toIdx != -1 ? inventories[toIdx].quantity : 0;
    if (toIdx != -1) {
      inventories[toIdx] = inventories[toIdx].copyWith(
        quantity: currentToQty + quantity,
        updatedAt: DateTime.now(),
      );
    } else {
      inventories.add(WarehouseInventoryDto(
        id: toId,
        warehouseId: toWarehouseId,
        productId: productId,
        quantity: quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }

    // Save inventories
    _saveInventories(inventories);
    _syncProductGlobalStock(productId);

    // Save transfer record
    final transfers = _getTransfers();
    final transferId = 'transfer_${DateTime.now().millisecondsSinceEpoch}';
    final newTransfer = StockTransferDto(
      id: transferId,
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      productId: productId,
      quantity: quantity,
      transferDate: DateTime.now(),
      notes: notes,
      status: 'Completed',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    transfers.add(newTransfer);
    _saveTransfers(transfers);

    // Resolve Names for Logging
    final warehouses = _getWarehouses();
    final fromWh = warehouses.firstWhere((w) => w.id == fromWarehouseId, orElse: () => WarehouseDto(id: fromWarehouseId, nameAr: 'مستودع مصدر', nameEn: 'Source Wh', locationAr: '', locationEn: '', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()));
    final toWh = warehouses.firstWhere((w) => w.id == toWarehouseId, orElse: () => WarehouseDto(id: toWarehouseId, nameAr: 'مستودع هدف', nameEn: 'Target Wh', locationAr: '', locationEn: '', isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now()));

    final prodList = _prefs.getStringList(MockProductRepository._productsKey) ?? [];
    final products = prodList.map((e) {
      final map = _decodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
    final prod = products.firstWhere((p) => p.id == productId, orElse: () => ProductDto(
      id: productId, nameAr: 'منتج غير معروف', nameEn: 'Unknown Product', price: 0.0, weight: 0.0, weightUnitId: 'unit', categoryId: '', isFeatured: false, isAvailable: true, createdAt: DateTime.now(), updatedAt: DateTime.now(), currentStock: 0, availableStock: 0,
    ));

    // Log double entry stock histories
    _logMockStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: prod.nameAr,
      productNameEn: prod.nameEn,
      type: 'transfer_out',
      quantityChanged: -quantity,
      previousStock: currentFromQty,
      newStock: currentFromQty - quantity,
      reasonAr: 'نقل مخزون خارج إلى ${toWh.nameAr}',
      reasonEn: 'Transfer stock out to ${toWh.nameEn}',
      createdBy: 'admin',
    );

    _logMockStockHistory(
      prefs: _prefs,
      productId: productId,
      productNameAr: prod.nameAr,
      productNameEn: prod.nameEn,
      type: 'transfer_in',
      quantityChanged: quantity,
      previousStock: currentToQty,
      newStock: currentToQty + quantity,
      reasonAr: 'استلام مخزون من ${fromWh.nameAr}',
      reasonEn: 'Received stock transfer from ${fromWh.nameEn}',
      createdBy: 'admin',
    );

    return Success(StockTransferModel.fromDto(newTransfer).toEntity());
  }
}

