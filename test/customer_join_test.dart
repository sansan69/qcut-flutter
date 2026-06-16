import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/models/shop_models.dart';

void main() {
  test('firstWhere returns null for missing barber', () {
    final barbers = <Barber>[Barber(id: '1', name: 'A')];
    final found = barbers.cast<Barber?>().firstWhere(
      (b) => b!.id == 'missing',
      orElse: () => null,
    );
    expect(found, isNull);
  });
}
