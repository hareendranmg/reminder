import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../../services/window_service.dart';

class MissedRemindersScreen extends ConsumerWidget {
  final int windowId;
  final List<ReminderModel> missedReminders;

  const MissedRemindersScreen({
    super.key,
    required this.windowId,
    required this.missedReminders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10), // Reduced opacity
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    size: 32,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Missed Reminders',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You missed ${missedReminders.length} reminders while away',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: missedReminders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = missedReminders[index];
                final isRecurring = reminder.isRecurring;

                return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          128,
                        ), // 0.5 * 255
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withAlpha(
                            128,
                          ), // 0.5 * 255
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTime(reminder.dateTime),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                    if (isRecurring) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Recurring',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSecondaryContainer,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 50 * index))
                    .slideX(begin: 0.1, curve: Curves.easeOut);
              },
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // TODO(snooze): Implement proper snooze logic (update trigger times)
                      // For now, dismissed to avoid stuck window.
                      if (context.mounted) {
                        await _dismissAll(context, ref);
                      }
                    },
                    icon: const Icon(Icons.snooze_rounded),
                    label: const Text('Snooze All 10m'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await _dismissAll(context, ref);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Dismiss All'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday =
        now.year == dateTime.year &&
        now.month == dateTime.month &&
        now.day == dateTime.day;
    final isYesterday =
        now.difference(dateTime).inDays == 1 && now.day != dateTime.day;

    if (isToday) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (isYesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  Future<void> _dismissAll(BuildContext context, WidgetRef ref) async {
    // Logic to update next trigger times should ideally be handled by Scheduler/Caller
    // But since this is a separate window, we might need to process here.
    // However, the caller (Scheduler) already passed these as "Missed",
    // implying it likely already updated their nextTriggerTime to avoid immediate loop?
    // Wait, if we just close, they are "acknowledged".

    // Actually, SchedulerService Option 1/2 implies we update them to future *before* showing this?
    // OR we show this *instead* of triggering.
    // If we show this, the reminders are still "due".
    // We should update their nextTriggerTime here.

    final repository = ref.read(reminderRepositoryProvider);

    for (final reminder in missedReminders) {
      if (reminder.isRecurring) {
        await repository.updateNextTriggerTime(reminder);
      }
      // If one-time, toggle active false? (Already handled by logic)
    }

    if (context.mounted) {
      await WindowService.closeAlertWindow(windowId);
    }
  }
}
