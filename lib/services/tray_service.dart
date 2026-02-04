import 'dart:io';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'window_service.dart';

class TrayService with TrayListener {
  static final TrayService _instance = TrayService._internal();

  factory TrayService() {
    return _instance;
  }

  TrayService._internal();

  Future<void> init() async {
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/icons/app_icon.ico'
          : 'assets/icons/app_icon.png',
    );
    await _updateContextMenu();
    trayManager.addListener(this);
  }

  Future<void> _updateContextMenu({String? nextReminderText}) async {
    List<MenuItem> items = [
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

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'add_reminder':
        await WindowService.restoreFromTray();
        // TODO: Navigate to add reminder screen if possible
        break;
      case 'show_window':
        await WindowService.restoreFromTray();
        break;
      case 'exit_app':
        await windowManager.destroy();
        exit(0);
    }
  }

  void dispose() {
    trayManager.removeListener(this);
  }
}

final trayService = TrayService();
