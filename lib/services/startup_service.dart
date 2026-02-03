import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

class StartupService {
  // Singleton pattern
  static final StartupService _instance = StartupService._internal();
  factory StartupService() => _instance;
  StartupService._internal();

  Future<void> init() async {
    if (kIsWeb) return;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Uri.base
          .toFilePath(), // Will be updated correctly by the package for compiled apps
      packageName:
          'com.hareendranmg.reminder', // Replace if you have a specific package name
    );
  }

  Future<void> enable() async {
    await launchAtStartup.enable();
  }

  Future<void> disable() async {
    await launchAtStartup.disable();
  }

  Future<bool> isEnabled() async {
    return await launchAtStartup.isEnabled();
  }

  Future<void> toggle() async {
    bool enabled = await isEnabled();
    if (enabled) {
      await disable();
    } else {
      await enable();
    }
  }
}

final startupService = StartupService();
