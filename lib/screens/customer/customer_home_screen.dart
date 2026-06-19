import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qcut_flutter/data/repositories/shop_repository.dart';
import 'package:qcut_flutter/models/shop_models.dart';
import 'package:qcut_flutter/screens/common/qr_scanner_screen.dart';
import 'package:qcut_flutter/screens/customer/shop_browser_screen.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Customer home — entry point for browsing/booking after sign-in. The scan
/// FAB scans a shop QR and routes into that shop's token/booking flow.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final ShopRepository _shopRepo = ShopRepository();

  Future<void> _onScanPressed() async {
    final url = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted || url == null) return;

    // Extract the shop slug from the scanned booking URL.
    final slug = url
        .replaceFirst('https://qcut.co.in/s/', '')
        .replaceFirst('https://qcut.in/s/', '');
    if (slug.isEmpty || slug == url) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a valid QCUT shop QR code.')),
      );
      return;
    }

    await _openShopBySlug(slug);
  }

  Future<void> _openShopBySlug(String slug) async {
    try {
      final tenantSnap = await FirebaseFirestore.instance
          .collection('tenants')
          .where('slug', isEqualTo: slug)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (!mounted) return;
      if (tenantSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No active shop found for "$slug".')),
        );
        return;
      }
      final tenant = Tenant.fromMap(tenantSnap.docs.first.data(), tenantSnap.docs.first.id);
      final shop = ShopSummary.fromTenant(tenant);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ShopBrowserScreen(shop: shop, shopRepository: _shopRepo),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open shop: $e')),
      );
    }
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
