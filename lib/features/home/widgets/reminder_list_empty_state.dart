import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';

class ReminderListEmptyState extends StatelessWidget {
  final ReminderFilter filter;

  const ReminderListEmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String title;
    String message;
    IconData icon;

    switch (filter) {
      case ReminderFilter.today:
        title = 'No reminders for today';
        message = 'Enjoy your free time!';
        icon = Icons.wb_sunny_rounded;
        break;
      case ReminderFilter.upcoming:
        title = 'No upcoming reminders';
        message = 'You are all caught up for now';
        icon = Icons.calendar_month_rounded;
        break;
      case ReminderFilter.past:
        title = 'No past reminders';
        message = 'History is clean';
        icon = Icons.history_rounded;
        break;
      case ReminderFilter.all:
        title = 'No reminders yet';
        message = 'Tap the + button to create your first reminder';
        icon = Icons.notifications_none_rounded;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(77),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: colorScheme.primary.withAlpha(179),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }
}
