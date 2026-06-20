import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/domain/entities/setting.entity.dart';
import 'package:fresh_market/core/enums/setting_type.dart';
import 'package:fresh_market/domain/repositories/settings_repository.dart';
import 'package:fresh_market/presentation/features/admin/providers/admin_settings_provider.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/settings_repository_provider.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {
  @override
  Future<Result<List<SettingEntity>>> getSettings() =>
      super.noSuchMethod(
        Invocation.method(#getSettings, []),
        returnValue: Future.value(const Success<List<SettingEntity>>([])),
        returnValueForMissingStub: Future.value(const Success<List<SettingEntity>>([])),
      ) as Future<Result<List<SettingEntity>>>;

  @override
  Future<Result<SettingEntity>> updateSetting(SettingEntity? setting) =>
      super.noSuchMethod(
        Invocation.method(#updateSetting, [setting]),
        returnValue: Future.value(Success(SettingEntity(id: 'test', value: '', type: SettingType.string, updatedAt: DateTime.now()))),
        returnValueForMissingStub: Future.value(Success(SettingEntity(id: 'test', value: '', type: SettingType.string, updatedAt: DateTime.now()))),
      ) as Future<Result<SettingEntity>>;
}

void main() {
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  test('loads settings successfully and parses values', () async {
    final settings = [
      SettingEntity(id: 'storeName', value: 'Fresh Store', type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'currencyCode', value: 'USD', type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'currencySymbol', value: '\$', type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'maintenanceMode', value: true, type: SettingType.bool, updatedAt: DateTime.now()),
      SettingEntity(id: 'phone', value: '123', type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'whatsapp', value: '456', type: SettingType.string, updatedAt: DateTime.now()),
    ];

    when(mockRepository.getSettings()).thenAnswer((_) async => Success(settings));

    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    container.listen(adminSettingsProvider, (_, __) {});
    final notifier = container.read(adminSettingsProvider.notifier);
    
    // Wait for async load in constructor
    await Future.delayed(Duration.zero);

    expect(notifier.state.storeName, 'Fresh Store');
    expect(notifier.state.currencyCode, 'USD');
    expect(notifier.state.currencySymbol, '\$');
    expect(notifier.state.maintenanceMode, true);
    expect(notifier.state.phone, '123');
    expect(notifier.state.whatsapp, '456');
    expect(notifier.state.loadState, RequestState.success);
  });
}
