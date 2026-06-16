import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:qcut_flutter/data/services/firestore_service.dart';

void main() {
  group('FirestoreService', () {
    late FakeFirebaseFirestore db;
    late FirestoreService service;

    setUp(() {
      db = FakeFirebaseFirestore();
      service = FirestoreService(db);
    });

    test('getDocument returns null for missing doc', () async {
      final doc = await service.getDocument('tenants', 'missing');
      expect(doc, isNull);
    });

    test('addDocument creates a doc and returns its ID', () async {
      final data = {'name': 'Test Tenant', 'active': true};
      final id = await service.addDocument('tenants', data);

      expect(id, isNotEmpty);

      final doc = await service.getDocument('tenants', id);
      expect(doc, equals(data));
    });

    test('setDocument with merge updates fields', () async {
      await service.setDocument(
        'tenants',
        't1',
        {'name': 'Original', 'active': true},
      );
      await service.setDocument(
        'tenants',
        't1',
        {'active': false, 'region': 'EU'},
        merge: true,
      );

      final doc = await service.getDocument('tenants', 't1');
      expect(doc, {'name': 'Original', 'active': false, 'region': 'EU'});
    });

    test('updateDocument updates fields', () async {
      await service.setDocument(
        'tenants',
        't2',
        {'name': 'Original', 'count': 1},
      );
      await service.updateDocument('tenants', 't2', {'count': 2});

      final doc = await service.getDocument('tenants', 't2');
      expect(doc, {'name': 'Original', 'count': 2});
    });

    test('deleteDocument removes a doc', () async {
      await service.setDocument('tenants', 't3', {'name': 'To Delete'});
      await service.deleteDocument('tenants', 't3');

      final doc = await service.getDocument('tenants', 't3');
      expect(doc, isNull);
    });

    test('collectionStream emits a list when data changes', () async {
      final stream = service.collectionStream('tenants');

      expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          hasLength(1),
        ]),
      );

      await service.addDocument('tenants', {'name': 'Tenant A'});
    });
  });
}
