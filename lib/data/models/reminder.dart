import 'dart:convert';

import '../../core/constants/app_constants.dart';
import '../database/app_database.dart' as db;

/// Reminder model for use throughout the app
class ReminderModel {
  final int? id;
  final String name;
  final String? description;
  final bool isRecurring;
  final bool isSensitive;
  final DateTime dateTime;
  final RecurringType? recurringType;
  final int? recurringInterval;
  final DateTime? nextTriggerTime;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReminderModel({
    this.id,
    required this.name,
    this.description,
    this.isRecurring = false,
    this.isSensitive = false,
    required this.dateTime,
    this.recurringType,
    this.recurringInterval,
    this.nextTriggerTime,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from database entity
  factory ReminderModel.fromDbEntity(db.Reminder entity) {
    RecurringType? recurringType;
    if (entity.recurringType != null) {
      recurringType = RecurringType.values.firstWhere(
        (e) => e.name == entity.recurringType,
        orElse: () => RecurringType.days,
      );
    }

    return ReminderModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isRecurring: entity.isRecurring, // Drift generated code handles defaults
      isSensitive: entity.isSensitive, // Drift generated code handles defaults
      dateTime: entity.reminderDateTime,
      recurringType: recurringType,
      recurringInterval: entity.recurringInterval,
      nextTriggerTime: entity.nextTriggerTime,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create from JSON (for multi-window communication)
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    RecurringType? recurringType;
    if (json['recurringType'] != null) {
      recurringType = RecurringType.values.firstWhere(
        (e) => e.name == json['recurringType'],
        orElse: () => RecurringType.days,
      );
    }

    return ReminderModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      isSensitive: json['isSensitive'] as bool? ?? false,
      dateTime: DateTime.parse(json['dateTime'] as String),
      recurringType: recurringType,
      recurringInterval: json['recurringInterval'] as int?,
      nextTriggerTime: json['nextTriggerTime'] != null
          ? DateTime.parse(json['nextTriggerTime'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isRecurring': isRecurring,
      'isSensitive': isSensitive,
      'dateTime': dateTime.toIso8601String(),
      'recurringType': recurringType?.name,
      'recurringInterval': recurringInterval,
      'nextTriggerTime': nextTriggerTime?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Encode to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Decode from JSON string
  static ReminderModel fromJsonString(String jsonString) {
    return ReminderModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Calculate next trigger time for recurring reminders.
  /// Always uses [dateTime] (original schedule) as the anchor, not [nextTriggerTime],
  /// so that after a snooze the next occurrence stays on the intended schedule
  /// (e.g. 9:00 -> snooze to 9:10 -> acknowledge -> next at 10:00, not 10:10).
  DateTime calculateNextTriggerTime([DateTime? fromTime]) {
    final baseTime = fromTime ?? DateTime.now();

    if (!isRecurring || recurringType == null || recurringInterval == null) {
      return dateTime;
    }

    // Use original schedule anchor so snooze does not shift the recurrence.
    DateTime nextTime = dateTime;

    // Keep adding intervals until we're in the future
    while (nextTime.isBefore(baseTime) || nextTime.isAtSameMomentAs(baseTime)) {
      switch (recurringType!) {
        case RecurringType.minutes:
          nextTime = nextTime.add(Duration(minutes: recurringInterval!));
          break;
        case RecurringType.hours:
          nextTime = nextTime.add(Duration(hours: recurringInterval!));
          break;
        case RecurringType.days:
          nextTime = nextTime.add(Duration(days: recurringInterval!));
          break;
        case RecurringType.weeks:
          nextTime = nextTime.add(Duration(days: recurringInterval! * 7));
          break;
        case RecurringType.months:
          nextTime = _addMonths(nextTime, recurringInterval!);
          break;
      }
    }

    return nextTime;
  }

  /// Add months to a DateTime, handling edge cases
  DateTime _addMonths(DateTime date, int months) {
    int newMonth = date.month + months;
    int newYear = date.year;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }

    // Handle month-end edge cases (e.g., Jan 31 + 1 month = Feb 28/29)
    int maxDay = DateTime(newYear, newMonth + 1, 0).day;
    int newDay = date.day > maxDay ? maxDay : date.day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
    );
  }

  /// Get duration until next trigger
  Duration? getDurationUntilTrigger() {
    final triggerTime = isRecurring ? (nextTriggerTime ?? dateTime) : dateTime;
    final now = DateTime.now();

    if (triggerTime.isBefore(now)) {
      return null;
    }

    return triggerTime.difference(now);
  }

  /// Check if reminder should trigger now
  bool shouldTriggerNow() {
    final triggerTime = isRecurring ? (nextTriggerTime ?? dateTime) : dateTime;
    final now = DateTime.now();

    return isActive &&
        (triggerTime.isBefore(now) || triggerTime.isAtSameMomentAs(now));
  }

  /// Create a copy with optional changes
  ReminderModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isRecurring,
    bool? isSensitive,
    DateTime? dateTime,
    RecurringType? recurringType,
    int? recurringInterval,
    DateTime? nextTriggerTime,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      isSensitive: isSensitive ?? this.isSensitive,
      dateTime: dateTime ?? this.dateTime,
      recurringType: recurringType ?? this.recurringType,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextTriggerTime: nextTriggerTime ?? this.nextTriggerTime,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReminderModel(id: $id, name: $name, isRecurring: $isRecurring, isSensitive: $isSensitive, dateTime: $dateTime)';
  }
}
