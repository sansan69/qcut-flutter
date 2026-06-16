import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:qcut_flutter/data/services/firestore_service.dart';

void main() {
  test('getDocument returns null for missing doc', () async {
    final db = FakeFirebaseFirestore();
    final service = FirestoreService(db);
    final doc = await service.getDocument('tenants', 'missing');
    expect(doc, isNull);
  });
}
