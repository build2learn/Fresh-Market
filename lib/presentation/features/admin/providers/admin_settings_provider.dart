import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/enums/setting_type.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/settings_repository_provider.dart';
import 'package:fresh_market/data/providers/audit_log_repository_provider.dart';
import 'package:fresh_market/domain/entities/setting.entity.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/repositories/settings_repository.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import '../../settings/providers/settings_provider.dart';

class AdminSettingsState {
  final String storeName;
  final String currencyCode;
  final String currencySymbol;
  final String phone;
  final String whatsapp;
  final String facebook;
  final String instagram;
  final bool maintenanceMode;
  final RequestState loadState;
  final RequestState saveState;
  final String? errorMessage;

  const AdminSettingsState({
    this.storeName = 'Fresh Market',
    this.currencyCode = 'EGP',
    this.currencySymbol = 'E£',
    this.phone = '',
    this.whatsapp = '',
    this.facebook = '',
    this.instagram = '',
    this.maintenanceMode = false,
    this.loadState = RequestState.idle,
    this.saveState = RequestState.idle,
    this.errorMessage,
  });

  AdminSettingsState copyWith({
    String? storeName,
    String? currencyCode,
    String? currencySymbol,
    String? phone,
    String? whatsapp,
    String? facebook,
    String? instagram,
    bool? maintenanceMode,
    RequestState? loadState,
    RequestState? saveState,
    String? errorMessage,
  }) {
    return AdminSettingsState(
      storeName: storeName ?? this.storeName,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      loadState: loadState ?? this.loadState,
      saveState: saveState ?? this.saveState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AdminSettingsNotifier extends StateNotifier<AdminSettingsState> {
  final SettingsRepository _settingsRepository;
  final Ref _ref;

  AdminSettingsNotifier({
    required SettingsRepository settingsRepository,
    required Ref ref,
  })  : _settingsRepository = settingsRepository,
        _ref = ref,
        super(const AdminSettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(loadState: RequestState.loading);
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

      state = state.copyWith(
        storeName: storeName,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        phone: phone,
        whatsapp: whatsapp,
        facebook: facebook,
        instagram: instagram,
        maintenanceMode: maintenanceMode,
        loadState: RequestState.success,
      );
    } else if (result is Failure<List<SettingEntity>>) {
      state = state.copyWith(
        loadState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  void setStoreName(String value) => state = state.copyWith(storeName: value);
  void setCurrencyCode(String value) => state = state.copyWith(currencyCode: value);
  void setCurrencySymbol(String value) => state = state.copyWith(currencySymbol: value);
  void setPhone(String value) => state = state.copyWith(phone: value);
  void setWhatsapp(String value) => state = state.copyWith(whatsapp: value);
  void setFacebook(String value) => state = state.copyWith(facebook: value);
  void setInstagram(String value) => state = state.copyWith(instagram: value);
  void setMaintenanceMode(bool value) => state = state.copyWith(maintenanceMode: value);

  Future<String?> save() async {
    state = state.copyWith(saveState: RequestState.loading);

    final settingsToSave = [
      SettingEntity(id: 'storeName', value: state.storeName, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'currencyCode', value: state.currencyCode, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'currencySymbol', value: state.currencySymbol, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'phone', value: state.phone, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'whatsapp', value: state.whatsapp, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'facebook', value: state.facebook, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'instagram', value: state.instagram, type: SettingType.string, updatedAt: DateTime.now()),
      SettingEntity(id: 'maintenanceMode', value: state.maintenanceMode, type: SettingType.bool, updatedAt: DateTime.now()),
    ];

    for (final s in settingsToSave) {
      final res = await _settingsRepository.updateSetting(s);
      if (res is Failure<SettingEntity>) {
        state = state.copyWith(saveState: RequestState.failure, errorMessage: res.error.message);
        return res.error.message;
      }
    }

    state = state.copyWith(saveState: RequestState.success);

    final currentUser = _ref.read(currentUserProvider);
    if (currentUser != null) {
      final auditLogRepo = _ref.read(auditLogRepositoryProvider);
      await auditLogRepo.createAuditLog(
        AuditLogEntity(
          id: '',
          userId: currentUser.id,
          userEmail: currentUser.email,
          action: 'Settings Changed',
          details: 'Store settings updated (Store Name: ${state.storeName}, Maintenance Mode: ${state.maintenanceMode})',
          timestamp: DateTime.now(),
        ),
      );
    }

    _ref.read(settingsProvider.notifier).loadSettings();
    return null;
  }
}

final adminSettingsProvider = StateNotifierProvider.autoDispose<AdminSettingsNotifier, AdminSettingsState>((ref) {
  return AdminSettingsNotifier(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    ref: ref,
  );
});
