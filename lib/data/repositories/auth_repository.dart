import 'package:firebase_auth/firebase_auth.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FunctionsService _functions;

  AuthRepository(this._auth, this._functions);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> resolveRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdTokenResult(true);
    return token.claims?['role'] as String?;
  }

  Future<String?> resolveTenantId() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdTokenResult(true);
    return token.claims?['tenantId'] as String?;
  }

  Future<void> refreshCustomClaims() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _functions.call(FunctionsService.refreshCustomClaims, {'uid': user.uid});
    await user.getIdToken(true);
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await refreshCustomClaims();
    return cred;
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await refreshCustomClaims();
    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
