import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences_provider.dart';

final soundEnabledProvider = StateNotifierProvider<SoundEnabledNotifier, bool>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SoundEnabledNotifier(prefs);
});

class SoundEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'sound_enabled';

  SoundEnabledNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_key, enabled);
    state = enabled;
  }

  Future<void> toggle() async {
    await setSoundEnabled(!state);
  }
}
