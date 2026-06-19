import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive app preferences. For credentials / tokens use [SecureStorageService].
class PreferencesService {
  static const _keyLocale = 'qcut_locale';
  static const _keyLastEmail = 'qcut_last_email';
  static const _keyBiometricEnabled = 'qcut_biometric_enabled';
  static const _keyOnboardingCompleted = 'qcut_onboarding_done';
  static const _keyThemeMode = 'qcut_theme_mode';

  final SharedPreferences _prefs;
  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // ── Last used email (non-sensitive, for autofill hint) ──
  String? get lastEmail => _prefs.getString(_keyLastEmail);
  Future<bool> setLastEmail(String email) => _prefs.setString(_keyLastEmail, email);

  // ── Biometric auth ──
  bool get biometricEnabled => _prefs.getBool(_keyBiometricEnabled) ?? false;
  Future<bool> setBiometricEnabled(bool v) => _prefs.setBool(_keyBiometricEnabled, v);

  // ── Locale ──
  String? get locale => _prefs.getString(_keyLocale);
  Future<bool> setLocale(String code) => _prefs.setString(_keyLocale, code);

  // ── Theme ──
  String? get themeMode => _prefs.getString(_keyThemeMode); // 'dark', 'light', 'system'
  Future<bool> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // ── Onboarding ──
  bool get onboardingCompleted => _prefs.getBool(_keyOnboardingCompleted) ?? false;
  Future<bool> setOnboardingCompleted(bool v) => _prefs.setBool(_keyOnboardingCompleted, v);

  // ── Clear ──
  Future<void> clear() => _prefs.clear();
}
