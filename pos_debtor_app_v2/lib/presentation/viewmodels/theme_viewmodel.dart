import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyDarkMode = 'isDarkMode';
  
  late Box _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeViewModel() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _isDarkMode = _box.get(_keyDarkMode, defaultValue: false);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _box.put(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }
}
