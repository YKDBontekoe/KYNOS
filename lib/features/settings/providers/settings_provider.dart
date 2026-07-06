import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

class SettingsState {
  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
    required this.cloudTasksEnabled,
    required this.cloudDataLevel,
    required this.selectedCloudModelId,
    required this.selectedCloudModelName,
  });

  final bool isDarkMode;
  final String languageCode;
  final bool cloudTasksEnabled;
  final CloudDataLevel cloudDataLevel;
  final String? selectedCloudModelId;
  final String? selectedCloudModelName;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  bool get hasSelectedCloudModel =>
      selectedCloudModelId != null && selectedCloudModelId!.isNotEmpty;
}

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  static const _themeKey = 'isDarkMode';
  static const _languageKey = 'languageCode';
  static const _cloudTasksKey = 'cloudTasksEnabled';
  static const _cloudDataLevelKey = 'cloudDataLevel';
  static const _cloudModelIdKey = 'selectedCloudModelId';
  static const _cloudModelNameKey = 'selectedCloudModelName';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final levelName = prefs.getString(_cloudDataLevelKey);
    return SettingsState(
      isDarkMode: prefs.getBool(_themeKey) ?? false,
      languageCode: prefs.getString(_languageKey) ?? 'en',
      cloudTasksEnabled: prefs.getBool(_cloudTasksKey) ?? false,
      cloudDataLevel: CloudDataLevel.values.firstWhere(
        (l) => l.name == levelName,
        orElse: () => CloudDataLevel.minimal,
      ),
      selectedCloudModelId: prefs.getString(_cloudModelIdKey),
      selectedCloudModelName: prefs.getString(_cloudModelNameKey),
    );
  }

  Future<void> updateThemeMode(bool isDark) async {
    if (state.isDarkMode == isDark) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_themeKey, isDark);
    state = _copy(state, isDarkMode: isDark);
  }

  Future<void> updateLanguage(String newLanguageCode) async {
    if (state.languageCode == newLanguageCode) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_languageKey, newLanguageCode);
    state = _copy(state, languageCode: newLanguageCode);
  }

  Future<void> updateCloudTasksEnabled(bool enabled) async {
    if (state.cloudTasksEnabled == enabled) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_cloudTasksKey, enabled);
    state = _copy(state, cloudTasksEnabled: enabled);
  }

  Future<void> updateCloudDataLevel(CloudDataLevel level) async {
    if (state.cloudDataLevel == level) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_cloudDataLevelKey, level.name);
    state = _copy(state, cloudDataLevel: level);
  }

  Future<void> updateSelectedCloudModel({
    required String id,
    required String name,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_cloudModelIdKey, id);
    await prefs.setString(_cloudModelNameKey, name);
    state = _copy(
      state,
      selectedCloudModelId: id,
      selectedCloudModelName: name,
    );
  }

  Future<void> clearSelectedCloudModel() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_cloudModelIdKey);
    await prefs.remove(_cloudModelNameKey);
    state = SettingsState(
      isDarkMode: state.isDarkMode,
      languageCode: state.languageCode,
      cloudTasksEnabled: state.cloudTasksEnabled,
      cloudDataLevel: state.cloudDataLevel,
      selectedCloudModelId: null,
      selectedCloudModelName: null,
    );
  }

  SettingsState _copy(
    SettingsState current, {
    bool? isDarkMode,
    String? languageCode,
    bool? cloudTasksEnabled,
    CloudDataLevel? cloudDataLevel,
    String? selectedCloudModelId,
    String? selectedCloudModelName,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? current.isDarkMode,
      languageCode: languageCode ?? current.languageCode,
      cloudTasksEnabled: cloudTasksEnabled ?? current.cloudTasksEnabled,
      cloudDataLevel: cloudDataLevel ?? current.cloudDataLevel,
      selectedCloudModelId:
          selectedCloudModelId ?? current.selectedCloudModelId,
      selectedCloudModelName:
          selectedCloudModelName ?? current.selectedCloudModelName,
    );
  }
}
