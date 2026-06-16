import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/main.dart';

void main() {
  testWidgets('landing shows customer actions', (tester) async {
    await tester.pumpWidget(const QCutApp());
    await tester.pumpAndSettle();
    expect(find.text('Scan & Join'), findsOneWidget);
    expect(find.text('My Bookings'), findsOneWidget);
  });
}
