/// Recurring period types for reminders
enum RecurringType {
  minutes('Minutes'),
  hours('Hours'),
  days('Days'),
  weeks('Weeks'),
  months('Months');

  final String label;
  const RecurringType(this.label);
}

/// Filter options for viewing reminders
enum ReminderFilter {
  all('All Reminders'),
  today('Today'),
  upcoming('Upcoming'),
  past('Past');

  final String label;
  const ReminderFilter(this.label);
}

/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Reminder';

  // Sidebar width
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 72.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Alert window dimensions
  static const double alertWindowWidth = 420.0;
  static const double alertWindowHeight = 320.0;

  // Default intervals for recurring types
  static const Map<RecurringType, List<int>> defaultIntervals = {
    RecurringType.minutes: [5, 10, 15, 30, 45],
    RecurringType.hours: [1, 2, 3, 4, 6, 8, 12],
    RecurringType.days: [1, 2, 3, 5, 7],
    RecurringType.weeks: [1, 2, 3, 4],
    RecurringType.months: [1, 2, 3, 6],
  };
}
