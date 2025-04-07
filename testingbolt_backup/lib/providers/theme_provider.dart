import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeBoxName = 'themeBox';
  static const String _themeKey = 'isDark';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Toggle between light and dark theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  // Load theme from Hive
  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_themeBoxName);
    final isDark = box.get(_themeKey, defaultValue: false);  // Default to light theme
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Save theme to Hive
  Future<void> _saveTheme() async {
    final box = await Hive.openBox(_themeBoxName);
    await box.put(_themeKey, _themeMode == ThemeMode.dark);
  }
}
