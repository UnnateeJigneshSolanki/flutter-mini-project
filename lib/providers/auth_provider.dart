import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _vaultUnlocked = false;
  bool _pinSet = false;
  bool get vaultUnlocked => _vaultUnlocked;
  bool get pinSet => _pinSet;
  void unlockVaultAfterAuth() {
    _vaultUnlocked = true;
    notifyListeners();
  }
  void lockVault() {
    if (_vaultUnlocked) {
      _vaultUnlocked = false;
      notifyListeners();
    }
  }
  void setPinSet(bool value) {
    _pinSet = value;
    notifyListeners();
  }
  void forceLock() {
    _vaultUnlocked = false;
    notifyListeners();
  }
}
