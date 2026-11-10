import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart';
import '../models/reminder.dart';

/// Repository for managing reminders
class ReminderRepository {
  final AppDatabase _database;

  ReminderRepository(this._database);

  /// How often watch queries bound to the current instant ("upcoming",
  /// "past") are re-run, so reminders move between those lists as their
  /// time passes. Matches the scheduler's one-minute check.
  static const Duration _nowRefreshInterval = Duration(minutes: 1);

  /// Creates a stream that re-subscribes to the [streamFactory] whenever the
  /// date changes (at midnight), or every [refreshEvery] if given. This
  /// prevents stale boundaries in watch queries that capture `DateTime.now()`
  /// at creation time.
  Stream<List<ReminderModel>> _dateAwareStream(
    Stream<List<ReminderModel>> Function() streamFactory, {
    Duration? refreshEvery,
  }) {
    late StreamController<List<ReminderModel>> controller;
    StreamSubscription<List<ReminderModel>>? innerSub;
    Timer? refreshTimer;

    void scheduleNextRefresh() {
      final now = DateTime.now();
      final duration =
          refreshEvery ??
          DateTime(now.year, now.month, now.day + 1).difference(now);

      refreshTimer?.cancel();
      refreshTimer = Timer(duration, () {
        // Re-subscribe with fresh boundaries
        innerSub?.cancel();
        innerSub = streamFactory().listen(
          controller.add,
          onError: controller.addError,
        );
        scheduleNextRefresh();
      });
    }

    controller = StreamController<List<ReminderModel>>.broadcast(
      onListen: () {
        innerSub = streamFactory().listen(
          controller.add,
          onError: controller.addError,
        );
        scheduleNextRefresh();
      },
      onCancel: () {
        innerSub?.cancel();
        refreshTimer?.cancel();
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

  /// Watch upcoming reminders (re-evaluated every minute)
  Stream<List<ReminderModel>> watchUpcomingReminders() {
    return _dateAwareStream(
      () => _database.reminderDao.watchUpcomingReminders().map(
        (entities) =>
            entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
      ),
      refreshEvery: _nowRefreshInterval,
    );
  }

  /// Get past reminders
  Future<List<ReminderModel>> getPastReminders() async {
    final entities = await _database.reminderDao.getPastReminders();
    return entities.map((e) => ReminderModel.fromDbEntity(e)).toList();
  }

  /// Watch past reminders (re-evaluated every minute)
  Stream<List<ReminderModel>> watchPastReminders() {
    return _dateAwareStream(
      () => _database.reminderDao.watchPastReminders().map(
        (entities) =>
            entities.map((e) => ReminderModel.fromDbEntity(e)).toList(),
      ),
      refreshEvery: _nowRefreshInterval,
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

    // A recurring reminder that was paused still has the occurrence it was
    // paused on; move it forward so re-enabling doesn't fire a stale alert.
    if (isActive) {
      final reminder = await getReminderById(id);
      if (reminder != null && reminder.isRecurring) {
        await updateNextTriggerTime(reminder);
      }
    }
  }

  /// Snooze a reminder until [until]. Works for both recurring and one-time
  /// reminders: the snooze time is stored as the next trigger time (the
  /// original schedule in `dateTime` is untouched) and the reminder is
  /// re-activated, since one-time reminders are deactivated when they fire.
  Future<void> snoozeReminder(int id, DateTime until) async {
    await _database.reminderDao.snoozeReminder(id, until);
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
