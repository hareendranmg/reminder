import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReminderRecurringToggle extends StatelessWidget {
  final bool isRecurring;
  final ValueChanged<bool> onToggle;

  const ReminderRecurringToggle({
    super.key,
    required this.isRecurring,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecurring
              ? colorScheme.primary.withAlpha(128)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isRecurring
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isRecurring ? Icons.repeat_rounded : Icons.looks_one_rounded,
              color: isRecurring
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRecurring ? 'Recurring' : 'One-time',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isRecurring
                      ? 'Repeats at a regular interval'
                      : 'Triggers once at the scheduled time',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: isRecurring, onChanged: onToggle),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 200.ms);
  }
}
