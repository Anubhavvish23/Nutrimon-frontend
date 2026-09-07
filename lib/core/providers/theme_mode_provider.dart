import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _storage_key = 'theme_mode';
  bool _loaded = false;

  @override
  ThemeMode build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return ThemeMode.dark;
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storage_key);
    if (stored == 'light') {
      state = ThemeMode.light;
      return;
    }
    state = ThemeMode.dark;
    if (stored != 'dark') {
      await prefs.setString(_storage_key, 'dark');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storage_key,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
