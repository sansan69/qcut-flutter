import 'package:flutter/material.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';

class ProviderDashboardScreen extends StatelessWidget {
  final Future<void> Function()? onRefresh;

  const ProviderDashboardScreen({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const QLogoHeader(height: 28),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Text('Provider dashboard — queue, staff, calendar, QR, settings'),
          ),
        ),
      ),
    );
  }
}
