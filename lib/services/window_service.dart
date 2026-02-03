import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import '../core/constants/app_constants.dart';
import '../data/models/reminder.dart';

/// Service for managing windows
class WindowService {
  static const String _alertWindowArg = 'alert';

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
      // The alert window will configure itself via window_manager when it starts
      final window = await WindowController.create(
        WindowConfiguration(
          hiddenAtLaunch: false,
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
      // Fallback: could show a system notification instead
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
  static Future<bool> isVisible() async {
    return await windowManager.isVisible();
  }
}
