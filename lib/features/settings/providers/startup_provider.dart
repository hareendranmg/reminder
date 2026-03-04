import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../services/startup_service.dart';

final startupServiceProvider = Provider<StartupService>((ref) {
  return startupService;
});

final startupProvider = StateNotifierProvider<StartupNotifier, bool>((ref) {
  final service = ref.watch(startupServiceProvider);
  return StartupNotifier(service);
});

class StartupNotifier extends StateNotifier<bool> {
  final StartupService _service;

  StartupNotifier(this._service) : super(false) {
    init();
  }

  Future<void> init() async {
    try {
      final isEnabled = await _service.isEnabled();
      state = isEnabled;
    } catch (_) {
      // Ignore errors in tests or unsupported platforms
      state = false;
    }
  }

  Future<void> toggle() async {
    try {
      await _service.toggle();
      state = await _service.isEnabled();
    } catch (_) {}
  }
}
