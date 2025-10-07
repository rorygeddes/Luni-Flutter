import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  // App state management
  bool _isLoading = false;
  String _currentScreen = 'home';
  ThemeMode _themeMode = ThemeMode.system;

  // Getters
  bool get isLoading => _isLoading;
  String get currentScreen => _currentScreen;
  ThemeMode get themeMode => _themeMode;

  // Methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
  }
}

