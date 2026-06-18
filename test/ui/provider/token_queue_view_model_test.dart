import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/ui/provider/token_queue_view_model.dart';
import 'package:qcut_flutter/data/repositories/queue_repository.dart';
import 'package:qcut_flutter/domain/models/token_entry.dart';

class MockQueueRepository extends Mock implements QueueRepository {}

void main() {
  test('callNext invokes repository', () async {
    final repo = MockQueueRepository();
    final vm = TokenQueueViewModel(repository: repo, tenantId: 't1');
    when(() => repo.callNext('t1')).thenAnswer((_) async => TokenEntry(
      id: 'e1', tokenNumber: 1, status: TokenStatus.called,
      customerName: 'A', customerPhone: '+91', issuedAt: DateTime.now(),
    ));
    await vm.callNext();
    verify(() => repo.callNext('t1')).called(1);
  });
}
