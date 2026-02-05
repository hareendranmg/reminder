import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reminder/services/startup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'data/models/reminder.dart';
import 'features/alert/alert_window.dart';
import 'features/settings/preferences_provider.dart';
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
      if (decoded['type'] == 'alert') {
        final reminder = ReminderModel.fromJsonString(
          decoded['data'] as String,
        );

        // Parse window ID from the controller
        final windowId = int.tryParse(windowController.windowId) ?? 0;

        // Configure alert window - always on top, non-closable
        await windowManager.setAlwaysOnTop(true);
        await windowManager.setPreventClose(true);
        await windowManager.setResizable(false);
        await windowManager.setMinimizable(false);
        await windowManager.setMaximizable(false);
        await windowManager.center();
        await windowManager.setTitle('Reminder: ${reminder.name}');

        runApp(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: AlertWindowApp(reminder: reminder, windowId: windowId),
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
