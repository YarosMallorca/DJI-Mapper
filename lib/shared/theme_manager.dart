import 'package:dji_mapper/main.dart';
import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeManager() {
    _isDark = prefs.getBool('isDark') ?? false;
  }

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
    prefs.setBool('isDark', _isDark);
  }

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
}
