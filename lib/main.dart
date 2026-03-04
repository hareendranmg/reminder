import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'data/models/reminder.dart';
import 'features/alert/alert_window.dart';
import 'features/alert/missed_reminders_screen.dart';
import 'features/settings/preferences_provider.dart';
import 'services/startup_service.dart';
import 'services/tray_service.dart';
import 'services/window_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Get the window controller to determine window type
  final windowController = await WindowController.fromCurrentEngine();
  final windowArgs = windowController.arguments;

  debugPrint('Window ID: ${windowController.windowId}, Args: "$windowArgs"');

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Check if this is a sub-window (alert window) by checking arguments
  if (windowArgs.isNotEmpty) {
    try {
      final decoded = jsonDecode(windowArgs) as Map<String, dynamic>;
      final type = decoded['type'];
      final windowId = int.tryParse(windowController.windowId) ?? 0;

      if (type == 'alert') {
        final reminder = ReminderModel.fromJsonString(
          decoded['data'] as String,
        );

        // Configure alert window
        await _configureWindow(
          title: reminder.isSensitive
              ? 'Sensitive Reminder'
              : 'Reminder: ${reminder.name}',
          width: 420,
          height: 380,
          isResizable: false,
        );

        runApp(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: AlertWindowApp(reminder: reminder, windowId: windowId),
          ),
        );
        return;
      } else if (type == 'summary') {
        final List<dynamic> data = jsonDecode(decoded['data'] as String);
        final reminders = data
            .map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
            .toList();

        await _configureWindow(
          title: 'Missed Reminders',
          width: 500,
          height: 600,
        );

        runApp(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: Consumer(
              builder: (context, ref, _) {
                final themeMode = ref.watch(themeModeProvider);
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Missed Reminders',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  home: MissedRemindersScreen(
                    windowId: windowId,
                    missedReminders: reminders,
                  ),
                );
              },
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Error parsing window args: $e');
    }
  }

  // Main window initialization - only reaches here if no valid sub-window args
  await WindowService.initializeMainWindow();
  await startupService.init();
  await trayService.init();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ReminderApp(),
    ),
  );
}

Future<void> _configureWindow({
  required String title,
  double width = 800,
  double height = 600,
  bool isResizable = true,
}) async {
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setPreventClose(true);
  await windowManager.setSkipTaskbar(false);
  await windowManager.setTitle(title);
  await windowManager.setResizable(isResizable);
  if (!isResizable) {
    await windowManager.setMinimizable(false);
    await windowManager.setMaximizable(false);
  }

  await windowManager.setSize(Size(width, height));
  await windowManager.center();
}
