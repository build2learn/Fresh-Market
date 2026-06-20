import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/setting_type.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/settings_repository_provider.dart';
import 'package:fresh_market/domain/entities/setting.entity.dart';
import 'package:fresh_market/domain/repositories/settings_repository.dart';

class SettingsState {
  final String storeName;
  final String currencyCode;
  final String currencySymbol;
  final String phone;
  final String whatsapp;
  final String facebook;
  final String instagram;
  final bool maintenanceMode;
  final bool isLoading;

  const SettingsState({
    this.storeName = 'Fresh Market',
    this.currencyCode = 'EGP',
    this.currencySymbol = 'E£',
    this.phone = '',
    this.whatsapp = '',
    this.facebook = '',
    this.instagram = '',
    this.maintenanceMode = false,
    this.isLoading = false,
  });

  SettingsState copyWith({
    String? storeName,
    String? currencyCode,
    String? currencySymbol,
    String? phone,
    String? whatsapp,
    String? facebook,
    String? instagram,
    bool? maintenanceMode,
    bool? isLoading,
  }) {
    return SettingsState(
      storeName: storeName ?? this.storeName,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsNotifier({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository,
        super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final result = await _settingsRepository.getSettings();
    if (result is Success<List<SettingEntity>>) {
      String storeName = 'Fresh Market';
      String currencyCode = 'EGP';
      String currencySymbol = 'E£';
      String phone = '';
      String whatsapp = '';
      String facebook = '';
      String instagram = '';
      bool maintenanceMode = false;

      for (final s in result.data) {
        switch (s.id) {
          case 'storeName':
            storeName = s.value as String? ?? 'Fresh Market';
            break;
          case 'currencyCode':
            currencyCode = s.value as String? ?? 'EGP';
            break;
          case 'currencySymbol':
            currencySymbol = s.value as String? ?? 'E£';
            break;
          case 'phone':
            phone = s.value as String? ?? '';
            break;
          case 'whatsapp':
            whatsapp = s.value as String? ?? '';
            break;
          case 'facebook':
            facebook = s.value as String? ?? '';
            break;
          case 'instagram':
            instagram = s.value as String? ?? '';
            break;
          case 'maintenanceMode':
            maintenanceMode = s.value as bool? ?? false;
            break;
        }
      }

      state = SettingsState(
        storeName: storeName,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        phone: phone,
        whatsapp: whatsapp,
        facebook: facebook,
        instagram: instagram,
        maintenanceMode: maintenanceMode,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(settingsRepository: ref.watch(settingsRepositoryProvider));
});
