import 'package:flutter/material.dart';
import 'package:qcut_flutter/screens/common/qr_scanner_screen.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  Future<void> _onScanPressed() async {
    final url = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted || url == null) return;
    final slug = url.replaceFirst('https://qcut.co.in/s/', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanned shop: $slug')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const QLogoHeader(height: 28),
      ),
      body: const Center(
        child: Text('Customer home — browse shops, scan QR, view bookings'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onScanPressed,
        label: const Text('Scan QR'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
