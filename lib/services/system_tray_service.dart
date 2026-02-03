import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'window_service.dart';

/// Service for managing system tray integration
class SystemTrayService {
  static SystemTray? _systemTray;
  static bool _isInitialized = false;

  /// Initialize the system tray
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _systemTray = SystemTray();

      // Initialize the system tray
      await _systemTray!.initSystemTray(
        title: 'Reminder',
        iconPath: _getTrayIconPath(),
        toolTip: 'Reminder - Click to open',
      );

      // Set up the context menu
      final menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Open Reminder',
          onClicked: (menuItem) => _showMainWindow(),
        ),
        MenuSeparator(),
        MenuItemLabel(label: 'Quit', onClicked: (menuItem) => _quitApp()),
      ]);

      await _systemTray!.setContextMenu(menu);

      // Handle tray icon click
      _systemTray!.registerSystemTrayEventHandler((eventName) {
        if (eventName == kSystemTrayEventClick ||
            eventName == kSystemTrayEventRightClick) {
          _systemTray!.popUpContextMenu();
        }
      });

      _isInitialized = true;
      debugPrint('System tray initialized');
    } catch (e) {
      debugPrint('Error initializing system tray: $e');
    }
  }

  /// Get the path to the tray icon
  static String _getTrayIconPath() {
    // For Linux, we need a PNG icon
    // First, try to use an existing icon or fall back to a system icon
    if (Platform.isLinux) {
      // Try to use the app icon from assets
      final iconPath = 'assets/icons/app_icon.png';
      final file = File(iconPath);
      if (file.existsSync()) {
        return iconPath;
      }

      // Fallback to a common system icon path
      return '/usr/share/icons/hicolor/48x48/apps/gnome-calculator.png';
    }

    return '';
  }

  /// Show the main window
  static Future<void> _showMainWindow() async {
    await WindowService.restoreFromTray();
  }

  /// Quit the application
  static Future<void> _quitApp() async {
    await windowManager.setPreventClose(false);
    await windowManager.close();
    exit(0);
  }

  /// Update tray icon (e.g., for notifications)
  static Future<void> updateIcon({bool hasReminders = false}) async {
    if (!_isInitialized || _systemTray == null) return;

    try {
      // Could update icon to show notification badge
      // For now, just update the tooltip
      await _systemTray!.setToolTip(
        hasReminders
            ? 'Reminder - You have pending reminders'
            : 'Reminder - Click to open',
      );
    } catch (e) {
      debugPrint('Error updating tray icon: $e');
    }
  }

  /// Destroy the system tray
  static Future<void> destroy() async {
    if (!_isInitialized || _systemTray == null) return;

    try {
      await _systemTray!.destroy();
      _systemTray = null;
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error destroying system tray: $e');
    }
  }
}
