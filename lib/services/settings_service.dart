import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {

  static const String _pinLockKey = 'pinLockEnabled';
  static Future<bool> get pinLockEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinLockKey) ?? true;
  }
  static Future<void> setPinLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinLockKey, value);
  }


  static const String _autoLockKey = 'autoLockEnabled';
  static Future<bool> get autoLockEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLockKey) ?? true;
  }
  static Future<void> setAutoLockEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLockKey, value);
  }
}
