import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';

void main() {
  group('Tenant', () {
    test('fromMap parses slug and plan', () {
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

    test('toMap round-trips correctly', () {
      final original = Tenant(
        id: 't1',
        slug: 'my-shop',
        name: 'My Shop',
        type: 'barbershop',
        ownerUid: 'u1',
        planId: 'starter',
        status: 'active',
      );

      final map = original.toMap();
      final roundTripped = Tenant.fromMap(map, 't1');

      expect(roundTripped.id, original.id);
      expect(roundTripped.slug, original.slug);
      expect(roundTripped.name, original.name);
      expect(roundTripped.type, original.type);
      expect(roundTripped.ownerUid, original.ownerUid);
      expect(roundTripped.planId, original.planId);
      expect(roundTripped.status, original.status);
    });

    test('uses default values when fields are missing', () {
      final tenant = Tenant.fromMap({'id': 't1'}, 't1');

      expect(tenant.slug, '');
      expect(tenant.name, '');
      expect(tenant.type, 'barbershop');
      expect(tenant.ownerUid, '');
      expect(tenant.planId, 'starter');
      expect(tenant.status, 'pending');
    });
  });
}
