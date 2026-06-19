import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcut_flutter/services/auth_service.dart';
import 'package:qcut_flutter/services/biometric_auth_service.dart';
import 'package:qcut_flutter/services/haptic_service.dart';
import 'package:qcut_flutter/services/preferences_service.dart';
import 'package:qcut_flutter/services/secure_storage_service.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

enum LoginRole { owner, customer }

/// Admin / Customer Login with credential persistence, biometric unlock, and
/// password-manager integration (Android Autofill / iOS Keychain).
class LoginScreen extends StatefulWidget {
  final AuthService auth;
  final LoginRole role;
  final VoidCallback? onRegisterShop;
  final VoidCallback? onRegisterCustomer;
  final VoidCallback? onUseGuest;
  final SecureStorageService? secureStorage;
  final PreferencesService? preferences;

  const LoginScreen({
    super.key,
    required this.auth,
    this.role = LoginRole.owner,
    this.onRegisterShop,
    this.onRegisterCustomer,
    this.onUseGuest,
    this.secureStorage,
    this.preferences,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _loading = false;
  bool _rememberMe = true;
  bool _biometricReady = false;
  bool _biometricEnabled = false;
  String? _error;

  SecureStorageService get _secure => widget.secureStorage ?? SecureStorageService();
  PreferencesService? get _prefs => widget.preferences;
  bool get _isCustomer => widget.role == LoginRole.customer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Load saved preferences
    _rememberMe = await _secure.isRemembered();
    _biometricEnabled = _prefs?.biometricEnabled ?? false;

    // Check biometric availability
    final bio = BiometricAuthService();
    if (await bio.canAuthenticate()) {
      _biometricReady = true;
    }

    // Load saved credentials and autofill
    final creds = await _secure.getCredentials();
    if (creds != null) {
      _emailCtrl.text = creds.email;
      _passCtrl.text = creds.password;
    } else {
      // Pre-fill email from preferences (non-sensitive)
      final lastEmail = _prefs?.lastEmail;
      if (lastEmail != null) _emailCtrl.text = lastEmail;
    }

    if (mounted) {
      setState(() {});
      // If biometric enabled and credentials saved, prompt
      if (_biometricEnabled && _biometricReady && creds != null) {
        _tryBiometricUnlock();
      }
    }
  }

  Future<void> _tryBiometricUnlock() async {
    final bio = BiometricAuthService();
    final ok = await bio.authenticate(reason: 'Sign in to QCUT');
    if (ok && mounted) {
      await _doSignIn();
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await _doSignIn();
  }

  Future<void> _doSignIn() async {
    setState(() { _loading = true; _error = null; });
    await HapticService.trigger(HapticType.medium);

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    try {
      await widget.auth.signInWithEmail(email, password);

      // Save credentials if "Remember Me" is checked
      if (_rememberMe) {
        await _secure.saveCredentials(email, password);
      } else {
        await _secure.clearCredentials();
      }
      await _prefs?.setLastEmail(email);

      // Pop back to root so AuthRouter shows the dashboard for the signed-in user.
      if (mounted) {
        setState(() => _loading = false);
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Something went wrong. Try again.'; _loading = false; });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCutColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Logo
                  Image.asset(
                    'assets/logo/logo_transparent.png',
                    height: 96,
                    errorBuilder: (_, __, ___) => Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(gradient: QCutGradients.primary, borderRadius: BorderRadius.circular(28), boxShadow: QCutShadows.glow()),
                      child: const Center(child: Text('Q', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_isCustomer ? 'Welcome back' : 'Queue. Cut. Go.',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: QCutColors.onSurface, letterSpacing: -0.2)),
                  const SizedBox(height: 6),
                  Text(_isCustomer ? 'Customer Sign In' : 'Admin Panel',
                      style: TextStyle(fontSize: 13, color: QCutColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 32),

                  if (_error != null)
                    Container(
                      width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: QCutColors.errorTint, borderRadius: BorderRadius.circular(12), border: Border.all(color: QCutColors.error.withValues(alpha: 0.4))),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: QCutColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: QCutColors.error, fontSize: 13))),
                      ]),
                    ),

                  // Email with autofill hint
                  TextFormField(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    decoration: const InputDecoration(
                      labelText: 'Email', hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email, AutofillHints.username],
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                    onEditingComplete: () => _passFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),

                  // Password with autofill hint
                  TextFormField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    decoration: const InputDecoration(
                      labelText: 'Password', hintText: 'Min 4 characters',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) => (v == null || v.length < 4) ? 'Min 4 characters' : null,
                    onFieldSubmitted: (_) => _signIn(),
                  ),

                  // Remember me + Biometric toggle
                  const SizedBox(height: 12),
                  Row(children: [
                    // Remember Me
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(
                            width: 20, height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) => setState(() => _rememberMe = v ?? true),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Remember me', style: TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant)),
                        ]),
                      ),
                    ),
                    const Spacer(),
                    // Biometric toggle (only if available)
                    if (_biometricReady)
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final v = !_biometricEnabled;
                          setState(() => _biometricEnabled = v);
                          await _prefs?.setBiometricEnabled(v);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              _biometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
                              size: 24,
                              color: _biometricEnabled ? QCutColors.primary : QCutColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Biometric',
                              style: TextStyle(
                                fontSize: 13,
                                color: _biometricEnabled ? QCutColors.primary : QCutColors.onSurfaceVariant,
                                fontWeight: _biometricEnabled ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ]),
                        ),
                      ),
                  ]),

                  const SizedBox(height: 20),
                  QPrimaryButton(
                    onPressed: _loading ? null : _signIn,
                    icon: _loading ? null : Icons.login,
                    child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Sign In'),
                  ),

                  // Biometric quick-unlock button
                  if (_biometricReady && _rememberMe && _emailCtrl.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton.icon(
                        onPressed: _tryBiometricUnlock,
                        icon: const Icon(Icons.fingerprint, size: 20),
                        label: const Text('Unlock with biometrics'),
                        style: TextButton.styleFrom(foregroundColor: QCutColors.primary),
                      ),
                    ),

                  const SizedBox(height: 24),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6), fontWeight: FontWeight.w600))),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),

                  if (_isCustomer) ...[
                    Text('New here?', style: TextStyle(fontSize: 14, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: widget.onRegisterCustomer,
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Create an Account', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                    if (widget.onUseGuest != null) ...[
                      const SizedBox(height: 10),
                      TextButton(onPressed: widget.onUseGuest, child: const Text('Continue as guest')),
                    ],
                  ] else ...[
                    Text('New to QCUT?', style: TextStyle(fontSize: 14, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onRegisterShop?.call();
                      },
                      icon: const Icon(Icons.store, size: 18),
                      label: const Text('Register Your Shop', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ],
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
