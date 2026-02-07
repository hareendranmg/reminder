import 'package:flutter/material.dart';

class AlertControls extends StatelessWidget {
  final bool canDismiss;
  final ValueChanged<DateTime>? onSnooze;
  final VoidCallback? onDismiss;

  const AlertControls({
    super.key,
    required this.canDismiss,
    required this.onSnooze,
    required this.onDismiss,
  });

  Future<void> _showSnoozeMenu(BuildContext context) async {
    if (onSnooze == null) return;

    final now = DateTime.now();
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<int>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        const PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(Icons.snooze_rounded, size: 20),
              SizedBox(width: 12),
              Text('5 minutes'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 10,
          child: Row(
            children: [
              Icon(Icons.snooze_rounded, size: 20),
              SizedBox(width: 12),
              Text('10 minutes'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 30,
          child: Row(
            children: [
              Icon(Icons.snooze_rounded, size: 20),
              SizedBox(width: 12),
              Text('30 minutes'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 60,
          child: Row(
            children: [
              Icon(Icons.snooze_rounded, size: 20),
              SizedBox(width: 12),
              Text('1 hour'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: -1,
          child: Row(
            children: [
              Icon(Icons.edit_calendar_rounded, size: 20),
              SizedBox(width: 12),
              Text('Custom...'),
            ],
          ),
        ),
      ],
    );

    if (selected != null) {
      if (selected == -1) {
        if (context.mounted) {
          _pickCustomTime(context);
        }
      } else {
        onSnooze!(now.add(Duration(minutes: selected)));
      }
    }
  }

  Future<void> _pickCustomTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          now.add(const Duration(minutes: 1)),
        ),
      );

      if (!context.mounted) return;

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Ensure selected time is in future
        if (selectedDateTime.isAfter(now)) {
          onSnooze!(selectedDateTime);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please select a future time'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Snooze button
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: canDismiss ? () => _showSnoozeMenu(context) : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              child: const Text(
                'Snooze',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Dismiss button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: canDismiss ? onDismiss : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canDismiss
                        ? Icons.check_rounded
                        : Icons.hourglass_top_rounded,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    canDismiss ? 'Acknowledge' : 'Wait...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
