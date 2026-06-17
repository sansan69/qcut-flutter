import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/repositories/queue_repository.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

class MockFunctionsService extends Mock implements FunctionsService {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  test('issueToken calls function with tenant and customer data', () async {
    final functions = MockFunctionsService();
    final firestore = MockFirebaseFirestore();
    final repo = QueueRepository(functions, firestore);
    when(() => functions.call('issueToken', any())).thenAnswer(
      (_) async => {
        'id': 'entry1',
        'entry': {
          'tokenNumber': 1,
          'status': 'waiting',
          'customerName': 'Ravi',
          'customerPhone': '+919876543210',
          'issuedAt': Timestamp.now(),
          'source': 'walk_in',
        },
      },
    );

    final result = await repo.issueToken(
      tenantId: 'ten1',
      customerName: 'Ravi',
      customerPhone: '+919876543210',
    );

    expect(result.id, 'entry1');
    expect(result.tokenNumber, 1);
    expect(result.status.name, 'waiting');
    expect(result.customerName, 'Ravi');
    expect(result.customerPhone, '+919876543210');
    expect(result.source, 'walk_in');
  });

  test('tokenStream emits token entries ordered by tokenNumber', () async {
    final functions = MockFunctionsService();
    final firestore = FakeFirebaseFirestore();
    final repo = QueueRepository(functions, firestore);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final entries = firestore
        .collection('tenants')
        .doc('ten1')
        .collection('tokens')
        .doc(today)
        .collection('entries');

    await entries.doc('e1').set({
      'tokenNumber': 2,
      'status': 'waiting',
      'customerName': 'B',
      'customerPhone': '+91',
      'issuedAt': Timestamp.now(),
      'source': 'walk_in',
    });
    await entries.doc('e2').set({
      'tokenNumber': 1,
      'status': 'waiting',
      'customerName': 'A',
      'customerPhone': '+91',
      'issuedAt': Timestamp.now(),
      'source': 'walk_in',
    });

    final emitted = await repo.tokenStream('ten1').first;

    expect(emitted.length, 2);
    expect(emitted[0].id, 'e2');
    expect(emitted[0].tokenNumber, 1);
    expect(emitted[1].id, 'e1');
    expect(emitted[1].tokenNumber, 2);
  });
}
