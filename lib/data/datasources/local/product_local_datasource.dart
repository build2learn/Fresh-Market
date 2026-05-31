import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/product.dto.dart';

abstract interface class ProductLocalDataSource {
  Future<List<ProductDto>> getAll();
  Future<void> cacheAll(List<ProductDto> products);
  Future<void> clear();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _cacheKey = 'cached_products';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<ProductDto>> getAll() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final json = prefs.getString(_cacheKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => ProductDto.fromMap(
              e as Map<String, dynamic>,
              e['id'] as String,
            ))
        .toList();
  }

  @override
  Future<void> cacheAll(List<ProductDto> products) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final json = jsonEncode(products.map((p) => p.toMap()).toList());
    await prefs.setString(_cacheKey, json);
  }

  @override
  Future<void> clear() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
