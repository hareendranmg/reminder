import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'window_service.dart';

class TrayService with TrayListener {
  static final TrayService _instance = TrayService._internal();

  factory TrayService() {
    return _instance;
  }

  TrayService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Resolve icon path relative to the executable so it works in both
    // debug builds (where CWD == project root) and installed/release
    // bundles (where CWD is typically the user's home directory).
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final iconPath = Platform.isWindows
        ? p.join(
            exeDir,
            'data',
            'flutter_assets',
            'assets',
            'icons',
            'app_icon.ico',
          )
        : p.join(
            exeDir,
            'data',
            'flutter_assets',
            'assets',
            'icons',
            'app_icon.png',
          );
    await trayManager.setIcon(iconPath);
    await _updateContextMenu();
    trayManager.addListener(this);
  }

  Future<void> _updateContextMenu({String? nextReminderText}) async {
    final items = [
      MenuItem(
        key: 'next_reminder',
        label: nextReminderText ?? 'Next: None',
        disabled: true,
      ),
      MenuItem.separator(),
      MenuItem(key: 'add_reminder', label: 'Add Reminder'),
      MenuItem(key: 'show_window', label: 'Show Window'),
      MenuItem.separator(),
      MenuItem(key: 'exit_app', label: 'Exit'),
    ];
    await trayManager.setContextMenu(Menu(items: items));
  }

  Future<void> updateNextReminder(String text) async {
    await _updateContextMenu(nextReminderText: text);
  }

  @override
  void onTrayIconMouseDown() {
    WindowService.restoreFromTray();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  void Function()? onAddReminderRequest;

  /// Called when the user selects Exit from the tray menu.
  /// Use this to run platform-specific cleanup (e.g. deleting lock files).
  Future<void> Function()? onExitRequest;

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    _handleTrayMenuItemClick(menuItem);
  }

  Future<void> _handleTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'add_reminder':
        await WindowService.restoreFromTray();
        onAddReminderRequest?.call();
        break;
      case 'show_window':
        await WindowService.restoreFromTray();
        break;
      case 'exit_app':
        // Gracefully tear down tray and window instead of hard exit(0),
        // which would skip Flutter disposal (database flush, provider
        // cleanup, etc.) and risk data corruption.
        await onExitRequest?.call();
        trayManager.removeListener(this);
        await trayManager.destroy();
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
    }
  }

  void dispose() {
    trayManager.removeListener(this);
  }
}

final trayService = TrayService();
