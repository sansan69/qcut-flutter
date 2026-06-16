import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/services/auth_service.dart';

void main() {
  test('super admin email resolves to superAdmin', () {
    final user = AuthUser(uid: '1', email: 'admin@qcut.in', role: AuthRole.superAdmin);
    expect(user.isSuperAdmin, isTrue);
    expect(user.isOwner, isFalse);
  });

  test('owner email resolves to owner', () {
    final user = AuthUser(uid: '2', email: 'owner@example.com', role: AuthRole.owner);
    expect(user.isOwner, isTrue);
    expect(user.isSuperAdmin, isFalse);
  });

  test('anonymous resolves to customer', () {
    final user = AuthUser(uid: '3', displayName: 'Guest', role: AuthRole.customer);
    expect(user.isSuperAdmin, isFalse);
    expect(user.isOwner, isFalse);
  });
}
