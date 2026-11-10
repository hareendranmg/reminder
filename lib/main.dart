import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

/// Held open for the lifetime of the main window process (Windows only) so the
/// exclusive lock on `.reminder.lock` stays in place.
RandomAccessFile? _instanceLock;

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

  // Windows single-instance guard.  Linux already has single-instance via
  // G_APPLICATION_FLAGS_NONE in the GTK runner.  Without this, a second
  // instance on Windows would create duplicate tray icons and schedulers,
  // leading to duplicate reminder alerts.
  // The guard holds an OS-level exclusive lock rather than relying on the
  // file's existence, so the OS releases it automatically if the process
  // crashes, is killed, or Windows shuts down without the tray "Exit".
  // Skipped in debug builds: a hot restart re-runs main() in the same
  // process, where the previous isolate's handle still holds the lock.
  if (Platform.isWindows && !kDebugMode) {
    final appDir = await getApplicationSupportDirectory();
    final lockFile = File(p.join(appDir.path, '.reminder.lock'));
    await lockFile.create(recursive: true);
    _instanceLock = lockFile.openSync(mode: FileMode.append);
    try {
      _instanceLock!.lockSync(FileLock.exclusive);
    } on FileSystemException {
      // Another instance holds the lock — exit silently.
      debugPrint('Another instance is already running. Exiting.');
      exit(0);
    }
  }

  await WindowService.initializeMainWindow();
  await startupService.init();
  await trayService.init();

  // Release the lock on tray "Exit" (Windows only); the OS also releases it
  // when the process ends for any other reason.
  if (Platform.isWindows) {
    trayService.onExitRequest = () async {
      try {
        _instanceLock?.unlockSync();
        _instanceLock?.closeSync();
        _instanceLock = null;
      } catch (_) {}
    };
  }

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
