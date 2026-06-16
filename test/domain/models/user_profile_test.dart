import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/domain/models/user_profile.dart';

void main() {
  test('UserProfile fromMap parses role and tenantId', () {
    final profile = UserProfile.fromMap({
      'uid': 'u1',
      'email': 'a@b.com',
      'role': 'provider',
      'tenantId': 't1',
      'displayName': 'Shop',
      'fcmTokens': ['tok1'],
    }, 'u1');
    expect(profile.role, UserRole.provider);
    expect(profile.tenantId, 't1');
  });
}
