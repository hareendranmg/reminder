import 'package:flutter_test/flutter_test.dart';
import 'package:reminder/core/constants/app_constants.dart';

void main() {
  group('RecurringType', () {
    test('has correct labels', () {
      expect(RecurringType.minutes.label, 'Minutes');
      expect(RecurringType.hours.label, 'Hours');
      expect(RecurringType.days.label, 'Days');
      expect(RecurringType.weeks.label, 'Weeks');
      expect(RecurringType.months.label, 'Months');
    });

    test('values has 5 entries', () {
      expect(RecurringType.values.length, 5);
    });
  });

  group('ReminderFilter', () {
    test('has correct labels', () {
      expect(ReminderFilter.all.label, 'All Reminders');
      expect(ReminderFilter.today.label, 'Today');
      expect(ReminderFilter.upcoming.label, 'Upcoming');
      expect(ReminderFilter.past.label, 'Past');
    });

    test('values has 4 entries', () {
      expect(ReminderFilter.values.length, 4);
    });
  });

  group('AppConstants', () {
    test('app name is correct', () {
      expect(AppConstants.appName, 'Reminder');
    });

    test('sidebar widths are reasonable', () {
      expect(AppConstants.sidebarWidth, greaterThan(0));
      expect(AppConstants.sidebarCollapsedWidth, greaterThan(0));
      expect(
        AppConstants.sidebarWidth,
        greaterThan(AppConstants.sidebarCollapsedWidth),
      );
    });

    test('animation durations are ordered', () {
      expect(
        AppConstants.shortAnimation.inMilliseconds,
        lessThan(AppConstants.mediumAnimation.inMilliseconds),
      );
      expect(
        AppConstants.mediumAnimation.inMilliseconds,
        lessThan(AppConstants.longAnimation.inMilliseconds),
      );
    });

    test('alert window dimensions are positive', () {
      expect(AppConstants.alertWindowWidth, greaterThan(0));
      expect(AppConstants.alertWindowHeight, greaterThan(0));
    });

    test('default intervals covers all recurring types', () {
      for (final type in RecurringType.values) {
        expect(
          AppConstants.defaultIntervals.containsKey(type),
          isTrue,
          reason: '$type missing from defaultIntervals',
        );
        expect(
          AppConstants.defaultIntervals[type]!.isNotEmpty,
          isTrue,
          reason: '$type has empty intervals',
        );
      }
    });

    test('all default intervals are positive', () {
      for (final entry in AppConstants.defaultIntervals.entries) {
        for (final interval in entry.value) {
          expect(
            interval,
            greaterThan(0),
            reason: '${entry.key} has non-positive interval',
          );
        }
      }
    });
  });
}
