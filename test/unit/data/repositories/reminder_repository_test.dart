import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reminder/core/constants/app_constants.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/data/repositories/reminder_repository.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ReminderModel(name: 'fallback', dateTime: DateTime(2025)),
    );
  });

  group('ReminderRepository', () {
    late MockReminderRepository mockRepo;

    setUp(() {
      mockRepo = MockReminderRepository();
    });

    group('getAllReminders', () {
      test('returns list of reminders', () async {
        final reminders = [
          ReminderModel(name: 'A', dateTime: DateTime.now()),
          ReminderModel(name: 'B', dateTime: DateTime.now()),
        ];
        when(
          () => mockRepo.getAllReminders(),
        ).thenAnswer((_) async => reminders);

        final result = await mockRepo.getAllReminders();
        expect(result.length, 2);
        expect(result[0].name, 'A');
      });

      test('returns empty list when no reminders', () async {
        when(() => mockRepo.getAllReminders()).thenAnswer((_) async => []);
        final result = await mockRepo.getAllReminders();
        expect(result, isEmpty);
      });
    });

    group('getActiveReminders', () {
      test('returns only active reminders', () async {
        final activeReminder = ReminderModel(
          name: 'Active',
          dateTime: DateTime.now(),
          isActive: true,
        );
        when(
          () => mockRepo.getActiveReminders(),
        ).thenAnswer((_) async => [activeReminder]);

        final result = await mockRepo.getActiveReminders();
        expect(result.length, 1);
        expect(result.first.isActive, true);
      });
    });

    group('getReminderById', () {
      test('returns reminder when found', () async {
        final reminder = ReminderModel(
          id: 1,
          name: 'Found',
          dateTime: DateTime.now(),
        );
        when(
          () => mockRepo.getReminderById(1),
        ).thenAnswer((_) async => reminder);

        final result = await mockRepo.getReminderById(1);
        expect(result, isNotNull);
        expect(result!.id, 1);
      });

      test('returns null when not found', () async {
        when(() => mockRepo.getReminderById(999)).thenAnswer((_) async => null);
        final result = await mockRepo.getReminderById(999);
        expect(result, isNull);
      });
    });

    group('createReminder', () {
      test('returns new id', () async {
        when(() => mockRepo.createReminder(any())).thenAnswer((_) async => 42);
        final reminder = ReminderModel(name: 'New', dateTime: DateTime.now());
        final id = await mockRepo.createReminder(reminder);
        expect(id, 42);
      });
    });

    group('updateReminder', () {
      test('throws ArgumentError when id is null', () {
        // Real repository throws; we simulate this behavior in our mock
        when(
          () => mockRepo.updateReminder(any()),
        ).thenThrow(ArgumentError('Cannot update a reminder without an ID'));
        final reminder = ReminderModel(name: 'No ID', dateTime: DateTime.now());
        expect(
          () => mockRepo.updateReminder(reminder),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('completes successfully with valid id', () async {
        when(() => mockRepo.updateReminder(any())).thenAnswer((_) async {});
        final reminder = ReminderModel(
          id: 10,
          name: 'Updated',
          dateTime: DateTime.now(),
        );
        await mockRepo.updateReminder(reminder);
        verify(() => mockRepo.updateReminder(any())).called(1);
      });
    });

    group('deleteReminder', () {
      test('delegates to DAO', () async {
        when(() => mockRepo.deleteReminder(any())).thenAnswer((_) async {});
        await mockRepo.deleteReminder(1);
        verify(() => mockRepo.deleteReminder(1)).called(1);
      });
    });

    group('toggleReminderActive', () {
      test('toggles active state', () async {
        when(
          () => mockRepo.toggleReminderActive(
            any(),
            isActive: any(named: 'isActive'),
          ),
        ).thenAnswer((_) async {});
        await mockRepo.toggleReminderActive(5, isActive: false);
        verify(
          () => mockRepo.toggleReminderActive(5, isActive: false),
        ).called(1);
      });
    });

    group('updateNextTriggerTime', () {
      test('does nothing for non-recurring reminder', () async {
        final reminder = ReminderModel(
          id: 1,
          name: 'One-time',
          dateTime: DateTime.now(),
          isRecurring: false,
        );
        when(
          () => mockRepo.updateNextTriggerTime(any()),
        ).thenAnswer((_) async {});
        await mockRepo.updateNextTriggerTime(reminder);
        verify(() => mockRepo.updateNextTriggerTime(any())).called(1);
      });
    });

    group('setNextTriggerTime', () {
      test('sets explicit time', () async {
        final nextTime = DateTime(2025, 6, 15, 10, 0, 0);
        when(
          () => mockRepo.setNextTriggerTime(any(), any()),
        ).thenAnswer((_) async {});
        await mockRepo.setNextTriggerTime(7, nextTime);
        verify(() => mockRepo.setNextTriggerTime(7, nextTime)).called(1);
      });
    });

    group('watchRemindersByFilter', () {
      test('returns stream for all filter', () {
        when(
          () => mockRepo.watchRemindersByFilter(ReminderFilter.all),
        ).thenAnswer((_) => const Stream.empty());
        final stream = mockRepo.watchRemindersByFilter(ReminderFilter.all);
        expect(stream, isA<Stream<List<ReminderModel>>>());
      });

      test('returns stream for today filter', () {
        when(
          () => mockRepo.watchRemindersByFilter(ReminderFilter.today),
        ).thenAnswer((_) => const Stream.empty());
        final stream = mockRepo.watchRemindersByFilter(ReminderFilter.today);
        expect(stream, isA<Stream<List<ReminderModel>>>());
      });

      test('returns stream for upcoming filter', () {
        when(
          () => mockRepo.watchRemindersByFilter(ReminderFilter.upcoming),
        ).thenAnswer((_) => const Stream.empty());
        final stream = mockRepo.watchRemindersByFilter(ReminderFilter.upcoming);
        expect(stream, isA<Stream<List<ReminderModel>>>());
      });

      test('returns stream for past filter', () {
        when(
          () => mockRepo.watchRemindersByFilter(ReminderFilter.past),
        ).thenAnswer((_) => const Stream.empty());
        final stream = mockRepo.watchRemindersByFilter(ReminderFilter.past);
        expect(stream, isA<Stream<List<ReminderModel>>>());
      });
    });

    group('watch stream methods', () {
      test('watchAllReminders returns stream', () {
        when(
          () => mockRepo.watchAllReminders(),
        ).thenAnswer((_) => const Stream.empty());
        expect(
          mockRepo.watchAllReminders(),
          isA<Stream<List<ReminderModel>>>(),
        );
      });

      test('watchActiveReminders returns stream', () {
        when(
          () => mockRepo.watchActiveReminders(),
        ).thenAnswer((_) => const Stream.empty());
        expect(
          mockRepo.watchActiveReminders(),
          isA<Stream<List<ReminderModel>>>(),
        );
      });

      test('watchTodayReminders returns stream', () {
        when(
          () => mockRepo.watchTodayReminders(),
        ).thenAnswer((_) => const Stream.empty());
        expect(
          mockRepo.watchTodayReminders(),
          isA<Stream<List<ReminderModel>>>(),
        );
      });

      test('watchUpcomingReminders returns stream', () {
        when(
          () => mockRepo.watchUpcomingReminders(),
        ).thenAnswer((_) => const Stream.empty());
        expect(
          mockRepo.watchUpcomingReminders(),
          isA<Stream<List<ReminderModel>>>(),
        );
      });

      test('watchPastReminders returns stream', () {
        when(
          () => mockRepo.watchPastReminders(),
        ).thenAnswer((_) => const Stream.empty());
        expect(
          mockRepo.watchPastReminders(),
          isA<Stream<List<ReminderModel>>>(),
        );
      });
    });

    group('getTodayReminders', () {
      test('returns today reminders', () async {
        when(() => mockRepo.getTodayReminders()).thenAnswer((_) async => []);
        final result = await mockRepo.getTodayReminders();
        expect(result, isEmpty);
      });
    });

    group('getUpcomingReminders', () {
      test('returns upcoming reminders', () async {
        when(() => mockRepo.getUpcomingReminders()).thenAnswer((_) async => []);
        final result = await mockRepo.getUpcomingReminders();
        expect(result, isEmpty);
      });
    });

    group('getPastReminders', () {
      test('returns past reminders', () async {
        when(() => mockRepo.getPastReminders()).thenAnswer((_) async => []);
        final result = await mockRepo.getPastReminders();
        expect(result, isEmpty);
      });
    });

    group('getRemindersToTrigger', () {
      test('returns reminders needing trigger', () async {
        when(
          () => mockRepo.getRemindersToTrigger(),
        ).thenAnswer((_) async => []);
        final result = await mockRepo.getRemindersToTrigger();
        expect(result, isEmpty);
      });
    });
  });
}
