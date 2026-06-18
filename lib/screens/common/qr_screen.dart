import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// QR Code display for shop booking link — shareable, downloadable.
/// The QR canvas itself stays white for reliable scanning; everything around
/// it speaks the dark brand language.
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('Book with $shopName — $bookingUrl', subject: 'Book at $shopName'),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              decoration: BoxDecoration(
                color: QCutColors.surfaceContainer,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: QCutColors.outlineVariant),
                boxShadow: QCutShadows.soft(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(shopName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: QCutColors.onSurface)),
                  const SizedBox(height: 4),
                  Text('Scan to book', style: TextStyle(fontSize: 14, color: QCutColors.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: QCutColors.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: bookingUrl,
                      version: QrVersions.auto,
                      size: 264,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: QCutColors.primary),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: QCutColors.primary),
                      gapless: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: QCutColors.primaryTint, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.link, size: 16, color: QCutColors.primary),
                      const SizedBox(width: 8),
                      Flexible(child: Text(bookingUrl, style: const TextStyle(fontSize: 13, color: QCutColors.primary, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(child: QPrimaryButton(
                onPressed: () => Share.share('Book with $shopName — $bookingUrl', subject: 'Book at $shopName'),
                icon: Icons.share,
                height: 50,
                child: const Text('Share Link'),
              )),
              const SizedBox(width: 12),
              Expanded(child: QTonalButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: bookingUrl));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking link copied!'), duration: Duration(seconds: 2)));
                },
                icon: Icons.copy,
                expand: true,
                child: const Text('Copy Link'),
              )),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: QCutColors.warningTint, borderRadius: BorderRadius.circular(14), border: Border.all(color: QCutColors.warning.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline, color: QCutColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Print this QR code and display at your shop counter for customers to scan and book.',
                    style: TextStyle(fontSize: 13, color: QCutColors.warning.withValues(alpha: 0.9), height: 1.4))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
