import 'package:flutter/material.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

class SuperAdminDashboardPlaceholder extends StatelessWidget {
  const SuperAdminDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const QLogoHeader(height: 28)),
      body: const QEmptyState(
        icon: Icons.dashboard_customize,
        title: 'Platform Admin',
        subtitle: 'Tenant approvals, billing, and reports live here.',
      ),
    );
  }
}
