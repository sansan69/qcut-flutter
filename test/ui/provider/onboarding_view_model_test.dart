import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/repositories/auth_repository.dart';
import 'package:qcut_flutter/data/services/firestore_service.dart';
import 'package:qcut_flutter/ui/provider/onboarding_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirestoreService extends Mock implements FirestoreService {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late OnboardingViewModel viewModel;
  late MockAuthRepository authRepository;
  late MockFirestoreService firestore;

  setUp(() {
    authRepository = MockAuthRepository();
    firestore = MockFirestoreService();
    viewModel = OnboardingViewModel(
      authRepository: authRepository,
      firestore: firestore,
    );
  });

  tearDown(() => viewModel.dispose());

  test('submit creates user and onboarding submission', () async {
    final cred = MockUserCredential();
    final user = MockUser();
    when(() => user.uid).thenReturn('provider-uid-123');
    when(() => cred.user).thenReturn(user);
    when(() => authRepository.signUpWithEmailAndPassword(any(), any()))
        .thenAnswer((_) async => cred);
    when(() => firestore.setDocument(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => firestore.addDocument(any(), any()))
        .thenAnswer((_) async => 'submission-id');

    final result = await viewModel.submit(
      email: 'owner@example.com',
      password: 'password123',
      businessName: 'Acme Salon',
      ownerName: 'John Doe',
      phone: '+911234567890',
      type: 'salon',
    );

    expect(result, isTrue);
    expect(viewModel.error, isNull);
    verify(() => authRepository.signUpWithEmailAndPassword(
          'owner@example.com',
          'password123',
        )).called(1);
    verify(() => firestore.setDocument('users', 'provider-uid-123', any()))
        .called(1);
    verify(() => firestore.addDocument('onboarding_submissions', any()))
        .called(1);
  });

  test('submit returns false and sets error on failure', () async {
    when(() => authRepository.signUpWithEmailAndPassword(any(), any()))
        .thenThrow(Exception('email already in use'));

    final result = await viewModel.submit(
      email: 'owner@example.com',
      password: 'password123',
      businessName: 'Acme Salon',
      ownerName: 'John Doe',
      phone: '+911234567890',
      type: 'salon',
    );

    expect(result, isFalse);
    expect(viewModel.error, contains('email already in use'));
  });
}
