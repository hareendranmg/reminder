import 'package:flutter/material.dart';

import '../../../../data/models/reminder.dart';

class ReminderStatusIndicator extends StatelessWidget {
  final ReminderModel reminder;
  final bool isPast;

  const ReminderStatusIndicator({
    super.key,
    required this.reminder,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
}
