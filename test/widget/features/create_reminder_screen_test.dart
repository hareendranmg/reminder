import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/features/reminder/widgets/reminder_recurring_toggle.dart';
import 'package:reminder/features/reminder/widgets/reminder_section_title.dart';

void main() {
  group('ReminderSectionTitle', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ReminderSectionTitle(title: 'Date & Time')),
        ),
      );

      expect(find.text('Date & Time'), findsOneWidget);
    });

    testWidgets('renders with custom title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReminderSectionTitle(title: 'Recurrence Settings'),
          ),
        ),
      );

      expect(find.text('Recurrence Settings'), findsOneWidget);
    });
  });

  group('ReminderRecurringToggle', () {
    testWidgets('shows One-time when not recurring', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderRecurringToggle(isRecurring: false, onToggle: (_) {}),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('One-time'), findsOneWidget);
      expect(find.text('Triggers once at the scheduled time'), findsOneWidget);
      expect(find.byIcon(Icons.looks_one_rounded), findsOneWidget);
    });

    testWidgets('shows Recurring when recurring', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderRecurringToggle(isRecurring: true, onToggle: (_) {}),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Recurring'), findsOneWidget);
      expect(find.text('Repeats at a regular interval'), findsOneWidget);
      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
    });

    testWidgets('switch fires onToggle callback', (tester) async {
      bool? toggleValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderRecurringToggle(
              isRecurring: false,
              onToggle: (val) => toggleValue = val,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(Switch));
      expect(toggleValue, isTrue);
    });

    testWidgets('switch has correct value when recurring', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReminderRecurringToggle(isRecurring: true, onToggle: (_) {}),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });
  });
}
