import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../reminder/create_reminder_screen.dart';
import 'reminder_card.dart';

class ReminderList extends ConsumerWidget {
  const ReminderList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(filteredRemindersProvider);
    final filter = ref.watch(reminderFilterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return _buildEmptyState(context, filter);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  ReminderCard(
                        reminder: reminder,
                        onTap: () =>
                            _showReminderDetails(context, ref, reminder),

                        onToggle: (isActive) =>
                            _toggleReminder(ref, reminder, isActive),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 50 * index),
                        duration: const Duration(milliseconds: 300),
                      )
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        delay: Duration(milliseconds: 50 * index),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      ),
            );
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReminderFilter filter) {
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

  void _showReminderDetails(
    BuildContext context,
    WidgetRef ref,
    ReminderModel reminder,
  ) {
    ref.read(selectedReminderProvider.notifier).state = reminder;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: CreateReminderScreen(
            isDialog: true,
            editingReminder: reminder,
          ),
        ),
      ),
    );
  }

  void _toggleReminder(WidgetRef ref, ReminderModel reminder, bool isActive) {
    if (reminder.id != null) {
      ref
          .read(reminderActionsProvider.notifier)
          .toggleActive(reminder.id!, isActive);
    }
  }
}
