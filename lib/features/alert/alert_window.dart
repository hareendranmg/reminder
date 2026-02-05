import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/app_theme.dart';
import '../../data/constants/quotes.dart';
import '../../data/models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../services/window_service.dart';
import '../security/passcode_dialog.dart';
import 'widgets/alert_animated_icon.dart';
import 'widgets/alert_controls.dart';
import 'widgets/alert_quote.dart';
import 'widgets/alert_time_info.dart';

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
  late Map<String, String> _quote;
  bool _canDismiss = false;
  late bool _isLocked;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.reminder.isSensitive;
    _quote = motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
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

  Future<void> _unlockReminder() async {
    final verified = await showDialog<bool>(
      context: context,
      builder: (context) =>
          const PasscodeVerificationDialog(title: 'Unlock Reminder'),
    );

    if (verified == true && mounted) {
      setState(() => _isLocked = false);
    }
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
                // Animated icon (Lock or Bell)
                if (_isLocked)
                  Icon(Icons.lock_rounded, size: 80, color: colorScheme.primary)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration: 1500.ms,
                      )
                else
                  AlertAnimatedIcon(animation: _pulseController)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.5, 0.5)),

                const SizedBox(height: 24),

                // Reminder title
                Text(
                  _isLocked ? 'Sensitive Reminder' : widget.reminder.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontStyle: _isLocked ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 12),

                // Description or Unlock Prompt
                if (_isLocked)
                  FilledButton.icon(
                    onPressed: _unlockReminder,
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Unlock to View'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms)
                else if (widget.reminder.description != null &&
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
                const AlertTimeInfo().animate().fadeIn(
                  delay: 300.ms,
                  duration: 300.ms,
                ),

                const SizedBox(height: 24),

                // Motivational Quote (hide if locked?) -> Maybe keep it, it's nice.
                AlertQuote(
                  quote: _quote,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                const SizedBox(height: 24),

                // Dismiss button
                AlertControls(
                      canDismiss: _canDismiss,
                      onSnooze: _snoozeReminder,
                      onDismiss: _dismissReminder,
                    )
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
}
