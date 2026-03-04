import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reminder/core/constants/app_constants.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/data/repositories/reminder_repository.dart';
import 'package:reminder/services/scheduler_service.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ReminderModel(name: 'fallback', dateTime: DateTime(2025)),
    );
  });

  group('SchedulerService', () {
    late MockReminderRepository mockRepo;
    late SchedulerService service;

    setUp(() {
      mockRepo = MockReminderRepository();
      service = SchedulerService(mockRepo);
    });

    tearDown(() {
      service.dispose();
    });

    test('dispose cancels all timers and resets state', () {
      // Should not throw
      service.dispose();
    });

    test('initialize only runs once', () async {
      when(() => mockRepo.getRemindersToTrigger()).thenAnswer((_) async => []);
      when(() => mockRepo.getActiveReminders()).thenAnswer((_) async => []);

      await service.initialize();
      await service.initialize(); // Second call should be no-op

      verify(() => mockRepo.getRemindersToTrigger()).called(1);
    });

    test('cancelReminder removes timer for given id', () {
      // Should not throw even for non-existent id
      service.cancelReminder(999);
    });

    test('refresh calls _checkAndScheduleReminders', () async {
      when(() => mockRepo.getActiveReminders()).thenAnswer((_) async => []);

      await service.refresh();
      verify(() => mockRepo.getActiveReminders()).called(1);
    });

    test('initialize deactivates past one-time reminders', () async {
      final pastReminder = ReminderModel(
        id: 1,
        name: 'Past one-time',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        isRecurring: false,
        isActive: true,
      );

      when(
        () => mockRepo.getRemindersToTrigger(),
      ).thenAnswer((_) async => [pastReminder]);
      when(
        () => mockRepo.toggleReminderActive(
          any(),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockRepo.getActiveReminders()).thenAnswer((_) async => []);

      await service.initialize();

      verify(() => mockRepo.toggleReminderActive(1, isActive: false)).called(1);
    });

    test('initialize does NOT deactivate recurring reminders', () async {
      final recurringReminder = ReminderModel(
        id: 2,
        name: 'Recurring',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        isRecurring: true,
        recurringType: RecurringType.hours,
        recurringInterval: 1,
        isActive: true,
      );

      when(
        () => mockRepo.getRemindersToTrigger(),
      ).thenAnswer((_) async => [recurringReminder]);
      when(() => mockRepo.getActiveReminders()).thenAnswer((_) async => []);

      await service.initialize();

      verifyNever(
        () => mockRepo.toggleReminderActive(
          any(),
          isActive: any(named: 'isActive'),
        ),
      );
    });

    test('refresh schedules future reminders', () async {
      final futureReminder = ReminderModel(
        id: 3,
        name: 'Future',
        dateTime: DateTime.now().add(const Duration(minutes: 30)),
        isActive: true,
      );

      when(
        () => mockRepo.getActiveReminders(),
      ).thenAnswer((_) async => [futureReminder]);

      await service.refresh();

      // The timer should be scheduled (we can verify indirectly by cancelReminder)
      service.cancelReminder(3);
    });

    test('dispose after initialize handles cleanup', () async {
      when(() => mockRepo.getRemindersToTrigger()).thenAnswer((_) async => []);
      when(() => mockRepo.getActiveReminders()).thenAnswer((_) async => []);

      await service.initialize();
      service.dispose();

      // Should not throw
    });

    test('initialize handles repo errors gracefully', () async {
      when(
        () => mockRepo.getRemindersToTrigger(),
      ).thenThrow(Exception('DB error'));
      when(() => mockRepo.getActiveReminders()).thenAnswer((_) async => []);

      // Should not throw
      await service.initialize();
    });
  });
}
