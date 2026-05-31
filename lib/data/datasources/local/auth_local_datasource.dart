import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AuthLocalDataSource {
  Future<String?> getCachedUserId();
  Future<void> cacheUserId(String uid);
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userIdKey = 'cached_user_id';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getCachedUserId() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  @override
  Future<void> cacheUserId(String uid) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, uid);
  }

  @override
  Future<void> clearCache() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }
}
