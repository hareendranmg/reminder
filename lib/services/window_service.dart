import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import '../core/constants/app_constants.dart';
import '../data/models/reminder.dart';

/// Service for managing windows
abstract class WindowService {
  WindowService._();
  static const String _alertWindowArg = 'alert';
  static const String _summaryWindowArg = 'summary';

  /// Initialize the main window
  static Future<void> initializeMainWindow() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Color(0x00000000),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: AppConstants.appName,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Show an alert window for a reminder
  static Future<void> showAlertWindow(ReminderModel reminder) async {
    try {
      final reminderJson = reminder.toJsonString();

      // Create a new window with the reminder data
      // The alert window will configure itself via main.dart when it starts
      final window = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({
            'type': _alertWindowArg,
            'data': reminderJson,
          }),
        ),
      );

      // Show the window
      await window.show();
    } catch (e) {
      debugPrint('Error creating alert window: $e');
    }
  }

  /// Show a summary window for missed reminders
  static Future<void> showSummaryWindow(List<ReminderModel> reminders) async {
    try {
      final remindersJson = jsonEncode(
        reminders.map((r) => r.toJson()).toList(),
      );

      final window = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({
            'type': _summaryWindowArg,
            'data': remindersJson,
          }),
        ),
      );

      await window.show();
    } catch (e) {
      debugPrint('Error creating summary window: $e');
    }
  }

  /// Initialize an alert/summary window
  static Future<void> initializeSubWindow(int windowId) async {
    await windowManager.ensureInitialized();
    // Specific config can be done based on window type if needed,
    // but general "on top" is good for both initially.
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
  }

  /// Parse window arguments
  static Map<String, dynamic>? parseWindowArgs(String args) {
    // ... implementation depends on how main.dart passes args.
    // If we use invokeMethod, we might not need this if we listen to method calls.
    // But preserving existing pattern:
    try {
      // ...
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Initialize an alert window (called from alert window's main)
  static Future<void> initializeAlertWindow(int windowId) async {
    await windowManager.ensureInitialized();

    // Configure the window to be always on top and prevent close
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setPreventClose(true);
    await windowManager.setResizable(false);
    await windowManager.setMinimizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setSkipTaskbar(false);
  }

  /// Close the alert window (called when user acknowledges)
  static Future<void> closeAlertWindow(int windowId) async {
    try {
      // Allow close
      await windowManager.setPreventClose(false);

      // Hide window first to hopefully prevent "last window closed" app termination
      await windowManager.hide();

      // Instead of closing natively (which crashes GL context when main is hidden),
      // we kill the isolate. This stops the engine cleanly enough for this use case.
      Isolate.current.kill(priority: Isolate.immediate);
    } catch (e) {
      debugPrint('Error closing alert window: $e');
    }
  }

  /// Parse window arguments to get reminder data
  static ReminderModel? parseAlertWindowArgs(String args) {
    try {
      final decoded = jsonDecode(args) as Map<String, dynamic>;
      if (decoded['type'] == _alertWindowArg) {
        return ReminderModel.fromJsonString(decoded['data'] as String);
      }
    } catch (e) {
      debugPrint('Error parsing alert window args: $e');
    }
    return null;
  }

  /// Check if running as alert window
  static bool isAlertWindow(List<String> args) {
    if (args.isEmpty) return false;
    try {
      final decoded = jsonDecode(args.first) as Map<String, dynamic>;
      return decoded['type'] == _alertWindowArg;
    } catch (e) {
      return false;
    }
  }

  /// Check if running as summary window
  static bool isSummaryWindow(List<String> args) {
    if (args.isEmpty) return false;
    try {
      final decoded = jsonDecode(args.first) as Map<String, dynamic>;
      return decoded['type'] == _summaryWindowArg;
    } catch (e) {
      return false;
    }
  }

  /// Get missed reminders from args
  static List<ReminderModel> parseSummaryWindowArgs(String args) {
    try {
      final decoded = jsonDecode(args) as Map<String, dynamic>;
      if (decoded['type'] == _summaryWindowArg) {
        final list = jsonDecode(decoded['data'] as String) as List;
        return list.map((e) => ReminderModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error parsing summary window args: $e');
    }
    return [];
  }

  /// Minimize main window to tray
  static Future<void> minimizeToTray() async {
    await windowManager.hide();
  }

  /// Restore main window from tray
  static Future<void> restoreFromTray() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// Check if main window is visible
  static Future<bool> isVisible() => windowManager.isVisible();
}
