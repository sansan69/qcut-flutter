import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/screens/owner/owner_dashboard_screen.dart';
import 'package:qcut_flutter/models/shop_models.dart';

void main() {
  testWidgets('dashboard shows live stats', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OwnerDashboardScreen(
        tenant: Tenant(id: 't', name: 'Shop'),
        waitingCount: 3,
        servingCount: 1,
        completedCount: 12,
        onOpenQueue: () {},
        onOpenBookings: () {},
        onOpenStaff: () {},
        onOpenSettings: () {},
        onOpenReports: () {},
        onOpenQR: () {},
        onSignOut: () {},
      ),
    ));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
