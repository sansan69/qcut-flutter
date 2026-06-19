import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qcut_flutter/data/repositories/shop_repository.dart';
import 'package:qcut_flutter/data/services/fcm_service.dart';
import 'package:qcut_flutter/screens/auth/login_screen.dart';
import 'package:qcut_flutter/screens/customer/client_signup_screen.dart';
import 'package:qcut_flutter/screens/customer/my_bookings_screen.dart';
import 'package:qcut_flutter/screens/customer/shop_browser_screen.dart';
import 'package:qcut_flutter/screens/landing/landing_screen.dart';
import 'package:qcut_flutter/screens/onboarding/onboarding_screen.dart';
import 'package:qcut_flutter/services/auth_service.dart';
import 'package:qcut_flutter/services/firebase_auth_service.dart';
import 'package:qcut_flutter/services/preferences_service.dart';
import 'package:qcut_flutter/services/secure_storage_service.dart';

/// The landing surface shown when no user is signed in. Wires the real
/// [LoginScreen] (admin and customer) instead of a placeholder, plus the
/// shop browser for tapping a shop into its token/booking flow.
class AuthLandingScreen extends StatelessWidget {
  final ShopRepository? shopRepository;
  final SecureStorageService? secureStorage;
  final PreferencesService? preferences;

  const AuthLandingScreen({
    super.key,
    this.shopRepository,
    this.secureStorage,
    this.preferences,
  });

  AuthService _authService() {
    // Mirror _AppRootState's fallback logic: prefer Firebase, fall back to demo.
    try {
      return FirebaseAuthService();
    } catch (e) {
      debugPrint('Falling back to DemoAuthService: $e');
      return DemoAuthService();
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      try {
        final fcm = FcmService(FirebaseMessaging.instance);
        final tok = await fcm.getToken();
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (tok != null && uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'fcmTokens': FieldValue.arrayUnion([tok]),
          }, SetOptions(merge: true));
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  }

  Future<void> _openMyBookings(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await _signInAnonymously();
    }
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
  }

  void _openAdminLogin(BuildContext context) {
    final auth = _authService();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LoginScreen(
        auth: auth,
        role: LoginRole.owner,
        secureStorage: secureStorage,
        preferences: preferences,
        onRegisterShop: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onBackToHome: () { Navigator.popUntil(context, (r) => r.isFirst); },
            auth: auth,
          ),
        )),
      ),
    ));
  }

  void _openClientLogin(BuildContext context) {
    final auth = _authService();
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LoginScreen(
        auth: auth,
        role: LoginRole.customer,
        secureStorage: secureStorage,
        preferences: preferences,
        onRegisterCustomer: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ClientSignupScreen(auth: auth, onAlreadyHaveAccount: () => Navigator.pop(context)),
        )),
        onUseGuest: () => Navigator.pop(context),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LandingScreen(
      shopRepository: shopRepository,
      onJoinQueue: () => _signInAnonymously(),
      onMyBookings: () => _signInAnonymously(),
      onAdminLogin: () => _openAdminLogin(context),
      onClientLogin: () => _openClientLogin(context),
      onOpenShop: (shop) => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ShopBrowserScreen(shop: shop, shopRepository: shopRepository),
      )),
    );
  }
}
