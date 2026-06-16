import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

void main() {
  test('FunctionsService exposes callable names', () {
    const names = FunctionsService.helloWorld;
    expect(names, 'helloWorld');
  });
}
