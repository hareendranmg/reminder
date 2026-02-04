import 'package:flutter/material.dart';

class AlertControls extends StatelessWidget {
  final bool canDismiss;
  final VoidCallback? onSnooze;
  final VoidCallback? onDismiss;

  const AlertControls({
    super.key,
    required this.canDismiss,
    required this.onSnooze,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Snooze button
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: canDismiss ? onSnooze : null,
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
