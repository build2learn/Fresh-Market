import 'dart:async';
import '../entities/setting.entity.dart';
import '../../core/utils/result.dart';

abstract interface class SettingsRepository {
  Future<Result<List<SettingEntity>>> getSettings();
  Future<Result<SettingEntity?>> getSetting(String key);
  Future<Result<SettingEntity>> updateSetting(SettingEntity setting);
}
