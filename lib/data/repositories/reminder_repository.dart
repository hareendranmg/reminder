import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import '../models/reminder.dart';

/// Repository for managing reminders
class ReminderRepository {
  final AppDatabase _database;

  ReminderRepository(this._database);

  /// Get all reminders
  Future<List<ReminderModel>> getAllReminders() async {
    final entities = await _database.reminderDao.getAllReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch all reminders (reactive stream)
  Stream<List<ReminderModel>> watchAllReminders() {
    return _database.reminderDao.watchAllReminders().map(
      (entities) => entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
    );
  }

  /// Get active reminders
  Future<List<ReminderModel>> getActiveReminders() async {
    final entities = await _database.reminderDao.getActiveReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch active reminders
  Stream<List<ReminderModel>> watchActiveReminders() {
    return _database.reminderDao.watchActiveReminders().map(
      (entities) => entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
    );
  }

  /// Get reminders for today
  Future<List<ReminderModel>> getTodayReminders() async {
    final entities = await _database.reminderDao.getTodayReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch reminders for today
  Stream<List<ReminderModel>> watchTodayReminders() {
    return _database.reminderDao.watchTodayReminders().map(
      (entities) => entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
    );
  }

  /// Get upcoming reminders
  Future<List<ReminderModel>> getUpcomingReminders() async {
    final entities = await _database.reminderDao.getUpcomingReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch upcoming reminders
  Stream<List<ReminderModel>> watchUpcomingReminders() {
    return _database.reminderDao.watchUpcomingReminders().map(
      (entities) => entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
    );
  }

  /// Get past reminders
  Future<List<ReminderModel>> getPastReminders() async {
    final entities = await _database.reminderDao.getPastReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch past reminders
  Stream<List<ReminderModel>> watchPastReminders() {
    return _database.reminderDao.watchPastReminders().map(
      (entities) => entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
    );
  }

  /// Get reminders that need to trigger
  Future<List<ReminderModel>> getRemindersToTrigger() async {
    final entities = await _database.reminderDao.getRemindersToTrigger();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Get a single reminder by ID
  Future<ReminderModel?> getReminderById(int id) async {
    final entity = await _database.reminderDao.getReminderById(id);
    return entity != null ? ReminderModel.fromDbEntity(entity) : null;
  }

  /// Create a new reminder
  Future<int> createReminder(ReminderModel reminder) async {
    final companion = RemindersCompanion(
      name: Value(reminder.name),
      description: Value(reminder.description),
      isRecurring: Value(reminder.isRecurring),
      reminderDateTime: Value(reminder.dateTime),
      recurringType: Value(reminder.recurringType?.name),
      recurringInterval: Value(reminder.recurringInterval),
      nextTriggerTime: Value(
        reminder.isRecurring ? reminder.calculateNextTriggerTime() : null,
      ),
      isActive: Value(reminder.isActive),
    );

    return _database.reminderDao.insertReminder(companion);
  }

  /// Update an existing reminder
  Future<void> updateReminder(ReminderModel reminder) async {
    if (reminder.id == null) {
      throw ArgumentError('Cannot update a reminder without an ID');
    }

    final companion = RemindersCompanion(
      name: Value(reminder.name),
      description: Value(reminder.description),
      isRecurring: Value(reminder.isRecurring),
      reminderDateTime: Value(reminder.dateTime),
      recurringType: Value(reminder.recurringType?.name),
      recurringInterval: Value(reminder.recurringInterval),
      nextTriggerTime: Value(
        reminder.isRecurring ? reminder.calculateNextTriggerTime() : null,
      ),
      isActive: Value(reminder.isActive),
      updatedAt: Value(DateTime.now()),
    );

    await _database.reminderDao.updateReminderFields(reminder.id!, companion);
  }

  /// Delete a reminder
  Future<void> deleteReminder(int id) async {
    await _database.reminderDao.deleteReminder(id);
  }

  /// Toggle reminder active status
  Future<void> toggleReminderActive(int id, bool isActive) async {
    await _database.reminderDao.toggleReminderActive(id, isActive);
  }

  /// Update next trigger time after reminder fires
  Future<void> updateNextTriggerTime(ReminderModel reminder) async {
    if (reminder.id == null || !reminder.isRecurring) return;

    final nextTime = reminder.calculateNextTriggerTime();
    await _database.reminderDao.updateNextTriggerTime(reminder.id!, nextTime);
  }

  /// Get reminders filtered by type
  Stream<List<ReminderModel>> watchRemindersByFilter(ReminderFilter filter) {
    switch (filter) {
      case ReminderFilter.all:
        return watchAllReminders();
      case ReminderFilter.today:
        return watchTodayReminders();
      case ReminderFilter.upcoming:
        return watchUpcomingReminders();
      case ReminderFilter.past:
        return watchPastReminders();
    }
  }
}
