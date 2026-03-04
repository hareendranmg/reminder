import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:reminder/features/settings/providers/sound_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SoundEnabledNotifier', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('default state is false', () {
      expect(container.read(soundEnabledProvider), false);
    });

    test('setSoundEnabled updates state and persists', () async {
      final notifier = container.read(soundEnabledProvider.notifier);
      await notifier.setSoundEnabled(enabled: true);

      expect(container.read(soundEnabledProvider), true);
      expect(prefs.getBool('sound_enabled'), true);
    });

    test('setSoundEnabled to false', () async {
      final notifier = container.read(soundEnabledProvider.notifier);
      await notifier.setSoundEnabled(enabled: true);
      await notifier.setSoundEnabled(enabled: false);

      expect(container.read(soundEnabledProvider), false);
      expect(prefs.getBool('sound_enabled'), false);
    });

    test('toggle flips state', () async {
      final notifier = container.read(soundEnabledProvider.notifier);
      expect(container.read(soundEnabledProvider), false);

      await notifier.toggle();
      expect(container.read(soundEnabledProvider), true);

      await notifier.toggle();
      expect(container.read(soundEnabledProvider), false);
    });

    test('loads saved value from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': true});
      final newPrefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(newPrefs)],
      );

      expect(newContainer.read(soundEnabledProvider), true);
      newContainer.dispose();
    });
  });
}
