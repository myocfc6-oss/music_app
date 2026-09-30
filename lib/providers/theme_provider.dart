import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, dark, light }

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'app_theme_mode';
  static const String _legacyKey = 'dark_mode';

  AppThemeMode _currentMode = AppThemeMode.dark;

  AppThemeMode get currentMode => _currentMode;

  ThemeMode get themeMode {
    switch (_currentMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
    }
  }

  bool get isDarkMode => _currentMode == AppThemeMode.dark;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);
    if (savedMode != null) {
      switch (savedMode) {
        case 'system':
          _currentMode = AppThemeMode.system;
          break;
        case 'light':
          _currentMode = AppThemeMode.light;
          break;
        case 'dark':
        default:
          _currentMode = AppThemeMode.dark;
          break;
      }
    } else {
      final legacyDark = prefs.getBool(_legacyKey);
      if (legacyDark != null) {
        _currentMode = legacyDark ? AppThemeMode.dark : AppThemeMode.light;
      } else {
        _currentMode = AppThemeMode.dark;
      }
    }
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _currentMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_currentMode == AppThemeMode.dark) {
      await setThemeMode(AppThemeMode.light);
    } else {
      await setThemeMode(AppThemeMode.dark);
    }
  }
}
