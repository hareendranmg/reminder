import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import '../models/reminder.dart';

/// Repository for managing reminders
class ReminderRepository {
  final AppDatabase _database;

  ReminderRepository(this._database);

  /// Creates a stream that re-subscribes to the [streamFactory] whenever the
  /// date changes (at midnight). This prevents stale date boundaries in
  /// watch queries that capture `DateTime.now()` at creation time.
  Stream<List<ReminderModel>> _dateAwareStream(
    Stream<List<ReminderModel>> Function() streamFactory,
  ) {
    late StreamController<List<ReminderModel>> controller;
    StreamSubscription<List<ReminderModel>>? innerSub;
    Timer? midnightTimer;

    void scheduleNextMidnight() {
      final now = DateTime.now();
      final nextMidnight = DateTime(now.year, now.month, now.day + 1);
      final duration = nextMidnight.difference(now);

      midnightTimer?.cancel();
      midnightTimer = Timer(duration, () {
        // Re-subscribe with fresh date boundaries
        innerSub?.cancel();
        innerSub = streamFactory().listen(
          controller.add,
          onError: controller.addError,
        );
        scheduleNextMidnight();
      });
    }

    controller = StreamController<List<ReminderModel>>.broadcast(
      onListen: () {
        innerSub = streamFactory().listen(
          controller.add,
          onError: controller.addError,
        );
        scheduleNextMidnight();
      },
      onCancel: () {
        innerSub?.cancel();
        midnightTimer?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

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

  /// Watch reminders for today (re-subscribes at midnight)
  Stream<List<ReminderModel>> watchTodayReminders() {
    return _dateAwareStream(
      () => _database.reminderDao.watchTodayReminders().map(
        (entities) =>
            entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
      ),
    );
  }

  /// Get upcoming reminders
  Future<List<ReminderModel>> getUpcomingReminders() async {
    final entities = await _database.reminderDao.getUpcomingReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch upcoming reminders (re-subscribes at midnight)
  Stream<List<ReminderModel>> watchUpcomingReminders() {
    return _dateAwareStream(
      () => _database.reminderDao.watchUpcomingReminders().map(
        (entities) =>
            entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
      ),
    );
  }

  /// Get past reminders
  Future<List<ReminderModel>> getPastReminders() async {
    final entities = await _database.reminderDao.getPastReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch past reminders (re-subscribes at midnight)
  Stream<List<ReminderModel>> watchPastReminders() {
    return _dateAwareStream(
      () => _database.reminderDao.watchPastReminders().map(
        (entities) =>
            entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
      ),
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
  Future<int> createReminder(ReminderModel reminder) {
    final companion = RemindersCompanion(
      name: Value(reminder.name),
      description: Value(reminder.description),
      isRecurring: Value(reminder.isRecurring),
      isSensitive: Value(reminder.isSensitive),
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
      isSensitive: Value(reminder.isSensitive),
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
  Future<void> toggleReminderActive(int id, {required bool isActive}) async {
    await _database.reminderDao.toggleReminderActive(id, isActive: isActive);
  }

  /// Update next trigger time after reminder fires (uses original schedule anchor).
  Future<void> updateNextTriggerTime(ReminderModel reminder) async {
    if (reminder.id == null || !reminder.isRecurring) return;

    final nextTime = reminder.calculateNextTriggerTime();
    await _database.reminderDao.updateNextTriggerTime(reminder.id!, nextTime);
  }

  /// Set next trigger time explicitly (e.g. when snoozing recurring reminder).
  /// Use this instead of [updateReminder] when snoozing so the snooze time is preserved.
  Future<void> setNextTriggerTime(int id, DateTime nextTime) async {
    await _database.reminderDao.updateNextTriggerTime(id, nextTime);
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
