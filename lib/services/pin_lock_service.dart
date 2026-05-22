import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinLockService {
  static const _pinKey = 'cs_vault_pin';
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<bool> hasPin() async {
    return await _secure.containsKey(key: _pinKey);
  }

  Future<void> setPin(String pin) async {
  
    await _secure.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secure.read(key: _pinKey);
    return stored != null && stored == pin;
  }

  Future<void> clearPin() async {
    await _secure.delete(key: _pinKey);
  }
}