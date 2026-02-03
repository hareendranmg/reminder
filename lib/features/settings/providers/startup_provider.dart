import 'package:flutter_riverpod/legacy.dart';

import '../../../../services/startup_service.dart';

final startupProvider = StateNotifierProvider<StartupNotifier, bool>((ref) {
  return StartupNotifier();
});

class StartupNotifier extends StateNotifier<bool> {
  StartupNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    final isEnabled = await startupService.isEnabled();
    state = isEnabled;
  }

  Future<void> toggle() async {
    await startupService.toggle();
    state = await startupService.isEnabled();
  }
}
