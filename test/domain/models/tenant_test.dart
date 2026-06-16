import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';

void main() {
  test('Tenant fromMap parses slug and plan', () {
    final tenant = Tenant.fromMap({
      'id': 't1',
      'slug': 'my-shop',
      'name': 'My Shop',
      'type': 'barbershop',
      'ownerUid': 'u1',
      'planId': 'starter',
      'status': 'active',
    }, 't1');
    expect(tenant.slug, 'my-shop');
    expect(tenant.planId, 'starter');
  });
}
