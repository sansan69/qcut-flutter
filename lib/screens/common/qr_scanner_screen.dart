import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';

/// Full-screen QR scanner with a branded dark overlay frame.
class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCutColors.scrim,
      appBar: AppBar(
        title: const Text('Scan Shop QR'),
        backgroundColor: QCutColors.scrim,
        foregroundColor: Colors.white,
      ),
      body: Stack(children: [
        MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final raw = barcode.rawValue;
              if (raw != null && raw.startsWith('https://qcut.co.in/s/')) {
                Navigator.of(context).pop(raw);
                return;
              }
            }
          },
        ),
        // Darkened vignette with a clear scanning window
        ColorFiltered(
          colorFilter: ColorFilter.mode(QCutColors.scrim.withValues(alpha: 0.35), BlendMode.srcOver),
          child: Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: QCutColors.primary, width: 2),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: QCutColors.primary.withValues(alpha: 0.4), blurRadius: 24)],
              ),
            ),
          ),
        ),
        // Hint
        Positioned(
          left: 0, right: 0, bottom: 48,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: QCutColors.scrim.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
              child: const Text('Point at a QCUT shop QR code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ),
      ]),
    );
  }
}
