import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Login screen — email/password for owners, name-only for customers
class LoginScreen extends StatefulWidget {
  final AuthService auth;

  const LoginScreen({super.key, required this.auth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'demo@qcut.in');
  final _passCtrl = TextEditingController(text: 'demo');
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOwner = true;         // toggle between owner login and customer walk-in
  bool _isRegistering = false;  // toggle between sign-in and sign-up
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isOwner && !_formKey.currentState!.validate()) return;
    if (!_isOwner && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() { _loading = true; _error = null; });
    HapticFeedback.mediumImpact();

    try {
      if (_isOwner) {
        if (_isRegistering) {
          await widget.auth.signUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
        } else {
          await widget.auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
        }
      } else {
        // Customer: anonymous sign-in with just a name — no account, no cost
        await widget.auth.signInAnonymously(displayName: _nameCtrl.text.trim());
      }
    } on AuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Something went wrong. Try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _isOwner ? _formKey : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: QCutColors.navy, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('Q', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Q - CUT', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: QCutColors.navy)),
                  Text('Queue smart, work fast', style: TextStyle(fontSize: 14, color: QCutColors.charcoal.withValues(alpha: 0.5))),
                  const SizedBox(height: 40),

                  // Role toggle
                  Container(
                    decoration: BoxDecoration(color: QCutColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOwner = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isOwner ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isOwner ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.store, size: 18, color: _isOwner ? QCutColors.navy : QCutColors.charcoal.withValues(alpha: 0.4)),
                              const SizedBox(width: 8),
                              Text('Owner', style: TextStyle(fontWeight: FontWeight.w600, color: _isOwner ? QCutColors.navy : QCutColors.charcoal.withValues(alpha: 0.4))),
                            ]),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isOwner = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isOwner ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isOwner ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.person, size: 18, color: !_isOwner ? QCutColors.navy : QCutColors.charcoal.withValues(alpha: 0.4)),
                              const SizedBox(width: 8),
                              Text('Customer', style: TextStyle(fontWeight: FontWeight.w600, color: !_isOwner ? QCutColors.navy : QCutColors.charcoal.withValues(alpha: 0.4))),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // Error banner
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: QCutColors.redBg, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: QCutColors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: QCutColors.red, fontSize: 13))),
                      ]),
                    ),

                  // Owner login form
                  if (_isOwner) ...[
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: _deco('Email', 'owner@shop.com', Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      decoration: _deco('Password', 'Min 4 characters', Icons.lock),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 4) ? 'Min 4 characters' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _isRegistering = !_isRegistering),
                        child: Text(_isRegistering ? 'Already have an account? Sign in' : 'New shop? Register here',
                            style: TextStyle(fontSize: 13, color: QCutColors.navy.withValues(alpha: 0.7))),
                      ),
                    ),
                  ],

                  // Customer walk-in form
                  if (!_isOwner) ...[
                    TextField(
                      controller: _nameCtrl,
                      decoration: _deco('Your Name', 'Enter name to join queue', Icons.person),
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneCtrl,
                      decoration: _deco('Phone (optional)', 'For future notifications', Icons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: QCutColors.emeraldBg, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.info_outline, size: 16, color: QCutColors.emerald),
                        const SizedBox(width: 8),
                        Expanded(child: Text('No account needed. Just walk in and get your token.', style: TextStyle(fontSize: 12, color: QCutColors.emerald))),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QCutColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(_isOwner
                              ? (_isRegistering ? 'Create Account' : 'Sign In')
                              : 'Join Queue',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Phone OTP — future scope
                  if (_isOwner) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: 0.4,
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.sms, size: 18),
                          label: const Text('Login with Phone OTP', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Phone OTP coming soon — requires verification setup',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: QCutColors.charcoal.withValues(alpha: 0.3))),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String label, String hint, IconData icon) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon),
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );
}
