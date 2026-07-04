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

class MockProductRepository implements ProductRepository {
  static const String productsKey = 'mock_products';
  final SharedPreferences _prefs;
  final _controller = StreamController<List<ProductEntity>>.broadcast();

  MockProductRepository(this._prefs) {
    _seedIfEmpty();
  }

  void _seedIfEmpty() {
    final list = _prefs.getStringList(productsKey) ?? [];
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
    final list = _prefs.getStringList(productsKey) ?? [];
    return list.map((e) {
      final map = mockDecodeMap(e);
      return ProductDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  void _saveAll(List<ProductDto> products) {
    _prefs.setStringList(productsKey, products.map((p) => mockEncode(p.toMap()..['id'] = p.id)).toList());
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

    mockLogStockHistory(
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

    mockLogStockHistory(
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
