import 'package:flutter/material.dart';
import 'package:kynos/domain/catalog/on_device_model_catalog.dart';
import 'package:kynos/domain/entities/cloud_data_level.dart';
import 'package:kynos/domain/entities/cloud_llm_endpoint.dart';
import 'package:kynos/shared/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

class SettingsState {
  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
    required this.cloudTasksEnabled,
    required this.cloudDataLevel,
    required this.cloudBaseUrl,
    required this.selectedCloudModelId,
    required this.selectedCloudModelName,
    required this.selectedLocalModelId,
    required this.selectedLocalModelName,
    required this.installedLocalModelId,
  });

  final bool isDarkMode;
  final String languageCode;
  final bool cloudTasksEnabled;
  final CloudDataLevel cloudDataLevel;
  final String cloudBaseUrl;
  final String? selectedCloudModelId;
  final String? selectedCloudModelName;
  final String selectedLocalModelId;
  final String selectedLocalModelName;
  final String? installedLocalModelId;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  bool get hasSelectedCloudModel =>
      selectedCloudModelId != null && selectedCloudModelId!.isNotEmpty;

  bool get isSelectedLocalModelInstalled =>
      installedLocalModelId != null &&
      installedLocalModelId == selectedLocalModelId;

  bool get isOpenRouterEndpoint => CloudLlmEndpoint.isOpenRouter(cloudBaseUrl);
}

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  static const _themeKey = 'isDarkMode';
  static const _languageKey = 'languageCode';
  static const _cloudTasksKey = 'cloudTasksEnabled';
  static const _cloudDataLevelKey = 'cloudDataLevel';
  static const _cloudBaseUrlKey = 'cloudBaseUrl';
  static const _cloudModelIdKey = 'selectedCloudModelId';
  static const _cloudModelNameKey = 'selectedCloudModelName';
  static const _localModelIdKey = 'selectedLocalModelId';
  static const _localModelNameKey = 'selectedLocalModelName';
  static const _installedLocalModelIdKey = 'installedLocalModelId';

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final levelName = prefs.getString(_cloudDataLevelKey);
    final defaultModel =
        OnDeviceModelCatalog.byId(OnDeviceModelCatalog.defaultModelId);
    final storedBaseUrl = prefs.getString(_cloudBaseUrlKey);
    return SettingsState(
      isDarkMode: prefs.getBool(_themeKey) ?? false,
      languageCode: prefs.getString(_languageKey) ?? 'en',
      cloudTasksEnabled: prefs.getBool(_cloudTasksKey) ?? false,
      cloudDataLevel: CloudDataLevel.values.firstWhere(
        (l) => l.name == levelName,
        orElse: () => CloudDataLevel.minimal,
      ),
      cloudBaseUrl: (storedBaseUrl == null || storedBaseUrl.isEmpty)
          ? CloudLlmEndpoint.openRouterBaseUrl
          : CloudLlmEndpoint.normalizeBaseUrl(storedBaseUrl),
      selectedCloudModelId: prefs.getString(_cloudModelIdKey),
      selectedCloudModelName: prefs.getString(_cloudModelNameKey),
      selectedLocalModelId:
          prefs.getString(_localModelIdKey) ?? defaultModel.id,
      selectedLocalModelName:
          prefs.getString(_localModelNameKey) ?? defaultModel.name,
      installedLocalModelId: prefs.getString(_installedLocalModelIdKey),
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

  Future<void> updateCloudBaseUrl(String baseUrl) async {
    final normalized = CloudLlmEndpoint.normalizeBaseUrl(baseUrl);
    if (normalized.isEmpty) return;
    if (state.cloudBaseUrl == normalized) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_cloudBaseUrlKey, normalized);
    state = _copy(state, cloudBaseUrl: normalized);
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

  Future<void> updateSelectedLocalModel({
    required String id,
    required String name,
  }) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localModelIdKey, id);
    await prefs.setString(_localModelNameKey, name);
    state = _copy(
      state,
      selectedLocalModelId: id,
      selectedLocalModelName: name,
    );
  }

  Future<void> markLocalModelInstalled(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_installedLocalModelIdKey, id);
    state = _copy(state, installedLocalModelId: id);
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
      cloudBaseUrl: state.cloudBaseUrl,
      selectedCloudModelId: null,
      selectedCloudModelName: null,
      selectedLocalModelId: state.selectedLocalModelId,
      selectedLocalModelName: state.selectedLocalModelName,
      installedLocalModelId: state.installedLocalModelId,
    );
  }

  SettingsState _copy(
    SettingsState current, {
    bool? isDarkMode,
    String? languageCode,
    bool? cloudTasksEnabled,
    CloudDataLevel? cloudDataLevel,
    String? cloudBaseUrl,
    String? selectedCloudModelId,
    String? selectedCloudModelName,
    String? selectedLocalModelId,
    String? selectedLocalModelName,
    String? installedLocalModelId,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? current.isDarkMode,
      languageCode: languageCode ?? current.languageCode,
      cloudTasksEnabled: cloudTasksEnabled ?? current.cloudTasksEnabled,
      cloudDataLevel: cloudDataLevel ?? current.cloudDataLevel,
      cloudBaseUrl: cloudBaseUrl ?? current.cloudBaseUrl,
      selectedCloudModelId:
          selectedCloudModelId ?? current.selectedCloudModelId,
      selectedCloudModelName:
          selectedCloudModelName ?? current.selectedCloudModelName,
      selectedLocalModelId:
          selectedLocalModelId ?? current.selectedLocalModelId,
      selectedLocalModelName:
          selectedLocalModelName ?? current.selectedLocalModelName,
      installedLocalModelId:
          installedLocalModelId ?? current.installedLocalModelId,
    );
  }
}
