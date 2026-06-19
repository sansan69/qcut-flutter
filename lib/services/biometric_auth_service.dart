import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric (fingerprint / face) + device PIN authentication.
class BiometricAuthService {
  final LocalAuthentication _auth;
  BiometricAuthService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  /// Whether the device has biometric hardware and enrolled credentials.
  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// List of available biometric types (face, fingerprint, iris, etc.)
  Future<List<BiometricType>> get availableBiometrics => _auth.getAvailableBiometrics();

  /// Prompt the user to authenticate with biometrics or device PIN.
  /// Returns `true` if the user successfully authenticated.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Quick check: can we use biometrics and is it enabled by user?
  Future<bool> canAuthenticate() async {
    if (!await isAvailable) return false;
    final types = await availableBiometrics;
    return types.isNotEmpty;
  }
}
