import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate(String reason) async {
    try {
     
      final bool isSupported = await _auth.isDeviceSupported();
      final bool canCheck = await _auth.canCheckBiometrics;
      if (!isSupported || !canCheck) {
        return false;
      }

      
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
      );

      return didAuthenticate;
    } on PlatformException {
      return false;
    }
  }
}