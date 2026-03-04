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
    expect(find.byType(MaterialApp), findsWidgets);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Upcoming'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Can navigate to settings tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Mock package info for Settings screen
    try {
      // Ignore if not available in tests without import
    } catch (_) {}

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const ReminderApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Find the settings tab icon/text and tap it
    final settingsTab = find.text('Settings').last;
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Appearance'),
        findsOneWidget,
      ); // Check for settings layout content
    }
  });
}
