import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'window_service.dart';

class TrayService {
  static final TrayService _instance = TrayService._internal();

  factory TrayService() {
    return _instance;
  }

  TrayService._internal();

  bool _isInitialized = false;

  // Native wrappers release their handle when garbage-collected, which would
  // remove the icon, so keep references for as long as the tray is shown.
  TrayIcon? _trayIcon;
  Menu? _menu;
  MenuItem? _nextReminderItem;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final trayIcon = TrayIcon.create();
    if (trayIcon == null) {
      debugPrint('Tray icon is not supported on this platform.');
      return;
    }
    _trayIcon = trayIcon;

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
    trayIcon.icon = Image.fromFile(iconPath);

    _menu = _buildContextMenu();
    trayIcon
      ..setContextMenu(_menu)
      ..setContextMenuTrigger(ContextMenuTrigger.rightClicked)
      ..addListener((event) {
        if (event is TrayIconClickedEvent) {
          WindowService.restoreFromTray();
        }
      })
      ..setVisible(true);
  }

  Menu? _buildContextMenu() {
    final menu = Menu.create();
    if (menu == null) return null;

    _nextReminderItem = MenuItem.createWithLabelAndType(
      'Next: None',
      MenuItemType.normal,
    )?..isEnabled = false;
    menu
      ..addItem(_nextReminderItem)
      ..addSeparator()
      ..addItem(_menuItem('Add Reminder', _onAddReminder))
      ..addItem(_menuItem('Show Window', WindowService.restoreFromTray))
      ..addSeparator()
      ..addItem(_menuItem('Exit', _onExit));
    return menu;
  }

  MenuItem? _menuItem(String label, Future<void> Function() onClick) {
    return MenuItem.createWithLabelAndType(label, MenuItemType.normal)
      ?..addListener((event) {
        if (event is MenuItemClickedEvent) {
          onClick();
        }
      });
  }

  Future<void> updateNextReminder(String text) async {
    // Assigning the label updates the visible menu in place.
    _nextReminderItem?.label = text;
  }

  void Function()? onAddReminderRequest;

  /// Called when the user selects Exit from the tray menu.
  /// Use this to run platform-specific cleanup (e.g. releasing locks).
  Future<void> Function()? onExitRequest;

  Future<void> _onAddReminder() async {
    await WindowService.restoreFromTray();
    onAddReminderRequest?.call();
  }

  Future<void> _onExit() async {
    // Gracefully tear down tray and window instead of hard exit(0),
    // which would skip Flutter disposal (database flush, provider
    // cleanup, etc.) and risk data corruption.
    await onExitRequest?.call();
    dispose();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  void dispose() {
    _trayIcon?.dispose();
    _trayIcon = null;
    _menu = null;
    _nextReminderItem = null;
  }
}

final trayService = TrayService();
