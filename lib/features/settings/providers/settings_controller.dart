import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _languageKey = 'languageCode';

  bool _isDarkMode = false;
  String _languageCode = 'en';

  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _languageCode = prefs.getString(_languageKey) ?? 'en';
    notifyListeners();
  }

  Future<void> updateThemeMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);

    notifyListeners();
  }

  Future<void> updateLanguage(String newLanguageCode) async {
    if (_languageCode == newLanguageCode) return;
    _languageCode = newLanguageCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, newLanguageCode);

    notifyListeners();
  }
}
