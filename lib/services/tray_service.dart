import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../core/constants/app_constants.dart';

class TrayService {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  Future<void> init() async {
    String iconPath = Platform.isWindows
        ? 'assets/icons/app_icon.ico'
        : 'assets/icons/app_icon.png';

    await _systemTray.initSystemTray(
      title: AppConstants.appName,
      iconPath: iconPath,
    );

    await _menu.buildFrom([
      MenuItemLabel(
        label: 'Show',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) async {
          // Allow the window to close
          await windowManager.setPreventClose(false);
          await windowManager.close();
        },
      ),
    ]);

    await _systemTray.setContextMenu(_menu);

    // Handle left click on tray icon (restore app)
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        windowManager.show();
        windowManager.focus();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
}

final trayService = TrayService();
