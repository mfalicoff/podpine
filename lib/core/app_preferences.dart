import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance() {
    unawaited(_load());
  }

  static const _themeModeKey = 'appearance.theme_mode';

  final Future<SharedPreferences> _preferences;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> _load() async {
    try {
      final preferences = await _preferences;
      final stored = preferences.getString(_themeModeKey);
      final mode = ThemeMode.values.where((value) => value.name == stored);
      if (mode.isNotEmpty && mode.first != _themeMode) {
        _themeMode = mode.first;
        notifyListeners();
      }
    } catch (_) {
      // System theme remains a safe default when preferences are unavailable.
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    try {
      await (await _preferences).setString(_themeModeKey, value.name);
    } catch (_) {
      // The in-memory choice still applies for this session.
    }
  }
}
