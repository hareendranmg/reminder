import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/features/alert/alert_window.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AlertWindowScreen renders normal reminder correctly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final reminder = ReminderModel(
      id: 1,
      name: 'Test Reminder',
      description: 'Test Description',
      dateTime: DateTime.now(),
      isSensitive: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: AlertWindowScreen(reminder: reminder, windowId: 0),
        ),
      ),
    );

    // Fast forward to clear the 2-seconds Future.delayed timer for '_canDismiss'
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Test Reminder'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
  });

  testWidgets('AlertWindowScreen obscures sensitive reminder', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final reminder = ReminderModel(
      id: 2,
      name: 'Secret Reminder',
      description: 'Secret Description',
      dateTime: DateTime.now(),
      isSensitive: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: AlertWindowScreen(reminder: reminder, windowId: 0),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Sensitive Reminder'), findsOneWidget);
    expect(find.text('Secret Reminder'), findsNothing);
    expect(find.text('Secret Description'), findsNothing);
    expect(find.text('Unlock to View'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });
}
