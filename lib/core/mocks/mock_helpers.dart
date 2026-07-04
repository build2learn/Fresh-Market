import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String mockEncode(dynamic value) {
  return jsonEncode(value, toEncodable: (item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    try {
      return (item as dynamic).toDate().toIso8601String();
    } catch (_) {}
    try {
      return (item as dynamic).toJson();
    } catch (_) {}
    return item.toString();
  });
}

Map<String, dynamic> mockDecodeMap(String jsonStr) {
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

void mockLogStockHistory({
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
