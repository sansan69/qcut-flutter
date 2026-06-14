import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/main.dart';

void main() {
  testWidgets('QCutApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QCutApp());
    expect(find.byType(QCutApp), findsOneWidget);
  });
}
