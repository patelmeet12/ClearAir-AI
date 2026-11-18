import '../../domain/models/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_storage_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalStorageService _storage;
  static const String _settingsKey = 'clearair_app_settings';

  SettingsRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<AppSettings> getSettings() async {
    final json = _storage.getJson(_settingsKey);
    if (json == null) {
      const defaultSettings = AppSettings();
      await _storage.setJson(_settingsKey, defaultSettings.toJson());
      return defaultSettings;
    }
    return AppSettings.fromJson(json);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _storage.setJson(_settingsKey, settings.toJson());
  }

  @override
  Future<void> clearAllUserData() async {
    await _storage.clearAll();
  }
}
