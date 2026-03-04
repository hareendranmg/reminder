import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/security/passcode_dialog.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildDialog({
    String title = 'Enter Passcode',
    String? overrideExpectedPasscode,
    bool isSettingNew = false,
  }) {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWithValue(prefs),
                  ],
                  child: PasscodeVerificationDialog(
                    title: title,
                    overrideExpectedPasscode: overrideExpectedPasscode,
                    isSettingNew: isSettingNew,
                  ),
                ),
              ),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('PasscodeDialog renders with title', (tester) async {
    await tester.pumpWidget(buildDialog(title: 'My Custom Title'));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('My Custom Title'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('PasscodeDialog shows Unlock button for verification mode', (
    tester,
  ) async {
    await tester.pumpWidget(buildDialog());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Unlock'), findsOneWidget);
    expect(find.text('Forgot? Try the fallback password.'), findsOneWidget);
  });

  testWidgets('PasscodeDialog shows Set button for new passcode mode', (
    tester,
  ) async {
    await tester.pumpWidget(buildDialog(isSettingNew: true));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Set'), findsOneWidget);
    // Should NOT show fallback hint when setting new
    expect(find.text('Forgot? Try the fallback password.'), findsNothing);
  });

  testWidgets('Setting new passcode enforces minimum 4 characters', (
    tester,
  ) async {
    await tester.pumpWidget(buildDialog(isSettingNew: true));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Enter short passcode
    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    expect(find.text('Passcode must be at least 4 characters'), findsOneWidget);
  });

  testWidgets('Verification shows error for incorrect passcode', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildDialog(overrideExpectedPasscode: 'correct123'),
    );
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect passcode'), findsOneWidget);
  });

  testWidgets('Cancel button dismisses dialog', (tester) async {
    await tester.pumpWidget(buildDialog());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Passcode'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Passcode'), findsNothing);
  });

  testWidgets('Fallback passcode accepted in override mode', (tester) async {
    await tester.pumpWidget(buildDialog(overrideExpectedPasscode: 'realPin'));
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'TringTring');
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    // Dialog should have popped (no error shown)
    expect(find.text('Incorrect passcode'), findsNothing);
  });
}
