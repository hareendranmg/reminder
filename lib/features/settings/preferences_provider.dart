import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences keys
class PreferenceKeys {
  static const String themeMode = 'theme_mode';
  static const String snoozeDuration = 'snooze_duration_minutes';
  static const String soundEnabled = 'sound_enabled';
  static const String minimizeToTray = 'minimize_to_tray';
}

/// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Provider was not initialized');
});

/// Theme mode provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadThemeMode(_prefs);
  }

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final modeStr = prefs.getString(PreferenceKeys.themeMode);
    if (modeStr == 'light') return ThemeMode.light;
    if (modeStr == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _prefs.setString(PreferenceKeys.themeMode, modeStr);
  }
}

/// Snooze duration provider
final snoozeDurationProvider = NotifierProvider<SnoozeDurationNotifier, int>(
  SnoozeDurationNotifier.new,
);

class SnoozeDurationNotifier extends Notifier<int> {
  late SharedPreferences _prefs;

  @override
  int build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadDuration(_prefs);
  }

  static int _loadDuration(SharedPreferences prefs) {
    return prefs.getInt(PreferenceKeys.snoozeDuration) ?? 10;
  }

  Future<void> setDuration(int minutes) async {
    state = minutes;
    await _prefs.setInt(PreferenceKeys.snoozeDuration, minutes);
  }
}
