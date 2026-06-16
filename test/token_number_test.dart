import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/models/token_entry.dart';

void main() {
  test('token increments from next available number', () {
    int nextToken = 5;
    final token = TokenEntry(tokenNumber: nextToken++);
    expect(token.tokenNumber, 5);
    expect(nextToken, 6);
  });
}
