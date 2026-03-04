import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/core/constants/app_constants.dart';
import 'package:reminder/features/home/widgets/home_fab.dart';
import 'package:reminder/features/home/widgets/reminder_list_empty_state.dart';

void main() {
  group('HomeFAB', () {
    testWidgets('renders New Reminder text and add icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: HomeFAB(
              onPressed: () {},
              controller: AnimationController(
                vsync: const TestVSync(),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('New Reminder'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('fires onPressed callback', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: HomeFAB(
              onPressed: () => pressed = true,
              controller: AnimationController(
                vsync: const TestVSync(),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('New Reminder'));
      expect(pressed, isTrue);
    });
  });

  group('ReminderListEmptyState', () {
    testWidgets('shows correct content for today filter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReminderListEmptyState(filter: ReminderFilter.today),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No reminders for today'), findsOneWidget);
      expect(find.text('Enjoy your free time!'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    });

    testWidgets('shows correct content for upcoming filter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReminderListEmptyState(filter: ReminderFilter.upcoming),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No upcoming reminders'), findsOneWidget);
      expect(find.text('You are all caught up for now'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('shows correct content for past filter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReminderListEmptyState(filter: ReminderFilter.past),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No past reminders'), findsOneWidget);
      expect(find.text('History is clean'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('shows correct content for all filter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReminderListEmptyState(filter: ReminderFilter.all),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('No reminders yet'), findsOneWidget);
      expect(
        find.text('Tap the + button to create your first reminder'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });
  });
}
