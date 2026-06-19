import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qcut_flutter/data/repositories/shop_repository.dart';
import 'package:qcut_flutter/models/shop_models.dart';
import 'package:qcut_flutter/screens/common/qr_scanner_screen.dart';
import 'package:qcut_flutter/screens/customer/shop_browser_screen.dart';
import 'package:qcut_flutter/screens/customer/my_bookings_screen.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Customer home — shows nearby shops, my bookings, recently visited, and
/// a scan QR FAB to join a shop queue.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final ShopRepository _shopRepo = ShopRepository();
  List<ShopSummary> _shops = [];
  List<ShopSummary> _recentShops = [];
  bool _loading = true;
  String? _error;

  static const _recentKey = 'qcut_recent_shops';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final shops = await _shopRepo.listActiveShops();
      final recent = await _loadRecentShops();
      if (!mounted) return;
      setState(() {
        _shops = shops;
        _recentShops = recent;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<List<ShopSummary>> _loadRecentShops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final slugs = prefs.getStringList(_recentKey) ?? [];
      if (slugs.isEmpty) return [];
      final results = <ShopSummary>[];
      for (final slug in slugs) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('tenants')
              .where('slug', isEqualTo: slug)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();
          if (snap.docs.isNotEmpty) {
            final t = Tenant.fromMap(snap.docs.first.data(), snap.docs.first.id);
            results.add(ShopSummary.fromTenant(t));
          }
        } catch (_) {}
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRecentShop(ShopSummary shop) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final slugs = prefs.getStringList(_recentKey) ?? [];
      final slug = shop.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      slugs.remove(slug);
      slugs.insert(0, slug);
      if (slugs.length > 10) slugs.removeRange(10, slugs.length);
      await prefs.setStringList(_recentKey, slugs);
    } catch (_) {}
  }

  Future<void> _openShop(ShopSummary shop) async {
    await _saveRecentShop(shop);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ShopBrowserScreen(shop: shop, shopRepository: _shopRepo),
    ));
  }

  Future<void> _onScanPressed() async {
    final url = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted || url == null) return;

    final slug = url
        .replaceFirst('https://qcut.co.in/s/', '')
        .replaceFirst('https://qcut.in/s/', '');
    if (slug.isEmpty || slug == url) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not a valid QCUT shop QR code.')),
      );
      return;
    }

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
      await _openShop(shop);
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    children: [
                      _buildMyBookingsCard(),
                      if (_recentShops.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildRecentSection(),
                      ],
                      const SizedBox(height: 24),
                      _buildShopListSection(),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onScanPressed,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildError() {
    return QEmptyState(
      icon: Icons.cloud_off,
      title: 'Couldn\'t load shops',
      subtitle: _error,
      tint: QCutColors.error,
      action: QPrimaryButton(onPressed: _load, icon: Icons.refresh, child: const Text('Retry')),
    );
  }

  Widget _buildMyBookingsCard() {
    return QGlassCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(gradient: QCutGradients.accent, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: QCutColors.onSurface)),
          SizedBox(height: 2),
          Text('View your upcoming and past bookings', style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
        ])),
        Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
      ]),
    );
  }

  Widget _buildRecentSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      QSectionLabel(icon: Icons.history, title: 'Recently Visited', trailing: '${_recentShops.length}'),
      const SizedBox(height: 12),
      ..._recentShops.take(5).map((shop) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildShopTile(shop),
      )),
    ]);
  }

  Widget _buildShopListSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      QSectionLabel(icon: Icons.store, title: 'Nearby Shops', trailing: '${_shops.length}'),
      const SizedBox(height: 12),
      ..._shops.map((shop) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildShopTile(shop),
      )),
    ]);
  }

  Widget _buildShopTile(ShopSummary shop) {
    final isToken = shop.bookingMode == 'token';
    IconData icon;
    switch (shop.type.toLowerCase()) {
      case 'salon':
      case 'barbershop':
        icon = Icons.content_cut;
      case 'spa':
        icon = Icons.spa;
      case 'clinic':
      case 'dental':
        icon = Icons.medical_services;
      default:
        icon = Icons.storefront;
    }
    return QGlassCard(
      margin: EdgeInsets.zero,
      onTap: () => _openShop(shop),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(gradient: QCutGradients.primary, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: QCutColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            shop.address.isNotEmpty ? shop.address : [shop.city, shop.district].whereType<String>().where((s) => s.isNotEmpty).join(', '),
            style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7)),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          QCountChip(label: isToken ? 'TOKEN QUEUE' : 'APPOINTMENT', color: isToken ? QCutColors.primary : QCutColors.success),
        ])),
        Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
      ]),
    );
  }
}
