import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/core/constants/app_constants.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/features/home/widgets/reminder_card.dart';

void main() {
  Widget buildTestWidget(
    ReminderModel reminder, {
    VoidCallback? onTap,
    ValueChanged<bool>? onToggle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ReminderCard(
          reminder: reminder,
          onTap: onTap ?? () {},
          onToggle: onToggle ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('ReminderCard renders name and description', (tester) async {
    final reminder = ReminderModel(
      id: 1,
      name: 'Meeting with Bob',
      description: 'Discuss project plan',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
    );

    await tester.pumpWidget(buildTestWidget(reminder));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Meeting with Bob'), findsOneWidget);
    expect(find.text('Discuss project plan'), findsOneWidget);
  });

  testWidgets('ReminderCard hides description for sensitive reminders', (
    tester,
  ) async {
    final reminder = ReminderModel(
      id: 2,
      name: 'Secret',
      description: 'Top secret info',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      isSensitive: true,
    );

    await tester.pumpWidget(buildTestWidget(reminder));
    await tester.pump(const Duration(milliseconds: 500));

    // Sensitive reminder should show lock icon and hide description
    expect(find.text('Top secret info'), findsNothing);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
  });

  testWidgets('ReminderCard shows recurring badge for recurring reminders', (
    tester,
  ) async {
    final reminder = ReminderModel(
      id: 3,
      name: 'Daily Standup',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      isRecurring: true,
      recurringType: RecurringType.days,
      recurringInterval: 1,
    );

    await tester.pumpWidget(buildTestWidget(reminder));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Daily Standup'), findsOneWidget);
    // Should show recurring indicator text
    expect(find.textContaining('Every'), findsOneWidget);
  });

  testWidgets('ReminderCard fires onTap callback', (tester) async {
    var tapped = false;
    final reminder = ReminderModel(
      id: 4,
      name: 'Tappable',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
    );

    await tester.pumpWidget(
      buildTestWidget(reminder, onTap: () => tapped = true),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Tappable'));
    expect(tapped, isTrue);
  });

  testWidgets('ReminderCard renders inactive state correctly', (tester) async {
    final reminder = ReminderModel(
      id: 5,
      name: 'Paused Reminder',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      isActive: false,
    );

    await tester.pumpWidget(buildTestWidget(reminder));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Paused Reminder'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });
}
