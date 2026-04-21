import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kynos/features/onboarding/providers/onboarding_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({this.isDarkMode = false, this.languageCode = 'en'});

  final bool isDarkMode;
  final String languageCode;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsState copyWith({bool? isDarkMode, String? languageCode}) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _themeKey = 'isDarkMode';
  static const _languageKey = 'languageCode';

  @override
  SettingsState build() {
    final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
    return SettingsState(
      isDarkMode: prefs.getBool(_themeKey) ?? false,
      languageCode: prefs.getString(_languageKey) ?? 'en',
    );
  }

  Future<void> updateThemeMode(bool isDark) async {
    if (state.isDarkMode == isDark) return;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_themeKey, isDark);
    state = state.copyWith(isDarkMode: isDark);
  }

  Future<void> updateLanguage(String languageCode) async {
    if (state.languageCode == languageCode) return;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_languageKey, languageCode);
    state = state.copyWith(languageCode: languageCode);
  }
}

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
