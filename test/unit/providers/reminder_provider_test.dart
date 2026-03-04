import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reminder/data/models/reminder.dart';
import 'package:reminder/data/repositories/reminder_repository.dart';
import 'package:reminder/providers/reminder_provider.dart';
import 'package:reminder/services/scheduler_service.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

class MockSchedulerService extends Mock implements SchedulerService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ReminderModel(name: 'fallback', dateTime: DateTime(2025)),
    );
  });

  group('ReminderActionsNotifier', () {
    late MockReminderRepository mockRepo;
    late MockSchedulerService mockScheduler;
    late ReminderActionsNotifier notifier;

    setUp(() {
      mockRepo = MockReminderRepository();
      mockScheduler = MockSchedulerService();
      notifier = ReminderActionsNotifier(mockRepo, mockScheduler);
    });

    test('initial state is AsyncValue.data(null)', () {
      expect(notifier.state, isA<AsyncValue<void>>());
      expect(notifier.state.hasValue, isTrue);
    });

    group('createReminder', () {
      test('creates reminder and refreshes scheduler', () async {
        when(() => mockRepo.createReminder(any())).thenAnswer((_) async => 42);
        when(() => mockScheduler.refresh()).thenAnswer((_) async {});

        final reminder = ReminderModel(
          name: 'Test',
          dateTime: DateTime.now().add(const Duration(hours: 1)),
        );

        final id = await notifier.createReminder(reminder);
        expect(id, 42);
        verify(() => mockRepo.createReminder(any())).called(1);
        verify(() => mockScheduler.refresh()).called(1);
        expect(notifier.state.hasValue, isTrue);
      });

      test('sets error state on failure', () async {
        when(
          () => mockRepo.createReminder(any()),
        ).thenThrow(Exception('DB error'));

        final reminder = ReminderModel(name: 'Test', dateTime: DateTime.now());

        await expectLater(
          () => notifier.createReminder(reminder),
          throwsA(isA<Exception>()),
        );
        expect(notifier.state.hasError, isTrue);
      });
    });

    group('updateReminder', () {
      test('updates reminder and refreshes scheduler', () async {
        when(() => mockRepo.updateReminder(any())).thenAnswer((_) async {});
        when(() => mockScheduler.refresh()).thenAnswer((_) async {});

        final reminder = ReminderModel(
          id: 1,
          name: 'Updated',
          dateTime: DateTime.now(),
        );

        await notifier.updateReminder(reminder);
        verify(() => mockRepo.updateReminder(any())).called(1);
        verify(() => mockScheduler.refresh()).called(1);
        expect(notifier.state.hasValue, isTrue);
      });

      test('sets error state on failure', () async {
        when(
          () => mockRepo.updateReminder(any()),
        ).thenThrow(Exception('Update error'));

        final reminder = ReminderModel(
          id: 1,
          name: 'Updated',
          dateTime: DateTime.now(),
        );

        await expectLater(
          () => notifier.updateReminder(reminder),
          throwsA(isA<Exception>()),
        );
        expect(notifier.state.hasError, isTrue);
      });
    });

    group('deleteReminder', () {
      test('deletes reminder and refreshes scheduler', () async {
        when(() => mockRepo.deleteReminder(any())).thenAnswer((_) async {});
        when(() => mockScheduler.refresh()).thenAnswer((_) async {});

        await notifier.deleteReminder(1);
        verify(() => mockRepo.deleteReminder(1)).called(1);
        verify(() => mockScheduler.refresh()).called(1);
        expect(notifier.state.hasValue, isTrue);
      });

      test('sets error state on failure', () async {
        when(
          () => mockRepo.deleteReminder(any()),
        ).thenThrow(Exception('Delete error'));

        await expectLater(
          () => notifier.deleteReminder(1),
          throwsA(isA<Exception>()),
        );
        expect(notifier.state.hasError, isTrue);
      });
    });

    group('toggleActive', () {
      test('toggles reminder active status', () async {
        when(
          () => mockRepo.toggleReminderActive(
            any(),
            isActive: any(named: 'isActive'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockScheduler.refresh()).thenAnswer((_) async {});

        await notifier.toggleActive(1, isActive: false);
        verify(
          () => mockRepo.toggleReminderActive(1, isActive: false),
        ).called(1);
        verify(() => mockScheduler.refresh()).called(1);
      });

      test('silently handles errors', () async {
        when(
          () => mockRepo.toggleReminderActive(
            any(),
            isActive: any(named: 'isActive'),
          ),
        ).thenThrow(Exception('Toggle error'));

        // Should not throw
        await notifier.toggleActive(1, isActive: true);
      });
    });
  });

  group('Provider state enums', () {
    test('AppView has correct values', () {
      expect(AppView.values.length, 2);
      expect(AppView.reminders, isNotNull);
      expect(AppView.settings, isNotNull);
    });
  });
}
