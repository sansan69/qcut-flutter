import 'package:flutter/material.dart';
import 'package:qcut_flutter/services/auth_service.dart';
import 'package:qcut_flutter/services/haptic_service.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Customer account creation — email + password + name + phone. Creates a
/// Firebase Auth user (no tenant claims). On success the auth-state listener
/// in the router navigates the customer into the app.
class ClientSignupScreen extends StatefulWidget {
  final AuthService auth;
  final VoidCallback? onAlreadyHaveAccount; // back to login

  const ClientSignupScreen({super.key, required this.auth, this.onAlreadyHaveAccount});

  @override
  State<ClientSignupScreen> createState() => _ClientSignupScreenState();
}

class _ClientSignupScreenState extends State<ClientSignupScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    await HapticService.trigger(HapticType.medium);

    try {
      await widget.auth.signUpWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      if (mounted) setState(() => _loading = false);
      // Router listens to auth state and navigates on success.
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
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset(
                  'assets/logo/logo_transparent.png',
                  height: 80,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(gradient: QCutGradients.primary, borderRadius: BorderRadius.circular(24), boxShadow: QCutShadows.glow()),
                    child: const Center(child: Text('Q', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Join QCUT', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Book & queue faster with an account', style: TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant)),
                const SizedBox(height: 28),

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
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone (optional)', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 4) ? 'Min 4 characters' : null,
                ),
                const SizedBox(height: 24),
                QPrimaryButton(
                  onPressed: _loading ? null : _signup,
                  icon: _loading ? null : Icons.person_add,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onAlreadyHaveAccount,
                  child: const Text('Already have an account? Sign in'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
