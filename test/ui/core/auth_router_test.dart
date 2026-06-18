import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/ui/core/auth_router.dart';

void main() {
  group('AppRole mapping', () {
    test('provider maps to provider', () {
      const role = 'provider';
      expect(_mapRole(role), AppRole.provider);
    });

    test('platform_admin maps to platformAdmin', () {
      const role = 'platform_admin';
      expect(_mapRole(role), AppRole.platformAdmin);
    });

    test('customer maps to customer', () {
      const role = 'customer';
      expect(_mapRole(role), AppRole.customer);
    });

    test('null maps to customer', () {
      expect(_mapRole(null), AppRole.customer);
    });
  });
}

AppRole _mapRole(String? role) {
  switch (role) {
    case 'provider':
      return AppRole.provider;
    case 'platform_admin':
      return AppRole.platformAdmin;
    case 'customer':
    case null:
    default:
      return AppRole.customer;
  }
}
