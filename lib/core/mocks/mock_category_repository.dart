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
      final map = mockDecodeMap(e);
      return CategoryDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<CategoryDto> categories) {
    _prefs.setStringList(_categoriesKey, categories.map((c) => mockEncode(c.toMap()..['id'] = c.id)).toList());
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
