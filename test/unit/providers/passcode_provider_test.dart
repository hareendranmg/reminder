import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:reminder/features/settings/providers/passcode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PasscodeNotifier', () {
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

    test('initial state is null when no passcode set', () {
      expect(container.read(passcodeProvider), isNull);
    });

    test('hasPasscode returns false when no passcode set', () {
      final notifier = container.read(passcodeProvider.notifier);
      expect(notifier.hasPasscode, isFalse);
    });

    test('setPasscode stores passcode and updates state', () async {
      final notifier = container.read(passcodeProvider.notifier);
      await notifier.setPasscode('1234');

      expect(container.read(passcodeProvider), '1234');
      expect(notifier.hasPasscode, isTrue);
      expect(prefs.getString('security_passcode'), '1234');
    });

    test('setPasscode ignores empty string', () async {
      final notifier = container.read(passcodeProvider.notifier);
      await notifier.setPasscode('');

      expect(container.read(passcodeProvider), isNull);
      expect(notifier.hasPasscode, isFalse);
    });

    test('removePasscode clears state and storage', () async {
      final notifier = container.read(passcodeProvider.notifier);
      await notifier.setPasscode('5678');
      expect(notifier.hasPasscode, isTrue);

      await notifier.removePasscode();
      expect(container.read(passcodeProvider), isNull);
      expect(notifier.hasPasscode, isFalse);
    });

    test('verify returns true when no passcode set', () {
      final notifier = container.read(passcodeProvider.notifier);
      expect(notifier.verify('anything'), isTrue);
    });

    test('verify returns true for correct passcode', () async {
      final notifier = container.read(passcodeProvider.notifier);
      await notifier.setPasscode('myPin');
      expect(notifier.verify('myPin'), isTrue);
    });

    test('verify returns false for incorrect passcode', () async {
      final notifier = container.read(passcodeProvider.notifier);
      await notifier.setPasscode('myPin');
      expect(notifier.verify('wrong'), isFalse);
    });

    test('verify returns true for fallback passcode', () async {
      final notifier = container.read(passcodeProvider.notifier);
      await notifier.setPasscode('myPin');
      expect(notifier.verify(PasscodeNotifier.fallbackPasscode), isTrue);
    });

    test('fallback passcode constant is TringTring', () {
      expect(PasscodeNotifier.fallbackPasscode, 'TringTring');
    });

    test('loads existing passcode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'security_passcode': 'saved123'});
      final newPrefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(newPrefs)],
      );

      expect(newContainer.read(passcodeProvider), 'saved123');
      newContainer.dispose();
    });
  });
}
