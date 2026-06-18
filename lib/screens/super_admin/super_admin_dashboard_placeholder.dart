import 'package:flutter/material.dart';

class SuperAdminDashboardPlaceholder extends StatelessWidget {
  const SuperAdminDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Admin')),
      body: const Center(
        child: Text('Platform admin dashboard — tenant approvals, billing, reports'),
      ),
    );
  }
}
