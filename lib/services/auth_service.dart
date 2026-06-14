import 'dart:async';

/// Auth result: who logged in and how
enum AuthRole { owner, customer, superAdmin }

class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final AuthRole role;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.role = AuthRole.customer,
  });

  bool get isOwner => role == AuthRole.owner;
  bool get isSuperAdmin => role == AuthRole.superAdmin;
}

/// Auth errors we handle gracefully
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Abstract auth interface — swap implementations later
abstract class AuthService {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  /// Owner: email + password (free, no per-auth cost)
  Future<AuthUser> signInWithEmail(String email, String password);
  Future<AuthUser> signUpWithEmail(String email, String password, {String? displayName});

  /// Customer: anonymous — just a name, no account needed
  Future<AuthUser> signInAnonymously({String? displayName});

  /// Phone OTP — COSTS MONEY. Disabled in MVP, stub for future.
  /// Will throw UnimplementedError until phone auth is configured.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AuthUser user) onVerified,
    required Function(String error) onError,
  });

  /// Sign out current user
  Future<void> signOut();
}

// ──────────────────────────────────────────────
// Demo Auth (works without Firebase, no backend)
// ──────────────────────────────────────────────

class DemoAuthService implements AuthService {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    if (email.isEmpty || password.length < 4) {
      throw AuthException('Invalid credentials');
    }
    final role = email == 'admin@qcut.in' ? AuthRole.superAdmin : AuthRole.owner;
    _currentUser = AuthUser(uid: 'demo-${email.hashCode}', email: email, role: role);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password, {String? displayName}) async {
    if (email.isEmpty || password.length < 4) {
      throw AuthException('Password must be at least 4 characters');
    }
    _currentUser = AuthUser(uid: 'demo-${email.hashCode}', email: email, displayName: displayName, role: AuthRole.owner);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signInAnonymously({String? displayName}) async {
    _currentUser = AuthUser(uid: 'anon-${DateTime.now().millisecondsSinceEpoch}', displayName: displayName, role: AuthRole.customer);
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AuthUser user) onVerified,
    required Function(String error) onError,
  }) async {
    onError('Phone OTP is not available in demo mode. Set up Firebase to enable.');
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
