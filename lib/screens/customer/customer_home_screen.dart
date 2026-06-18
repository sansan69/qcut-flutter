import 'package:flutter/material.dart';
import 'package:qcut_flutter/screens/common/qr_scanner_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QCut')),
      body: const Center(
        child: Text('Customer home — browse shops, scan QR, view bookings'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QrScannerScreen()),
          );
        },
        label: const Text('Scan QR'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
