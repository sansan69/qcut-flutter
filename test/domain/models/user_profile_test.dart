import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/domain/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('fromMap parses role and tenantId', () {
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

    test('toMap round-trips correctly', () {
      final original = UserProfile(
        uid: 'u1',
        email: 'a@b.com',
        phone: '+1234567890',
        role: UserRole.provider,
        tenantId: 't1',
        displayName: 'Shop',
        fcmTokens: ['tok1', 'tok2'],
        createdAt: DateTime(2023, 1, 2),
      );

      final map = original.toMap();
      final roundTripped = UserProfile.fromMap(map, 'u1');

      expect(roundTripped.uid, original.uid);
      expect(roundTripped.email, original.email);
      expect(roundTripped.phone, original.phone);
      expect(roundTripped.role, original.role);
      expect(roundTripped.tenantId, original.tenantId);
      expect(roundTripped.displayName, original.displayName);
      expect(roundTripped.fcmTokens, original.fcmTokens);
      expect(roundTripped.createdAt, original.createdAt);
    });

    test('defaults to customer for unknown role strings', () {
      final profile = UserProfile.fromMap({'role': 'not_a_role'}, 'u1');
      expect(profile.role, UserRole.customer);
    });

    test('handles fcmTokens list correctly', () {
      final profile = UserProfile.fromMap({
        'fcmTokens': ['token-a', 'token-b', 'token-c'],
      }, 'u1');

      expect(profile.fcmTokens, ['token-a', 'token-b', 'token-c']);

      final map = profile.toMap();
      expect(map['fcmTokens'], ['token-a', 'token-b', 'token-c']);
    });

    test('handles createdAt Timestamp conversion', () {
      final createdAt = DateTime(2023, 5, 10, 14, 30);
      final profile = UserProfile(
        uid: 'u1',
        role: UserRole.customer,
        displayName: 'Name',
        createdAt: createdAt,
      );

      final map = profile.toMap();
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), createdAt);

      final fromMap = UserProfile.fromMap(map, 'u1');
      expect(fromMap.createdAt, createdAt);
    });
  });
}
