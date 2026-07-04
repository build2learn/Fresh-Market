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
import 'package:fresh_market/core/mocks/mock_product_repository.dart';

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
      _prefs.setStringList(_offersKey, [mockEncode(o1.toMap()..['id'] = o1.id)]);
      _prefs.setStringList(_offerProductsKey, [
        mockEncode({'id': 'op1', 'offerId': 'offer_summer', 'productId': 'prod_minced_meat', 'createdAt': DateTime.now().toIso8601String()}),
        mockEncode({'id': 'op2', 'offerId': 'offer_summer', 'productId': 'prod_meat_box', 'createdAt': DateTime.now().toIso8601String()}),
      ]);
    }
  }

  List<OfferDto> _getOffers() {
    final list = _prefs.getStringList(_offersKey) ?? [];
    return list.map((e) {
      final map = mockDecodeMap(e);
      return OfferDto.fromMap(map, map['id'] as String);
    }).toList();
  }

  List<Map<String, dynamic>> _getOfferProducts() {
    final list = _prefs.getStringList(_offerProductsKey) ?? [];
    return list.map((e) => mockDecodeMap(e)).toList();
  }

  void _saveAll(List<OfferDto> offers) {
    _prefs.setStringList(_offersKey, offers.map((o) => mockEncode(o.toMap()..['id'] = o.id)).toList());
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
    final prodKey = _prefs.getStringList(MockProductRepository.productsKey) ?? [];
    final allProds = prodKey.map((e) {
      final map = mockDecodeMap(e);
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
    _prefs.setStringList(_offerProductsKey, mappings.map((m) => mockEncode(m)).toList());

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
    _prefs.setStringList(_offerProductsKey, mappings.map((m) => mockEncode(m)).toList());

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
    _prefs.setStringList(_offerProductsKey, mappings.map((m) => mockEncode(m)).toList());

    return const Success(null);
  }
}
