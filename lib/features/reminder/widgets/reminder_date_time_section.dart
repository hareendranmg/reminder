import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'datetime_picker.dart';
import 'reminder_section_title.dart';

class ReminderDateTimeSection extends StatelessWidget {
  final bool isRecurring;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const ReminderDateTimeSection({
    super.key,
    required this.isRecurring,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      onDateChanged(date);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      onTimeChanged(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReminderSectionTitle(
          title: isRecurring ? 'Start Date & Time' : 'Date & Time',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Date picker
            Expanded(
              child: DateTimePicker(
                icon: Icons.calendar_today_rounded,
                label: DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(width: 12),
            // Time picker
            Expanded(
              child: DateTimePicker(
                icon: Icons.access_time_rounded,
                label: selectedTime.format(context),
                onTap: () => _selectTime(context),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 250.ms, duration: 200.ms);
  }
}
