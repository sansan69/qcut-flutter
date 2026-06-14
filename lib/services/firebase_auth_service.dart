import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'auth_service.dart';

/// Firebase-backed AuthService for appointment-32f4a project
class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth;
  final _controller = StreamController<AuthUser?>.broadcast();
  StreamSubscription<fb.User?>? _fbSub;
  AuthUser? _currentUser;

  // Super admin emails — in production, fetch from Firestore 'super_admins' collection
  static const _superAdminEmails = {'admin@qcut.in'};

  FirebaseAuthService({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance {
    _fbSub = _auth.authStateChanges().listen(_onFirebaseUser);
    _onFirebaseUser(_auth.currentUser);
  }

  void _onFirebaseUser(fb.User? fbUser) {
    if (fbUser == null) {
      _currentUser = null;
    } else {
      final email = fbUser.email ?? '';
      final role = _superAdminEmails.contains(email)
          ? AuthRole.superAdmin
          : fbUser.isAnonymous ? AuthRole.customer : AuthRole.owner;
      _currentUser = AuthUser(
        uid: fbUser.uid,
        email: fbUser.email,
        displayName: fbUser.displayName,
        role: role,
      );
    }
    _controller.add(_currentUser);
  }

  @override Stream<AuthUser?> get authStateChanges => _controller.stream;
  @override AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _toUser(cred.user!);
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password, {String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null) await cred.user?.updateDisplayName(displayName);
    return _toUser(cred.user!);
  }

  @override
  Future<AuthUser> signInAnonymously({String? displayName}) async {
    final cred = await _auth.signInAnonymously();
    if (displayName != null) await cred.user?.updateDisplayName(displayName);
    return _toUser(cred.user!);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(AuthUser) onVerified,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (fb.PhoneAuthCredential cred) async {
          final r = await _auth.signInWithCredential(cred);
          onVerified(_toUser(r.user!));
        },
        verificationFailed: (e) => onError(e.message ?? 'Failed'),
        codeSent: (id, _) => onCodeSent(id),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<AuthUser> confirmPhoneCode(String verificationId, String smsCode) async {
    final cred = fb.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final r = await _auth.signInWithCredential(cred);
    return _toUser(r.user!);
  }

  @override
  Future<void> signOut() async => _auth.signOut();

  AuthUser _toUser(fb.User u) => AuthUser(
    uid: u.uid, email: u.email, displayName: u.displayName,
    role: u.isAnonymous ? AuthRole.customer : AuthRole.owner,
  );

  void dispose() { _fbSub?.cancel(); _controller.close(); }
}

Future<void> initFirebase() async {
  await Firebase.initializeApp();
}
