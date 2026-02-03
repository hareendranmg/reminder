import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/reminder.dart';
import '../data/repositories/reminder_repository.dart';
import 'window_service.dart';

/// Service for scheduling and triggering reminders
class SchedulerService {
  final ReminderRepository _repository;
  final Map<int, Timer> _timers = {};
  Timer? _checkTimer;
  bool _isInitialized = false;

  SchedulerService(this._repository);

  /// Initialize the scheduler
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Mark past one-time reminders as inactive (don't trigger on startup)
    await _deactivatePastOneTimeReminders();

    // Initial check for reminders - only schedule future ones
    await _checkAndScheduleReminders();

    // Periodic check every minute for new/updated reminders
    _checkTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAndScheduleReminders(),
    );
  }

  /// Deactivate one-time reminders that are in the past
  Future<void> _deactivatePastOneTimeReminders() async {
    try {
      final remindersToTrigger = await _repository.getRemindersToTrigger();
      for (final reminder in remindersToTrigger) {
        if (!reminder.isRecurring && reminder.id != null) {
          // One-time reminder in the past - deactivate it
          debugPrint('Deactivating past reminder: ${reminder.name}');
          await _repository.toggleReminderActive(reminder.id!, false);
        }
      }
    } catch (e) {
      debugPrint('Error deactivating past reminders: $e');
    }
  }

  /// Check for reminders that need to be scheduled
  Future<void> _checkAndScheduleReminders() async {
    try {
      final activeReminders = await _repository.getActiveReminders();

      // Cancel timers for reminders that are no longer active
      final activeIds = activeReminders.map((r) => r.id).toSet();
      final timerIdsToCancel = _timers.keys
          .where((id) => !activeIds.contains(id))
          .toList();
      for (final id in timerIdsToCancel) {
        _timers[id]?.cancel();
        _timers.remove(id);
      }

      // Schedule or reschedule active reminders
      for (final reminder in activeReminders) {
        if (reminder.id != null) {
          _scheduleReminder(reminder);
        }
      }

      // Check for any reminders that should have already triggered
      await _checkForMissedReminders();
    } catch (e) {
      // Log error but don't crash
      debugPrint('Error checking reminders: $e');
    }
  }

  /// Schedule a single reminder
  void _scheduleReminder(ReminderModel reminder) {
    if (reminder.id == null) return;

    // Cancel existing timer if any
    _timers[reminder.id!]?.cancel();

    final duration = reminder.getDurationUntilTrigger();

    // Don't schedule past reminders - they should be handled elsewhere
    // BUT if the reminder is active and just slightly past due (or missed), trigger it now
    if (duration == null) {
      return;
    }

    if (duration.isNegative) {
      debugPrint(
        'Triggering overdue active reminder immediately: ${reminder.name} (overdue by ${duration.abs()})',
      );
      _triggerReminder(reminder);
      return;
    }

    debugPrint(
      'Scheduling reminder: ${reminder.name} in ${duration.inMinutes} minutes',
    );

    // Schedule the timer
    _timers[reminder.id!] = Timer(duration, () {
      _triggerReminder(reminder);
    });
  }

  /// Trigger a reminder (show alert window)
  Future<void> _triggerReminder(ReminderModel reminder) async {
    try {
      // Show the alert window
      await WindowService.showAlertWindow(reminder);

      // Update next trigger time for recurring reminders
      if (reminder.isRecurring) {
        await _repository.updateNextTriggerTime(reminder);

        // Reschedule for next occurrence
        final updatedReminder = await _repository.getReminderById(reminder.id!);
        if (updatedReminder != null && updatedReminder.isActive) {
          _scheduleReminder(updatedReminder);
        }
      } else {
        // For one-time reminders, remove the timer
        _timers.remove(reminder.id);
      }
    } catch (e) {
      debugPrint('Error triggering reminder: $e');
    }
  }

  /// Check for reminders that should have triggered but were missed
  /// Only handles recurring reminders - updates their next trigger time
  Future<void> _checkForMissedReminders() async {
    try {
      final missedReminders = await _repository.getRemindersToTrigger();
      for (final reminder in missedReminders) {
        if (reminder.isRecurring && reminder.id != null) {
          // For recurring reminders, update the next trigger time without showing alert
          debugPrint('Updating missed recurring reminder: ${reminder.name}');
          await _repository.updateNextTriggerTime(reminder);
          // Reschedule for the next occurrence
          final updated = await _repository.getReminderById(reminder.id!);
          if (updated != null && updated.isActive) {
            _scheduleReminder(updated);
          }
        }
        // One-time past reminders are already deactivated in initialize()
      }
    } catch (e) {
      debugPrint('Error checking missed reminders: $e');
    }
  }

  /// Manually trigger a reminder for testing
  Future<void> triggerReminderNow(ReminderModel reminder) async {
    await _triggerReminder(reminder);
  }

  /// Cancel a specific reminder's timer
  void cancelReminder(int id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  /// Refresh scheduling for all reminders
  Future<void> refresh() async {
    await _checkAndScheduleReminders();
  }

  /// Dispose of all timers
  void dispose() {
    _checkTimer?.cancel();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _isInitialized = false;
  }
}
