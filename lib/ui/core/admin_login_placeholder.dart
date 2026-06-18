import 'package:flutter/material.dart';

class AdminLoginPlaceholder extends StatelessWidget {
  const AdminLoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Admin login flow is being migrated to the new auth repository. '
            'Use the legacy admin path until integration is complete.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
