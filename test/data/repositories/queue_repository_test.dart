import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/repositories/queue_repository.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

class MockFunctionsService extends Mock implements FunctionsService {}

void main() {
  test('issueToken calls function with tenant and customer data', () async {
    final functions = MockFunctionsService();
    final repo = QueueRepository(functions);
    when(() => functions.call('issueToken', any())).thenAnswer((_) async => {'tokenId': 't1', 'tokenNumber': 1});

    final result = await repo.issueToken(
      tenantId: 'ten1',
      customerName: 'Ravi',
      customerPhone: '+919876543210',
    );

    expect(result.tokenNumber, 1);
  });
}
