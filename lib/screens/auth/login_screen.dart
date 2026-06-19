import 'package:flutter/material.dart';
import 'package:qcut_flutter/services/auth_service.dart';
import 'package:qcut_flutter/services/haptic_service.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Which login surface is being shown.
enum LoginRole { owner, customer }

/// Admin / Customer Login — role-aware. Sign In (email + password) or, for
/// owners, register a shop (onboarding); for customers, create an account.
class LoginScreen extends StatefulWidget {
  final AuthService auth;
  final LoginRole role;
  final VoidCallback? onRegisterShop; // owner → onboarding flow
  final VoidCallback? onRegisterCustomer; // customer → signup screen
  final VoidCallback? onUseGuest; // optional: continue as guest

  const LoginScreen({
    super.key,
    required this.auth,
    this.role = LoginRole.owner,
    this.onRegisterShop,
    this.onRegisterCustomer,
    this.onUseGuest,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  bool get _isCustomer => widget.role == LoginRole.customer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    await HapticService.trigger(HapticType.medium);

    try {
      await widget.auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      // On success the auth-state listener in the router will navigate away.
      if (mounted) setState(() => _loading = false);
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Something went wrong. Try again.'; _loading = false; });
    }
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

                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', hintText: 'you@example.com', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Password', hintText: 'Min 4 characters', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 4) ? 'Min 4 characters' : null,
                  onFieldSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 24),
                QPrimaryButton(
                  onPressed: _loading ? null : _signIn,
                  icon: _loading ? null : Icons.login,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Sign In'),
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
    );
  }
}
