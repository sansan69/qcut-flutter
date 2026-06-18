import 'package:flutter/material.dart';
import 'package:qcut_flutter/screens/common/qr_scanner_screen.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

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
      appBar: AppBar(title: const QLogoHeader(height: 28)),
      body: const QEmptyState(
        icon: Icons.storefront,
        title: 'Browse shops near you',
        subtitle: 'Scan a shop QR code to join the queue or book a slot.',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onScanPressed,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
