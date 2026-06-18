import 'package:flutter/material.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

class AdminLoginPlaceholder extends StatelessWidget {
  const AdminLoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const QLogoHeader(height: 28)),
      body: const QEmptyState(
        icon: Icons.admin_panel_settings,
        title: 'Admin Login',
        subtitle: 'Admin login flow is being migrated to the new auth repository. Use the legacy admin path until integration is complete.',
      ),
    );
  }
}
