import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences_provider.dart';

/// Passcode provider
final passcodeProvider = NotifierProvider<PasscodeNotifier, String?>(
  PasscodeNotifier.new,
);

class PasscodeNotifier extends Notifier<String?> {
  late SharedPreferences _prefs;
  static const String _key = 'security_passcode';
  static const String fallbackPasscode = 'TringTring';

  @override
  String? build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _prefs.getString(_key);
  }

  /// Check if a passcode is currently set
  bool get hasPasscode => state != null && state!.isNotEmpty;

  /// Set a new passcode
  Future<void> setPasscode(String passcode) async {
    if (passcode.isEmpty) return;
    state = passcode;
    await _prefs.setString(_key, passcode);
  }

  /// Remove passcode (not currently exposed in UI, but useful logic)
  Future<void> removePasscode() async {
    state = null;
    await _prefs.remove(_key);
  }

  /// Verify input against stored passcode or fallback
  bool verify(String input) {
    if (!hasPasscode) return true; // No passcode = always valid
    return input == state || input == fallbackPasscode;
  }
}
