import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'app_theme';

  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    state = switch (saved) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };
  }

  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
      _                => ThemeMode.light,
    };
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, switch (next) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      _                => 'system',
    });
  }

  /// Icon representing the current mode.
  static IconData iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.light  => Icons.light_mode,
    ThemeMode.dark   => Icons.dark_mode,
    _                => Icons.brightness_auto,
  };
}
