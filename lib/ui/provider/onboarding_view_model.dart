import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:qcut_flutter/data/repositories/auth_repository.dart';
import 'package:qcut_flutter/data/services/firestore_service.dart';

class OnboardingViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirestoreService _firestore;

  OnboardingViewModel({
    required AuthRepository authRepository,
    required FirestoreService firestore,
  })  : _authRepository = authRepository,
        _firestore = firestore;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> submit({
    required String email,
    required String password,
    required String businessName,
    required String ownerName,
    required String phone,
    required String type,
  }) async {
    _setLoading(true);
    try {
      final cred = await _authRepository.signUpWithEmailAndPassword(
        email,
        password,
      );
      final uid = cred.user!.uid;
      await _firestore.setDocument('users', uid, {
        'uid': uid,
        'email': email,
        'phone': phone,
        'role': 'provider',
        'displayName': ownerName,
        'fcmTokens': <String>[],
        'createdAt': Timestamp.now(),
      });
      await _firestore.addDocument('onboarding_submissions', {
        'uid': uid,
        'businessName': businessName,
        'ownerName': ownerName,
        'phone': phone,
        'type': type,
        'status': 'pending',
        'submittedAt': Timestamp.now(),
      });
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
