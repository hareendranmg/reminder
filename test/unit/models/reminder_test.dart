import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/core/constants/app_constants.dart';
import 'package:reminder/data/models/reminder.dart';

void main() {
  group('ReminderModel', () {
    final now = DateTime(2025, 1, 1, 12, 0, 0);

    ReminderModel buildReminder({
      int? id,
      String name = 'Test',
      String? description,
      bool isRecurring = false,
      bool isSensitive = false,
      DateTime? dateTime,
      RecurringType? recurringType,
      int? recurringInterval,
      DateTime? nextTriggerTime,
      bool isActive = true,
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      return ReminderModel(
        id: id,
        name: name,
        description: description,
        isRecurring: isRecurring,
        isSensitive: isSensitive,
        dateTime: dateTime ?? now,
        recurringType: recurringType,
        recurringInterval: recurringInterval,
        nextTriggerTime: nextTriggerTime,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    group('toJson and fromJson', () {
      test('round-trips all fields correctly', () {
        final reminder = buildReminder(
          id: 1,
          name: 'Test Reminder',
          description: 'Test Description',
          isRecurring: true,
          isSensitive: true,
          recurringType: RecurringType.days,
          recurringInterval: 2,
          nextTriggerTime: now.add(const Duration(days: 2)),
          createdAt: now,
          updatedAt: now.add(const Duration(hours: 1)),
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
        expect(fromJson.createdAt, now);
        expect(fromJson.updatedAt, now.add(const Duration(hours: 1)));
      });

      test('handles null optional fields', () {
        final reminder = buildReminder(name: 'Minimal');
        final json = reminder.toJson();
        final fromJson = ReminderModel.fromJson(json);

        expect(fromJson.id, isNull);
        expect(fromJson.description, isNull);
        expect(fromJson.recurringType, isNull);
        expect(fromJson.recurringInterval, isNull);
        expect(fromJson.nextTriggerTime, isNull);
        expect(fromJson.createdAt, isNull);
        expect(fromJson.updatedAt, isNull);
      });

      test('fromJson defaults booleans when missing', () {
        final json = {'name': 'Test', 'dateTime': now.toIso8601String()};
        final fromJson = ReminderModel.fromJson(json);

        expect(fromJson.isRecurring, false);
        expect(fromJson.isSensitive, false);
        expect(fromJson.isActive, true);
      });

      test('fromJson handles unknown recurringType with fallback', () {
        final json = {
          'name': 'Test',
          'dateTime': now.toIso8601String(),
          'recurringType': 'unknownValue',
        };
        final fromJson = ReminderModel.fromJson(json);
        expect(fromJson.recurringType, RecurringType.days);
      });
    });

    group('toJsonString and fromJsonString', () {
      test('round-trips via JSON string', () {
        final reminder = buildReminder(id: 5, name: 'String test');
        final jsonStr = reminder.toJsonString();
        final decoded = ReminderModel.fromJsonString(jsonStr);

        expect(decoded.id, 5);
        expect(decoded.name, 'String test');
      });

      test('toJsonString produces valid JSON', () {
        final reminder = buildReminder(name: 'Valid JSON');
        final jsonStr = reminder.toJsonString();
        expect(() => jsonDecode(jsonStr), returnsNormally);
      });
    });

    group('copyWith', () {
      test('creates identical copy when no args', () {
        final original = buildReminder(
          id: 1,
          name: 'Original',
          description: 'Desc',
          isRecurring: true,
          isSensitive: true,
          recurringType: RecurringType.hours,
          recurringInterval: 3,
          nextTriggerTime: now.add(const Duration(hours: 3)),
        );
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.name, original.name);
        expect(copy.description, original.description);
        expect(copy.isRecurring, original.isRecurring);
        expect(copy.isSensitive, original.isSensitive);
        expect(copy.dateTime, original.dateTime);
        expect(copy.recurringType, original.recurringType);
        expect(copy.recurringInterval, original.recurringInterval);
        expect(copy.nextTriggerTime, original.nextTriggerTime);
        expect(copy.isActive, original.isActive);
      });

      test('overrides specified fields', () {
        final original = buildReminder(id: 1, name: 'Original');
        final copy = original.copyWith(
          name: 'Changed',
          isRecurring: true,
          isSensitive: true,
          recurringType: RecurringType.weeks,
          recurringInterval: 2,
          isActive: false,
        );

        expect(copy.id, 1);
        expect(copy.name, 'Changed');
        expect(copy.isRecurring, true);
        expect(copy.isSensitive, true);
        expect(copy.recurringType, RecurringType.weeks);
        expect(copy.recurringInterval, 2);
        expect(copy.isActive, false);
      });
    });

    group('equality and hashCode', () {
      test('reminders with same id are equal', () {
        final a = buildReminder(id: 1, name: 'A');
        final b = buildReminder(id: 1, name: 'B');
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('reminders with different id are not equal', () {
        final a = buildReminder(id: 1, name: 'A');
        final b = buildReminder(id: 2, name: 'A');
        expect(a, isNot(equals(b)));
      });

      test('identity check works', () {
        final a = buildReminder(id: 1);
        expect(a == a, isTrue);
      });

      test('comparison with non-ReminderModel returns false', () {
        final a = buildReminder(id: 1);
        // ignore: unrelated_type_equality_checks
        expect(a == 'not a reminder', isFalse);
      });
    });

    group('toString', () {
      test('contains key fields', () {
        final reminder = buildReminder(
          id: 42,
          name: 'My Reminder',
          isRecurring: true,
          isSensitive: true,
        );
        final str = reminder.toString();

        expect(str, contains('42'));
        expect(str, contains('My Reminder'));
        expect(str, contains('isRecurring: true'));
        expect(str, contains('isSensitive: true'));
      });
    });

    group('calculateNextTriggerTime', () {
      test('returns original time if not recurring', () {
        final reminder = buildReminder(isRecurring: false);
        expect(
          reminder.calculateNextTriggerTime(now.add(const Duration(hours: 5))),
          now,
        );
      });

      test('returns original time if no recurringType', () {
        final reminder = buildReminder(isRecurring: true, recurringInterval: 1);
        expect(reminder.calculateNextTriggerTime(now), now);
      });

      test('returns original time if no recurringInterval', () {
        final reminder = buildReminder(
          isRecurring: true,
          recurringType: RecurringType.days,
        );
        expect(reminder.calculateNextTriggerTime(now), now);
      });

      test('calculates next time for minutes', () {
        final reminder = buildReminder(
          isRecurring: true,
          recurringType: RecurringType.minutes,
          recurringInterval: 15,
        );
        final nextTime = reminder.calculateNextTriggerTime(
          now.add(const Duration(minutes: 5)),
        );
        expect(nextTime, now.add(const Duration(minutes: 15)));
      });

      test('calculates next time for hours past multiple intervals', () {
        final reminder = buildReminder(
          isRecurring: true,
          recurringType: RecurringType.hours,
          recurringInterval: 2,
        );
        final checkTime = now.add(const Duration(hours: 5));
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        expect(nextTime, now.add(const Duration(hours: 6)));
      });

      test('calculates next time for days', () {
        final reminder = buildReminder(
          isRecurring: true,
          recurringType: RecurringType.days,
          recurringInterval: 3,
        );
        final checkTime = now.add(const Duration(days: 1));
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        expect(nextTime, now.add(const Duration(days: 3)));
      });

      test('calculates next time for weeks', () {
        final reminder = buildReminder(
          isRecurring: true,
          recurringType: RecurringType.weeks,
          recurringInterval: 2,
        );
        final checkTime = now.add(const Duration(days: 10));
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        expect(nextTime, now.add(const Duration(days: 14)));
      });

      test('calculates next time for months with day clamping', () {
        final reminder = buildReminder(
          dateTime: DateTime(2025, 1, 31, 12, 0, 0),
          isRecurring: true,
          recurringType: RecurringType.months,
          recurringInterval: 1,
        );
        final checkTime = DateTime(2025, 2, 1, 12, 0, 0);
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        expect(nextTime, DateTime(2025, 2, 28, 12, 0, 0));
      });

      test('months rollover across years (Dec → next year)', () {
        final reminder = buildReminder(
          dateTime: DateTime(2025, 11, 15, 10, 0, 0),
          isRecurring: true,
          recurringType: RecurringType.months,
          recurringInterval: 3,
        );
        final checkTime = DateTime(2026, 1, 1);
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        expect(nextTime, DateTime(2026, 2, 15, 10, 0, 0));
      });

      test('leap year Feb 29 clamping', () {
        final reminder = buildReminder(
          dateTime: DateTime(2024, 1, 31, 9, 0, 0),
          isRecurring: true,
          recurringType: RecurringType.months,
          recurringInterval: 1,
        );
        final checkTime = DateTime(2024, 2, 1);
        final nextTime = reminder.calculateNextTriggerTime(checkTime);
        // Leap year: Feb has 29 days
        expect(nextTime, DateTime(2024, 2, 29, 9, 0, 0));
      });

      test('uses default now when fromTime is null', () {
        final futureTime = DateTime.now().add(const Duration(hours: 2));
        final reminder = buildReminder(
          dateTime: futureTime,
          isRecurring: true,
          recurringType: RecurringType.hours,
          recurringInterval: 1,
        );
        // Should not throw and should return a future time
        final result = reminder.calculateNextTriggerTime();
        expect(
          result.isAfter(DateTime.now().subtract(const Duration(seconds: 5))),
          isTrue,
        );
      });

      test('skips exact match (isAtSameMomentAs)', () {
        final reminder = buildReminder(
          isRecurring: true,
          recurringType: RecurringType.hours,
          recurringInterval: 1,
        );
        // fromTime exactly equals dateTime
        final nextTime = reminder.calculateNextTriggerTime(now);
        expect(nextTime, now.add(const Duration(hours: 1)));
      });
    });

    group('getDurationUntilTrigger', () {
      test('returns null for past non-recurring reminder', () {
        final reminder = buildReminder(
          dateTime: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(reminder.getDurationUntilTrigger(), isNull);
      });

      test('returns positive duration for future reminder', () {
        final futureTime = DateTime.now().add(const Duration(hours: 2));
        final reminder = buildReminder(dateTime: futureTime);
        final duration = reminder.getDurationUntilTrigger();
        expect(duration, isNotNull);
        expect(duration!.inMinutes, greaterThan(100));
      });

      test('uses nextTriggerTime for recurring reminders', () {
        final futureTime = DateTime.now().add(const Duration(hours: 3));
        final reminder = buildReminder(
          isRecurring: true,
          dateTime: DateTime.now().subtract(const Duration(hours: 1)),
          nextTriggerTime: futureTime,
        );
        final duration = reminder.getDurationUntilTrigger();
        expect(duration, isNotNull);
        expect(duration!.inMinutes, greaterThan(150));
      });

      test(
        'falls back to dateTime when nextTriggerTime is null for recurring',
        () {
          final reminder = buildReminder(
            isRecurring: true,
            dateTime: DateTime.now().subtract(const Duration(hours: 1)),
          );
          expect(reminder.getDurationUntilTrigger(), isNull);
        },
      );
    });

    group('shouldTriggerNow', () {
      test('returns true when past and active', () {
        final reminder = buildReminder(
          dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        expect(reminder.shouldTriggerNow(), isTrue);
      });

      test('returns false when inactive', () {
        final reminder = buildReminder(
          dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
          isActive: false,
        );
        expect(reminder.shouldTriggerNow(), isFalse);
      });

      test('returns false when future', () {
        final reminder = buildReminder(
          dateTime: DateTime.now().add(const Duration(minutes: 5)),
        );
        expect(reminder.shouldTriggerNow(), isFalse);
      });

      test('uses nextTriggerTime for recurring', () {
        final reminder = buildReminder(
          isRecurring: true,
          dateTime: DateTime.now().add(const Duration(hours: 10)),
          nextTriggerTime: DateTime.now().subtract(const Duration(minutes: 1)),
        );
        expect(reminder.shouldTriggerNow(), isTrue);
      });
    });
  });
}
