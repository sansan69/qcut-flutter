import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/main.dart';

void main() {
  testWidgets('landing shows customer actions', (tester) async {
    await tester.pumpWidget(const QCutApp());
    // Pump (don't settle) — the landing kicks off a location/geolocator fetch
    // and a Firestore read which are unavailable in the headless test env and
    // surface as the landing's error state; the static auth actions render
    // immediately regardless.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
  });
}
