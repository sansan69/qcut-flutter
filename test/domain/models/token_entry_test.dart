import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/domain/models/token_entry.dart';

void main() {
  test('TokenEntry fromMap parses status and tokenNumber', () {
    final entry = TokenEntry.fromMap({
      'tokenNumber': 5,
      'status': 'waiting',
      'customerName': 'Ravi',
      'customerPhone': '+919876543210',
    }, 'e1');
    expect(entry.tokenNumber, 5);
    expect(entry.status, TokenStatus.waiting);
  });
}
