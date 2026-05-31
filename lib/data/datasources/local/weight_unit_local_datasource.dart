import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/weight_unit.dto.dart';

abstract interface class WeightUnitLocalDataSource {
  Future<List<WeightUnitDto>> getAll();
  Future<void> cacheAll(List<WeightUnitDto> units);
  Future<void> clear();
  Future<DateTime?> getLastSyncTimestamp();
  Future<void> setLastSyncTimestamp(DateTime timestamp);
}

class WeightUnitLocalDataSourceImpl implements WeightUnitLocalDataSource {
  static const String _cacheKey = 'cached_weight_units';
  static const String _syncTimestampKey = 'weight_units_last_sync';

  final SharedPreferences _prefs;

  WeightUnitLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<WeightUnitDto>> getAll() async {
    final json = _prefs.getString(_cacheKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => WeightUnitDto.fromMap(
              e as Map<String, dynamic>,
              e['id'] as String,
            ))
        .toList();
  }

  @override
  Future<void> cacheAll(List<WeightUnitDto> units) async {
    final json = jsonEncode(units.map((u) => u.toMap()).toList());
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
