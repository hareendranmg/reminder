import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:reminder/features/settings/providers/sound_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Settings Providers Unit Tests', () {
    test('ThemeMode loaded correctly from defaults', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('Providers update state and shared preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // ThemeMode
      final themeNotifier = container.read(themeModeProvider.notifier);
      await themeNotifier.setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(prefs.getString(PreferenceKeys.themeMode), 'dark');

      // Snooze Duration
      final snoozeNotifier = container.read(snoozeDurationProvider.notifier);
      await snoozeNotifier.setDuration(30);
      expect(container.read(snoozeDurationProvider), 30);
      expect(prefs.getInt(PreferenceKeys.snoozeDuration), 30);

      // Sound provider
      final soundNotifier = container.read(soundEnabledProvider.notifier);
      await soundNotifier.setSoundEnabled(enabled: true);
      expect(container.read(soundEnabledProvider), true);
      expect(prefs.getBool('sound_enabled'), true);

      await soundNotifier.toggle();
      expect(container.read(soundEnabledProvider), false);
      expect(prefs.getBool('sound_enabled'), false);
    });
  });
}
