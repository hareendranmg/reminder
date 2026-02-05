import 'package:drift/drift.dart';

/// Table definition for reminders
class Reminders extends Table {
  /// Unique identifier
  IntColumn get id => integer().autoIncrement()();

  /// Reminder name/title
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Optional description
  TextColumn get description => text().nullable()();

  /// Whether this is a recurring reminder
  BoolColumn get isRecurring => boolean().withDefault(Constant(false))();

  /// Whether this reminder is sensitive (requires passcode)
  BoolColumn get isSensitive => boolean().withDefault(Constant(false))();

  /// The date and time for the reminder (or start time for recurring)
  DateTimeColumn get reminderDateTime => dateTime()();

  /// Type of recurrence (minutes, hours, days, weeks, months)
  /// Stored as string enum name
  TextColumn get recurringType => text().nullable()();

  /// Interval for recurrence (e.g., every 2 hours)
  IntColumn get recurringInterval => integer().nullable()();

  /// Next scheduled time for recurring reminders
  DateTimeColumn get nextTriggerTime => dateTime().nullable()();

  /// Whether the reminder is active
  BoolColumn get isActive => boolean().withDefault(Constant(true))();

  /// When the reminder was created
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  /// When the reminder was last modified
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
}
