import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'auth_service.dart';

/// Firebase-backed AuthService — email/password + anonymous
class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth;
  final _controller = StreamController<AuthUser?>.broadcast();
  StreamSubscription<fb.User?>? _fbSub;
  AuthUser? _currentUser;

  FirebaseAuthService({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance {
    _fbSub = _auth.authStateChanges().listen(_onFirebaseUser);
    // Sync initial state
    _onFirebaseUser(_auth.currentUser);
  }

  void _onFirebaseUser(fb.User? fbUser) {
    if (fbUser == null) {
      _currentUser = null;
    } else {
      final isAnon = fbUser.isAnonymous;
      _currentUser = AuthUser(
        uid: fbUser.uid,
        email: fbUser.email,
        displayName: fbUser.displayName,
        role: isAnon ? AuthRole.customer : AuthRole.owner,
      );
    }
    _controller.add(_currentUser);
  }

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _toUser(cred.user!);
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password, {String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null) {
      await cred.user?.updateDisplayName(displayName);
    }
    return _toUser(cred.user!);
  }

  @override
  Future<AuthUser> signInAnonymously({String? displayName}) async {
    final cred = await _auth.signInAnonymously();
    if (displayName != null) {
      await cred.user?.updateDisplayName(displayName);
    }
    return _toUser(cred.user!);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AuthUser user) onVerified,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          final result = await _auth.signInWithCredential(credential);
          onVerified(_toUser(result.user!));
        },
        verificationFailed: (e) => onError(e.message ?? 'Verification failed'),
        codeSent: (String verificationId, int? resendToken) => onCodeSent(verificationId),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Confirm phone OTP code
  Future<AuthUser> confirmPhoneCode(String verificationId, String smsCode) async {
    final cred = fb.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final result = await _auth.signInWithCredential(cred);
    return _toUser(result.user!);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  AuthUser _toUser(fb.User u) {
    return AuthUser(
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      role: u.isAnonymous ? AuthRole.customer : AuthRole.owner,
    );
  }

  void dispose() {
    _fbSub?.cancel();
    _controller.close();
  }
}

/// Initialize Firebase — google-services.json is read automatically on Android
Future<void> initFirebase() async {
  await Firebase.initializeApp();
}
