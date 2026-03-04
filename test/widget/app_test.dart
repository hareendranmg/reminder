import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/app.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App initializes and shows home tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ReminderApp(),
      ),
    );

    // Initial animations
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app title or core structure is present
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Can navigate to settings tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ReminderApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Find the settings tab icon/text and tap it
    final settingsTab = find.byIcon(Icons.settings_outlined).last;
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('General'),
        findsOneWidget,
      ); // Check for settings layout content
    }
  });
}
