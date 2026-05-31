import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dto/offer.dto.dart';

abstract interface class OfferLocalDataSource {
  Future<List<OfferDto>> getAll();
  Future<void> cacheAll(List<OfferDto> offers);
  Future<void> clear();
  Future<DateTime?> getLastSyncTimestamp();
  Future<void> setLastSyncTimestamp(DateTime timestamp);
}

class OfferLocalDataSourceImpl implements OfferLocalDataSource {
  static const String _cacheKey = 'cached_offers';
  static const String _syncTimestampKey = 'offers_last_sync';

  final SharedPreferences _prefs;

  OfferLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<OfferDto>> getAll() async {
    final json = _prefs.getString(_cacheKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => OfferDto.fromMap(
              e as Map<String, dynamic>,
              e['id'] as String,
            ))
        .toList();
  }

  @override
  Future<void> cacheAll(List<OfferDto> offers) async {
    final json = jsonEncode(offers.map((o) => o.toMap()).toList());
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
