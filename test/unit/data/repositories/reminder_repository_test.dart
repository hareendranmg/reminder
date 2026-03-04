import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reminder/data/database/app_database.dart';
import 'package:reminder/data/database/daos/reminder_dao.dart';
import 'package:reminder/data/repositories/reminder_repository.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockReminderDao extends Mock implements ReminderDao {}

void main() {
  group('ReminderRepository Unit Tests', () {
    late MockAppDatabase mockDatabase;
    late MockReminderDao mockDao;
    late ReminderRepository repository;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockDao = MockReminderDao();
      when(() => mockDatabase.reminderDao).thenReturn(mockDao);

      repository = ReminderRepository(mockDatabase);
    });

    test('getAllReminders returns mapped models', () async {
      // Setup mock data
      final dateTime = DateTime.now();
      final entity = Reminder(
        id: 1,
        name: 'Test',
        description: 'Desc',
        isRecurring: false,
        isSensitive: false,
        reminderDateTime: dateTime,
        isActive: true,
        createdAt: dateTime,
        updatedAt: dateTime,
      );

      when(() => mockDao.getAllReminders()).thenAnswer((_) async => [entity]);

      // Execute
      final result = await repository.getAllReminders();

      // Verify
      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.name, 'Test');
    });

    test('getReminderById returns correctly', () async {
      final dateTime = DateTime.now();
      final entity = Reminder(
        id: 1,
        name: 'Test ID',
        description: null,
        isRecurring: false,
        isSensitive: true,
        reminderDateTime: dateTime,
        isActive: true,
        createdAt: dateTime,
        updatedAt: dateTime,
      );

      when(() => mockDao.getReminderById(1)).thenAnswer((_) async => entity);

      when(() => mockDao.getReminderById(2)).thenAnswer((_) async => null);

      final resultHit = await repository.getReminderById(1);
      final resultMiss = await repository.getReminderById(2);

      expect(resultHit?.name, 'Test ID');
      expect(resultHit?.isSensitive, isTrue);
      expect(resultMiss, isNull);
    });

    test('deleteReminder delegates properly', () async {
      when(() => mockDao.deleteReminder(1)).thenAnswer((_) async => 1);

      await repository.deleteReminder(1);

      verify(() => mockDao.deleteReminder(1)).called(1);
    });

    test('toggleReminderActive delegates properly', () async {
      when(
        () => mockDao.toggleReminderActive(1, isActive: false),
      ).thenAnswer((_) async => 1);

      await repository.toggleReminderActive(1, isActive: false);

      verify(() => mockDao.toggleReminderActive(1, isActive: false)).called(1);
    });
  });
}
