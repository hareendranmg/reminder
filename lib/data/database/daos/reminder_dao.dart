import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/reminders_table.dart';

part 'reminder_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase>
    with _$ReminderDaoMixin {
  ReminderDao(super.db);

  /// Get all reminders ordered by date
  Future<List<Reminder>> getAllReminders() {
    return (select(reminders)..orderBy([
          (t) => OrderingTerm(
            expression: t.reminderDateTime,
            mode: OrderingMode.asc,
          ),
        ]))
        .get();
  }

  /// Watch all reminders (reactive stream)
  Stream<List<Reminder>> watchAllReminders() {
    return (select(reminders)..orderBy([
          (t) => OrderingTerm(
            expression: t.reminderDateTime,
            mode: OrderingMode.asc,
          ),
        ]))
        .watch();
  }

  /// Get active reminders only
  Future<List<Reminder>> getActiveReminders() {
    return (select(reminders)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
  }

  /// Watch active reminders
  Stream<List<Reminder>> watchActiveReminders() {
    return (select(reminders)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.asc,
            ),
          ]))
        .watch();
  }

  /// Get reminders for today
  Future<List<Reminder>> getTodayReminders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(reminders)
          ..where(
            (t) =>
                t.reminderDateTime.isBiggerOrEqualValue(startOfDay) &
                t.reminderDateTime.isSmallerThanValue(endOfDay),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
  }

  /// Watch reminders for today
  Stream<List<Reminder>> watchTodayReminders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(reminders)
          ..where(
            (t) =>
                t.reminderDateTime.isBiggerOrEqualValue(startOfDay) &
                t.reminderDateTime.isSmallerThanValue(endOfDay),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.asc,
            ),
          ]))
        .watch();
  }

  /// Get upcoming reminders (future)
  Future<List<Reminder>> getUpcomingReminders() {
    final now = DateTime.now();
    return (select(reminders)
          ..where((t) => t.reminderDateTime.isBiggerThanValue(now))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
  }

  /// Watch upcoming reminders
  Stream<List<Reminder>> watchUpcomingReminders() {
    final now = DateTime.now();
    return (select(reminders)
          ..where((t) => t.reminderDateTime.isBiggerThanValue(now))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.asc,
            ),
          ]))
        .watch();
  }

  /// Get past reminders
  Future<List<Reminder>> getPastReminders() {
    final now = DateTime.now();
    return (select(reminders)
          ..where(
            (t) =>
                t.reminderDateTime.isSmallerThanValue(now) &
                t.isRecurring.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Watch past reminders
  Stream<List<Reminder>> watchPastReminders() {
    final now = DateTime.now();
    return (select(reminders)
          ..where(
            (t) =>
                t.reminderDateTime.isSmallerThanValue(now) &
                t.isRecurring.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.reminderDateTime,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  /// Get reminders that need to trigger (next trigger time is now or past)
  Future<List<Reminder>> getRemindersToTrigger() {
    final now = DateTime.now();
    return (select(reminders)..where(
          (t) =>
              t.isActive.equals(true) &
              (t.nextTriggerTime.isSmallerOrEqualValue(now) |
                  (t.nextTriggerTime.isNull() &
                      t.reminderDateTime.isSmallerOrEqualValue(now))),
        ))
        .get();
  }

  /// Get a single reminder by ID
  Future<Reminder?> getReminderById(int id) {
    return (select(reminders)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new reminder
  Future<int> insertReminder(RemindersCompanion reminder) {
    return into(reminders).insert(reminder);
  }

  /// Update an existing reminder
  Future<bool> updateReminder(Reminder reminder) {
    return update(reminders).replace(reminder);
  }

  /// Update specific fields of a reminder
  Future<int> updateReminderFields(int id, RemindersCompanion companion) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(companion);
  }

  /// Delete a reminder
  Future<int> deleteReminder(int id) {
    return (delete(reminders)..where((t) => t.id.equals(id))).go();
  }

  /// Toggle reminder active status
  Future<int> toggleReminderActive(int id, bool isActive) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update next trigger time for recurring reminders
  Future<int> updateNextTriggerTime(int id, DateTime nextTime) {
    return (update(reminders)..where((t) => t.id.equals(id))).write(
      RemindersCompanion(
        nextTriggerTime: Value(nextTime),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
