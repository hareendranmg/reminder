import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/core/constants/app_constants.dart';
import 'package:reminder/data/models/reminder.dart';

void main() {
  group('ReminderModel Unit Tests', () {
    final now = DateTime(2025, 1, 1, 12, 0, 0);

    test('toJson and fromJson work correctly', () {
      final reminder = ReminderModel(
        id: 1,
        name: 'Test Reminder',
        description: 'Test Description',
        isRecurring: true,
        isSensitive: true,
        dateTime: now,
        recurringType: RecurringType.days,
        recurringInterval: 2,
        nextTriggerTime: now.add(const Duration(days: 2)),
        isActive: true,
      );

      final json = reminder.toJson();
      final fromJson = ReminderModel.fromJson(json);

      expect(fromJson.id, 1);
      expect(fromJson.name, 'Test Reminder');
      expect(fromJson.description, 'Test Description');
      expect(fromJson.isRecurring, true);
      expect(fromJson.isSensitive, true);
      expect(fromJson.dateTime, now);
      expect(fromJson.recurringType, RecurringType.days);
      expect(fromJson.recurringInterval, 2);
      expect(fromJson.nextTriggerTime, now.add(const Duration(days: 2)));
      expect(fromJson.isActive, true);
    });

    group('calculateNextTriggerTime', () {
      test('calculates next time for minutes', () {
        final reminder = ReminderModel(
          name: 'Minutes',
          dateTime: now,
          isRecurring: true,
          recurringType: RecurringType.minutes,
          recurringInterval: 15,
        );

        final nextTime = reminder.calculateNextTriggerTime(
          now.add(const Duration(minutes: 5)),
        );
        expect(nextTime, now.add(const Duration(minutes: 15)));
      });

      test('calculates next time when past multiple intervals', () {
        final reminder = ReminderModel(
          name: 'Hours',
          dateTime: now,
          isRecurring: true,
          recurringType: RecurringType.hours,
          recurringInterval: 2,
        );

        // Let's say we check 5 hours later
        final checkTime = now.add(const Duration(hours: 5));
        final nextTime = reminder.calculateNextTriggerTime(checkTime);

        // Intervals: +2, +4, +6 h. Since 5 is checked, next is +6
        expect(nextTime, now.add(const Duration(hours: 6)));
      });

      test('calculates next time for months', () {
        final reminder = ReminderModel(
          name: 'Months',
          dateTime: DateTime(2025, 1, 31, 12, 0, 0), // Jan 31
          isRecurring: true,
          recurringType: RecurringType.months,
          recurringInterval: 1,
        );

        final checkTime = DateTime(2025, 2, 1, 12, 0, 0);
        final nextTime = reminder.calculateNextTriggerTime(checkTime);

        // Jan 31 + 1 month -> Feb 28
        expect(nextTime, DateTime(2025, 2, 28, 12, 0, 0));
      });

      test('returns original time if not recurring', () {
        final reminder = ReminderModel(
          name: 'One time',
          dateTime: now,
          isRecurring: false,
        );

        final checkTime = now.add(const Duration(hours: 5));
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        expect(nextTime, now);
      });
    });

    group('shouldTriggerNow', () {
      test('returns true if time is past', () {
        final reminder = ReminderModel(
          name: 'Past',
          dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        expect(reminder.shouldTriggerNow(), isTrue);
      });

      test('returns false if inactive', () {
        final reminder = ReminderModel(
          name: 'Past Inactive',
          dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
          isActive: false,
        );

        expect(reminder.shouldTriggerNow(), isFalse);
      });

      test('returns false if time is future', () {
        final reminder = ReminderModel(
          name: 'Future',
          dateTime: DateTime.now().add(const Duration(minutes: 5)),
        );

        expect(reminder.shouldTriggerNow(), isFalse);
      });
    });
  });
}
