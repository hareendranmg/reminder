import 'package:flutter/material.dart';

import '../../../../data/models/reminder.dart';

class ReminderTimeRemaining extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderTimeRemaining({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
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
}
