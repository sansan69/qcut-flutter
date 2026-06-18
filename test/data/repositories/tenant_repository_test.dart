import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/data/repositories/tenant_repository.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TenantRepository repo;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repo = TenantRepository(firestore);

    await firestore.collection('tenants').doc('t1').set({
      'slug': 'rajesh-salon',
      'name': 'Rajesh Salon',
      'type': 'salon',
      'ownerUid': 'u1',
      'planId': 'starter',
      'status': 'active',
      'createdAt': 1000,
    });
    await firestore.collection('tenants').doc('t2').set({
      'slug': 'closed-shop',
      'name': 'Closed Shop',
      'type': 'barbershop',
      'ownerUid': 'u2',
      'planId': 'starter',
      'status': 'suspended',
      'createdAt': 2000,
    });
  });

  group('TenantRepository.fetchBySlug', () {
    test('returns the active tenant matching the slug', () async {
      final tenant = await repo.fetchBySlug('rajesh-salon');

      expect(tenant, isNotNull);
      expect(tenant!.id, 't1');
      expect(tenant.slug, 'rajesh-salon');
      expect(tenant.name, 'Rajesh Salon');
      expect(tenant.type, 'salon');
      expect(tenant.ownerUid, 'u1');
      expect(tenant.planId, 'starter');
      expect(tenant.status, 'active');
    });

    test('returns null when slug does not match any tenant', () async {
      final tenant = await repo.fetchBySlug('does-not-exist');

      expect(tenant, isNull);
    });

    test('returns null when tenant exists but is not active', () async {
      final tenant = await repo.fetchBySlug('closed-shop');

      expect(tenant, isNull);
    });
  });

  group('TenantRepository.listTenants', () {
    test('returns all tenants ordered by createdAt descending', () async {
      final tenants = await repo.listTenants();

      expect(tenants.length, 2);
      expect(tenants[0].id, 't2');
      expect(tenants[0].name, 'Closed Shop');
      expect(tenants[1].id, 't1');
      expect(tenants[1].name, 'Rajesh Salon');
    });
  });

  group('TenantRepository.updateTenantStatus', () {
    test('updates status and writes updatedAt server timestamp', () async {
      await repo.updateTenantStatus('t1', 'suspended');

      final snap = await firestore.collection('tenants').doc('t1').get();
      expect(snap.data()!['status'], 'suspended');
      expect(snap.data()!['updatedAt'], isNotNull);
    });
  });
}
