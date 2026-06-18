import 'package:flutter/material.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const QLogoHeader(height: 28),
      ),
      body: const Center(
        child: Text('Provider dashboard — queue, staff, calendar, QR, settings'),
      ),
    );
  }
}
