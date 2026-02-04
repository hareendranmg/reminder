import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../services/tray_service.dart';

class TrayListener extends ConsumerWidget {
  final Widget child;

  const TrayListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<ReminderModel>>>(activeRemindersProvider, (
      previous,
      next,
    ) {
      next.whenData((reminders) {
        _updateTray(reminders);
      });
    });

    return child;
  }

  void _updateTray(List<ReminderModel> reminders) {
    final now = DateTime.now();

    // Filter for future reminders
    final futureReminders = reminders.where((r) {
      final triggerTime = r.nextTriggerTime ?? r.dateTime;
      return triggerTime.isAfter(now);
    }).toList();

    // Sort by time
    futureReminders.sort((a, b) {
      final timeA = a.nextTriggerTime ?? a.dateTime;
      final timeB = b.nextTriggerTime ?? b.dateTime;
      return timeA.compareTo(timeB);
    });

    if (futureReminders.isNotEmpty) {
      final next = futureReminders.first;
      final time = next.nextTriggerTime ?? next.dateTime;

      String timeString, remainingTime;
      if (time.day == now.day &&
          time.month == now.month &&
          time.year == now.year) {
        timeString = DateFormat('h:mm a').format(time);
        remainingTime = time.difference(now).inMinutes.toString();
      } else {
        timeString = DateFormat('EEE, h:mm a').format(time);
        remainingTime = time.difference(now).inHours.toString();
      }

      trayService.updateNextReminder(
        'Next: ${next.name} ($timeString, $remainingTime)',
      );
    } else {
      trayService.updateNextReminder('Next: None');
    }
  }
}
