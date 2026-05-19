import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted locale preference: 'en' or 'fr'.
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  static const _key = 'app_locale';

  LocaleNotifier() : super('en') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) ?? 'en';
  }

  Future<void> toggle() async {
    final next = state == 'en' ? 'fr' : 'en';
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next);
  }
}
