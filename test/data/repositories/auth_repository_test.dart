import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qcut_flutter/data/repositories/auth_repository.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockIdTokenResult extends Mock implements IdTokenResult {}
class MockFunctionsService extends Mock implements FunctionsService {}

void main() {
  test('resolveRole returns role from custom claims', () async {
    final auth = MockFirebaseAuth();
    final functions = MockFunctionsService();
    final repo = AuthRepository(auth, functions);
    final user = MockUser();
    final token = MockIdTokenResult();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async => token);
    when(() => token.claims).thenReturn({'role': 'provider', 'tenantId': 't1'});
    final role = await repo.resolveRole();
    expect(role, 'provider');
  });
}
