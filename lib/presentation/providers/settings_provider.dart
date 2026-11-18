import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/aqi_standards.dart';
import '../../domain/models/app_settings.dart';
import 'app_providers.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(settingsRepositoryProvider);
    state = await repo.getSettings();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> updateAqiStandard(AqiStandard standard) async {
    state = state.copyWith(aqiStandard: standard);
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> toggleReducedMotion(bool value) async {
    state = state.copyWith(reducedMotion: value);
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> toggleDemoMode(bool value) async {
    state = state.copyWith(isDemoMode: value);
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> updateGenAiConfig({
    required bool useRealGenAi,
    required String apiKey,
    required String endpoint,
  }) async {
    state = state.copyWith(
      useRealGenAi: useRealGenAi,
      genAiApiKey: apiKey,
      genAiEndpoint: endpoint,
    );
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> toggleGeolocation(bool allow) async {
    state = state.copyWith(allowGeolocation: allow);
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> resetAllData() async {
    await _ref.read(settingsRepositoryProvider).clearAllUserData();
    state = const AppSettings();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});
