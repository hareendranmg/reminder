import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/reminder.dart';
import '../../security/passcode_dialog.dart';
import 'reminder_status_indicator.dart';
import 'reminder_time_remaining.dart';

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

    // Check if sensitive
    final isSensitive = reminder.isSensitive;

    final isPast =
        !reminder.isRecurring && reminder.dateTime.isBefore(DateTime.now());

    return Card(
      elevation: 0,
      color: reminder.isActive
          ? colorScheme.surface
          : colorScheme.surfaceContainerHighest.withAlpha(128),
      child: InkWell(
        onTap: () async {
          if (isSensitive) {
            // Prompt for passcode
            final verified = await showDialog<bool>(
              context: context,
              builder: (context) =>
                  const PasscodeVerificationDialog(title: 'Unlock Reminder'),
            );

            if (verified == true) {
              widget.onTap?.call();
            }
          } else {
            widget.onTap?.call();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator
              ReminderStatusIndicator(reminder: reminder, isPast: isPast),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        if (isSensitive) ...[
                          Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            isSensitive ? 'Sensitive Reminder' : reminder.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: reminder.isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withAlpha(128),
                              decoration: reminder.isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                              fontStyle: isSensitive ? FontStyle.italic : null,
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
                    if (!isSensitive &&
                        reminder.description != null &&
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
                    ] else if (isSensitive) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tap to unlock',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
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
                          ReminderTimeRemaining(reminder: reminder),
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
