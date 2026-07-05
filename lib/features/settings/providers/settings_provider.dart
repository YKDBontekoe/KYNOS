import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

class SettingsState {
  const SettingsState({
    required this.isDarkMode,
    required this.languageCode,
  });

  final bool isDarkMode;
  final String languageCode;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;
}

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  static const _themeKey = 'isDarkMode';
  static const _languageKey = 'languageCode';

  @override
  SettingsState build() {
    _load();
    return const SettingsState(isDarkMode: false, languageCode: 'en');
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      isDarkMode: prefs.getBool(_themeKey) ?? false,
      languageCode: prefs.getString(_languageKey) ?? 'en',
    );
  }

  Future<void> updateThemeMode(bool isDark) async {
    if (state.isDarkMode == isDark) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    state = SettingsState(
      isDarkMode: isDark,
      languageCode: state.languageCode,
    );
  }

  Future<void> updateLanguage(String newLanguageCode) async {
    if (state.languageCode == newLanguageCode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLanguageCode);
    state = SettingsState(
      isDarkMode: state.isDarkMode,
      languageCode: newLanguageCode,
    );
  }
}
