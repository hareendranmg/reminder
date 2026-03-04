import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/features/alert/widgets/alert_animated_icon.dart';
import 'package:reminder/features/alert/widgets/alert_controls.dart';
import 'package:reminder/features/alert/widgets/alert_quote.dart';
import 'package:reminder/features/alert/widgets/alert_time_info.dart';
import 'package:reminder/features/home/widgets/reminder_status_indicator.dart';
import 'package:reminder/features/home/widgets/reminder_time_remaining.dart';

void main() {
  group('AlertAnimatedIcon', () {
    testWidgets('renders notification icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: AlertAnimatedIcon(
                animation: const AlwaysStoppedAnimation(0.5),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    });
  });

  group('AlertControls', () {
    testWidgets('renders Snooze and Acknowledge when canDismiss is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertControls(
              canDismiss: true,
              onSnooze: (_) {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Snooze'), findsOneWidget);
      expect(find.text('Acknowledge'), findsOneWidget);
    });

    testWidgets('renders Wait when canDismiss is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertControls(
              canDismiss: false,
              onSnooze: null,
              onDismiss: null,
            ),
          ),
        ),
      );

      expect(find.text('Wait...'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    });

    testWidgets('dismiss button fires callback', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertControls(
              canDismiss: true,
              onSnooze: (_) {},
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Acknowledge'));
      expect(dismissed, isTrue);
    });
  });

  group('AlertQuote', () {
    testWidgets('renders quote text and author', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertQuote(
              quote: const {
                'quote': 'Stay hungry, stay foolish.',
                'author': 'Steve Jobs',
              },
            ),
          ),
        ),
      );

      expect(find.text('"Stay hungry, stay foolish."'), findsOneWidget);
      expect(find.text('- Steve Jobs'), findsOneWidget);
    });
  });

  group('AlertTimeInfo', () {
    testWidgets('renders time and date', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AlertTimeInfo())),
      );

      // Should have a clock icon
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
    });
  });

  group('ReminderStatusIndicator', () {
    testWidgets('shows pause icon for inactive reminder', (tester) async {
      final reminder = ReminderModel(
        id: 1,
        name: 'Inactive',
        dateTime: DateTime.now(),
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderStatusIndicator(reminder: reminder, isPast: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('shows warning icon for past active reminder', (tester) async {
      final reminder = ReminderModel(
        id: 2,
        name: 'Past Active',
        dateTime: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderStatusIndicator(reminder: reminder, isPast: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('shows repeat icon for recurring reminder', (tester) async {
      final reminder = ReminderModel(
        id: 3,
        name: 'Recurring',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        isActive: true,
        isRecurring: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderStatusIndicator(reminder: reminder, isPast: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
    });

    testWidgets('shows notification icon for active one-time future reminder', (
      tester,
    ) async {
      final reminder = ReminderModel(
        id: 4,
        name: 'Active One-time',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderStatusIndicator(reminder: reminder, isPast: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    });
  });

  group('ReminderTimeRemaining', () {
    testWidgets('shows days remaining', (tester) async {
      final reminder = ReminderModel(
        id: 1,
        name: 'Days',
        dateTime: DateTime.now().add(const Duration(days: 5, hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReminderTimeRemaining(reminder: reminder)),
        ),
      );

      expect(find.text('5d left'), findsOneWidget);
    });

    testWidgets('shows hours remaining', (tester) async {
      final reminder = ReminderModel(
        id: 2,
        name: 'Hours',
        dateTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReminderTimeRemaining(reminder: reminder)),
        ),
      );

      expect(find.text('3h left'), findsOneWidget);
    });

    testWidgets('shows minutes remaining', (tester) async {
      final reminder = ReminderModel(
        id: 3,
        name: 'Minutes',
        dateTime: DateTime.now().add(const Duration(minutes: 42)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReminderTimeRemaining(reminder: reminder)),
        ),
      );

      expect(find.textContaining('m left'), findsOneWidget);
    });

    testWidgets('shows Soon for very near reminders', (tester) async {
      final reminder = ReminderModel(
        id: 4,
        name: 'Soon',
        dateTime: DateTime.now().add(const Duration(seconds: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReminderTimeRemaining(reminder: reminder)),
        ),
      );

      expect(find.text('Soon'), findsOneWidget);
    });

    testWidgets('shows nothing for past reminders', (tester) async {
      final reminder = ReminderModel(
        id: 5,
        name: 'Past',
        dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReminderTimeRemaining(reminder: reminder)),
        ),
      );

      // SizedBox.shrink is rendered for null duration
      expect(find.text('Soon'), findsNothing);
      expect(find.textContaining('left'), findsNothing);
    });
  });
}
