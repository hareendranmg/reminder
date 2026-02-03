import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/reminder.dart';

class ReminderCard extends StatefulWidget {
  final ReminderModel reminder;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onToggle,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reminder = widget.reminder;

    final isPast =
        !reminder.isRecurring && reminder.dateTime.isBefore(DateTime.now());

    return Card(
      elevation: 0,
      color: reminder.isActive
          ? colorScheme.surface
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              _buildStatusIndicator(context, isPast),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            reminder.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: reminder.isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withAlpha(128),
                              decoration: reminder.isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (reminder.isRecurring)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.repeat_rounded,
                                  size: 14,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getRecurringText(reminder),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Description
                    if (reminder.description != null &&
                        reminder.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        reminder.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Date/time row
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: isPast
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDateTime(reminder),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isPast
                                ? colorScheme.error
                                : colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),

                        // Time remaining
                        if (!isPast && reminder.isActive)
                          _buildTimeRemaining(context, reminder),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Actions
              Switch(value: reminder.isActive, onChanged: widget.onToggle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, bool isPast) {
    final colorScheme = Theme.of(context).colorScheme;
    final reminder = widget.reminder;

    Color indicatorColor;
    IconData indicatorIcon;

    if (!reminder.isActive) {
      indicatorColor = colorScheme.outline;
      indicatorIcon = Icons.pause_rounded;
    } else if (isPast) {
      indicatorColor = colorScheme.error;
      indicatorIcon = Icons.warning_rounded;
    } else if (reminder.isRecurring) {
      indicatorColor = colorScheme.tertiary;
      indicatorIcon = Icons.repeat_rounded;
    } else {
      indicatorColor = colorScheme.primary;
      indicatorIcon = Icons.notifications_active_rounded;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: indicatorColor.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(indicatorIcon, color: indicatorColor, size: 24),
    );
  }

  Widget _buildTimeRemaining(BuildContext context, ReminderModel reminder) {
    final colorScheme = Theme.of(context).colorScheme;
    final duration = reminder.getDurationUntilTrigger();

    if (duration == null) return const SizedBox.shrink();

    String text;
    if (duration.inDays > 0) {
      text = '${duration.inDays}d left';
    } else if (duration.inHours > 0) {
      text = '${duration.inHours}h left';
    } else if (duration.inMinutes > 0) {
      text = '${duration.inMinutes}m left';
    } else {
      text = 'Soon';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDateTime(ReminderModel reminder) {
    final dateTime = reminder.isRecurring
        ? (reminder.nextTriggerTime ?? reminder.dateTime)
        : reminder.dateTime;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (reminderDate == today) {
      dateStr = 'Today';
    } else if (reminderDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else if (dateTime.year == now.year) {
      dateStr = DateFormat('MMM d').format(dateTime);
    } else {
      dateStr = DateFormat('MMM d, yyyy').format(dateTime);
    }

    final timeStr = DateFormat('h:mm a').format(dateTime);
    return '$dateStr at $timeStr';
  }

  String _getRecurringText(ReminderModel reminder) {
    if (reminder.recurringType == null || reminder.recurringInterval == null) {
      return 'Recurring';
    }

    final interval = reminder.recurringInterval!;
    final type = reminder.recurringType!;

    if (interval == 1) {
      return 'Every ${type.label.toLowerCase().substring(0, type.label.length - 1)}';
    }
    return 'Every $interval ${type.label.toLowerCase()}';
  }
}
