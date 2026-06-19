import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores sensitive data (credentials, tokens) securely using platform keychain /
/// KeyStore. Data survives app uninstall only if backed up to the cloud by the OS.
class SecureStorageService {
  static const _keyEmail = 'qcut_email';
  static const _keyPassword = 'qcut_password';
  static const _keyRemember = 'qcut_remember_me';
  static const _keyFcmToken = 'qcut_fcm_token';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device),
            );

  // ── Credentials ──

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyRemember, value: 'true');
  }

  Future<({String email, String password})?> getCredentials() async {
    final remember = await _storage.read(key: _keyRemember);
    if (remember != 'true') return null;
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyRemember);
  }

  Future<bool> isRemembered() async {
    final v = await _storage.read(key: _keyRemember);
    return v == 'true';
  }

  // ── FCM Token ──

  Future<void> saveFcmToken(String token) =>
      _storage.write(key: _keyFcmToken, value: token);

  Future<String?> getFcmToken() => _storage.read(key: _keyFcmToken);

  Future<void> clearFcmToken() => _storage.delete(key: _keyFcmToken);

  // ── Generic ──

  Future<void> clearAll() => _storage.deleteAll();
}
