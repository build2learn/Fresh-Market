import '../../core/enums/setting_type.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/setting.entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/firebase/settings_firebase_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsFirebaseDataSource _firebaseDataSource;

  SettingsRepositoryImpl({required SettingsFirebaseDataSource firebaseDataSource})
      : _firebaseDataSource = firebaseDataSource;

  @override
  Future<Result<List<SettingEntity>>> getSettings() async {
    try {
      final data = await _firebaseDataSource.getSettings();
      if (data == null) return const Success([]);
      final list = <SettingEntity>[];
      data.forEach((key, val) {
        SettingType type = SettingType.string;
        if (val is bool) {
          type = SettingType.bool;
        } else if (val is num) {
          type = SettingType.number;
        } else if (val is Map) {
          type = SettingType.json;
        }
        list.add(SettingEntity(
          id: key,
          value: val,
          type: type,
          updatedAt: DateTime.now(),
        ));
      });
      return Success(list);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<SettingEntity?>> getSetting(String key) async {
    try {
      final data = await _firebaseDataSource.getSettings();
      if (data == null || !data.containsKey(key)) return const Success(null);
      final val = data[key];
      SettingType type = SettingType.string;
      if (val is bool) {
        type = SettingType.bool;
      } else if (val is num) {
        type = SettingType.number;
      } else if (val is Map) {
        type = SettingType.json;
      }
      return Success(SettingEntity(
        id: key,
        value: val,
        type: type,
        updatedAt: DateTime.now(),
      ));
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<SettingEntity>> updateSetting(SettingEntity setting) async {
    try {
      await _firebaseDataSource.saveSettings({
        setting.id: setting.value,
      });
      return Success(setting);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
