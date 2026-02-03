import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../services/window_service.dart';

class AlertWindowApp extends StatelessWidget {
  final ReminderModel reminder;
  final int windowId;

  const AlertWindowApp({
    super.key,
    required this.reminder,
    required this.windowId,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder Alert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AlertWindowScreen(reminder: reminder, windowId: windowId),
    );
  }
}

class AlertWindowScreen extends ConsumerStatefulWidget {
  final ReminderModel reminder;
  final int windowId;

  const AlertWindowScreen({
    super.key,
    required this.reminder,
    required this.windowId,
  });

  @override
  ConsumerState<AlertWindowScreen> createState() => _AlertWindowScreenState();
}

class _AlertWindowScreenState extends ConsumerState<AlertWindowScreen>
    with WindowListener, SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Allow dismiss after a short delay (ensures user sees the reminder)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _canDismiss = true);
      }
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() {
    // Prevent close unless explicitly allowed
  }

  void _dismissReminder() async {
    if (!_canDismiss) return;
    await WindowService.closeAlertWindow(widget.windowId);
  }

  void _snoozeReminder() async {
    if (!_canDismiss) return;

    // Calculate new time (10 minutes from now)
    final snoozeTime = DateTime.now().add(const Duration(minutes: 10));

    // Update reminder in database
    ReminderModel updatedReminder;

    if (widget.reminder.isRecurring) {
      updatedReminder = widget.reminder.copyWith(nextTriggerTime: snoozeTime);
    } else {
      updatedReminder = widget.reminder.copyWith(dateTime: snoozeTime);
    }

    // We can use the global container here because we wrapped the app in ProviderScope
    await ref.read(reminderRepositoryProvider).updateReminder(updatedReminder);

    // Close the window
    await WindowService.closeAlertWindow(widget.windowId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withAlpha(77),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Animated bell icon
                _buildAnimatedIcon(context)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.5, 0.5)),

                const SizedBox(height: 24),

                // Reminder title
                Text(
                      widget.reminder.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 300.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 12),

                // Description if present
                if (widget.reminder.description != null &&
                    widget.reminder.description!.isNotEmpty)
                  Text(
                        widget.reminder.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 300.ms)
                      .slideY(begin: 0.2),

                const Spacer(),

                // Time info
                _buildTimeInfo(
                  context,
                ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                const SizedBox(height: 24),

                // Dismiss button
                _buildDismissButton(context)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 300.ms)
                    .slideY(begin: 0.3),

                const SizedBox(height: 8),

                // Hint text
                AnimatedOpacity(
                  opacity: _canDismiss ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'Please wait...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withAlpha(153),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.1);
        final opacity = 0.3 + (_pulseController.value * 0.3);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Transform.scale(
              scale: scale * 1.4,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withAlpha(
                    (opacity * 0.3 * 255).toInt(),
                  ),
                ),
              ),
            ),
            // Inner pulse ring
            Transform.scale(
              scale: scale * 1.2,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withAlpha(
                    (opacity * 0.5 * 255).toInt(),
                  ),
                ),
              ),
            ),
            // Icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(77),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            DateFormat('h:mm a').format(now),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('EEE, MMM d').format(now),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return Row(
      children: [
        // Snooze button
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _canDismiss ? _snoozeReminder : null,
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
              onPressed: _canDismiss ? _dismissReminder : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _canDismiss
                        ? Icons.check_rounded
                        : Icons.hourglass_top_rounded,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _canDismiss ? 'Access' : 'Wait...',
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
