import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';

/// QR Code display for shop booking link — shareable, downloadable
class ShopQRScreen extends StatelessWidget {
  final String shopName;
  final String bookingUrl;

  const ShopQRScreen({
    super.key,
    required this.shopName,
    required this.bookingUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop QR Code'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
              'Book with $shopName — $bookingUrl',
              subject: 'Book at $shopName',
            ),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // QR Card
            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Shop name above QR
                  Text(shopName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: QCutColors.navy)),
                  const SizedBox(height: 4),
                  Text('Scan to book', style: TextStyle(fontSize: 14, color: QCutColors.charcoal.withValues(alpha: 0.5))),
                  const SizedBox(height: 24),
                  // QR code
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: QCutColors.surfaceVariant, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: bookingUrl,
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: QCutColors.navy),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: QCutColors.navy,
                      ),
                      gapless: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // URL below QR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: QCutColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.link, size: 16, color: QCutColors.purple),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(bookingUrl, style: const TextStyle(fontSize: 13, color: QCutColors.purple, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.share,
                  label: 'Share Link',
                  color: QCutColors.purple,
                  onTap: () => Share.share(
                    'Book with $shopName — $bookingUrl',
                    subject: 'Book at $shopName',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  color: QCutColors.navy,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: bookingUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking link copied!'), duration: Duration(seconds: 2)),
                    );
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Print / display tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: QCutColors.amberBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline, color: QCutColors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Print this QR code and display at your shop counter for customers to scan and book.',
                    style: TextStyle(fontSize: 13, color: QCutColors.amber, height: 1.4),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
