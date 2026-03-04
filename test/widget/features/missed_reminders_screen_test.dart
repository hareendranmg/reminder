import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/features/alert/missed_reminders_screen.dart';
import 'package:reminder/features/settings/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MissedRemindersScreen renders and handles dismiss all', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final reminders = [
      ReminderModel(
        id: 1,
        name: 'First Missed',
        dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ReminderModel(
        id: 2,
        name: 'Second Missed',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: MissedRemindersScreen(windowId: 0, missedReminders: reminders),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Missed Reminders'), findsOneWidget);
    expect(find.text('You missed 2 reminders while away'), findsOneWidget);
    expect(find.text('First Missed'), findsOneWidget);
    expect(find.text('Second Missed'), findsOneWidget);

    // Actions are available
    expect(find.text('Snooze All 10m'), findsOneWidget);
    expect(find.text('Dismiss All'), findsOneWidget);
  });
}
