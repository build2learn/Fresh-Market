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
      final map = mockDecodeMap(e);
      return LookupDto.fromMap(map, map['id']?.toString() ?? '');
    }).toList();
  }

  void _saveAll(List<LookupDto> list) {
    _prefs.setStringList(_lookupsKey, list.map((e) => mockEncode(e.toMap()..['id'] = e.id)).toList());
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
