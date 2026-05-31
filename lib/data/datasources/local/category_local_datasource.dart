import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/category.dto.dart';

abstract interface class CategoryLocalDataSource {
  Future<List<CategoryDto>> getAll();
  Future<void> cacheAll(List<CategoryDto> categories);
  Future<void> clear();
  Future<DateTime?> getLastSyncTimestamp();
  Future<void> setLastSyncTimestamp(DateTime timestamp);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  static const String _cacheKey = 'cached_categories';
  static const String _syncTimestampKey = 'categories_last_sync';

  final SharedPreferences _prefs;

  CategoryLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<CategoryDto>> getAll() async {
    final json = _prefs.getString(_cacheKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => CategoryDto.fromMap(
              e as Map<String, dynamic>,
              e['id'] as String,
            ))
        .toList();
  }

  @override
  Future<void> cacheAll(List<CategoryDto> categories) async {
    final json = jsonEncode(categories.map((c) => c.toMap()).toList());
    await _prefs.setString(_cacheKey, json);
    await setLastSyncTimestamp(DateTime.now());
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_syncTimestampKey);
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    final millis = _prefs.getInt(_syncTimestampKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<void> setLastSyncTimestamp(DateTime timestamp) async {
    await _prefs.setInt(_syncTimestampKey, timestamp.millisecondsSinceEpoch);
  }
}
