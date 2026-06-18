import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qcut_flutter/screens/landing/landing_screen.dart';
import 'package:qcut_flutter/ui/core/admin_login_placeholder.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LandingScreen(
      onJoinQueue: () => _signInAnonymously(context),
      onMyBookings: () => _signInAnonymously(context),
      onAdminLogin: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginPlaceholder()),
      ),
    );
  }
}
