import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcut_flutter/data/repositories/shop_repository.dart';
import 'package:qcut_flutter/data/services/location_service.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Customer-centric landing — live, searchable, location-sorted shop list.
/// Long-press the logo for admin access. Tap a shop to open its booking/queue.
class LandingScreen extends StatefulWidget {
  final VoidCallback onJoinQueue;
  final VoidCallback onMyBookings;
  final VoidCallback onAdminLogin;
  final VoidCallback onClientLogin;
  final void Function(ShopSummary shop) onOpenShop;
  final ShopRepository? shopRepository;

  const LandingScreen({
    super.key,
    required this.onJoinQueue,
    required this.onMyBookings,
    required this.onAdminLogin,
    required this.onClientLogin,
    required this.onOpenShop,
    this.shopRepository,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _logoHeld = false;
  bool _showAdminHint = false;

  late final ShopRepository _repo;
  List<ShopSummary> _allShops = [];
  List<ShopSummary> _filtered = [];
  LatLng? _location;
  bool _loading = true;
  bool _locationEnabled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = widget.shopRepository ?? ShopRepository();
    _searchCtrl.addListener(_onSearchChanged);
    _load();
  }

  Future<void> _load({bool withLocation = true}) async {
    setState(() { _loading = true; _error = null; });
    try {
      if (withLocation) {
        _location = await LocationService.getCurrentLocation();
        _locationEnabled = _location != null;
      }
      final shops = await _repo.listActiveShops(near: _location);
      if (!mounted) return;
      setState(() {
        _allShops = shops;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allShops
          : _allShops.where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.type.toLowerCase().contains(q) ||
              s.address.toLowerCase().contains(q) ||
              (s.district ?? '').toLowerCase().contains(q) ||
              (s.city ?? '').toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _retryWithLocation() async {
    await _load(withLocation: true);
  }

  void _onLogoLongPressStart() {
    HapticFeedback.heavyImpact();
    setState(() { _logoHeld = true; _showAdminHint = true; });
  }

  void _onLogoLongPressEnd() {
    if (_logoHeld) {
      setState(() { _logoHeld = false; _showAdminHint = false; });
      widget.onAdminLogin();
    }
  }

  void _onLogoLongPressCancel() {
    setState(() { _logoHeld = false; _showAdminHint = false; });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Header ──
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        GestureDetector(
          onLongPressStart: (_) => _onLogoLongPressStart(),
          onLongPressEnd: (_) => _onLogoLongPressEnd(),
          onLongPressCancel: _onLogoLongPressCancel,
          onLongPressUp: _onLogoLongPressEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: QCutColors.iconBackground,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _logoHeld ? QCutShadows.glow() : [BoxShadow(color: QCutColors.primary.withValues(alpha: 0.25), blurRadius: 10)],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _logoHeld
                  ? const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22, key: ValueKey('a'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        'assets/logo/logo_transparent.png',
                        width: 40, height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text('Q', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white), key: ValueKey('q')),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('QCUT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: QCutColors.onSurface, letterSpacing: 2)),
          Text('Skip the queue, book instantly', style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
        ])),
        GestureDetector(
          onTap: widget.onMyBookings,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: QCutColors.surfaceContainer, borderRadius: BorderRadius.circular(12), border: Border.all(color: QCutColors.outlineVariant)),
            child: const Icon(Icons.receipt_long, color: QCutColors.primary, size: 22),
          ),
        ),
      ]),
    );
  }

  // ── Auth row: client login + scan ──
  Widget _buildAuthRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(child: _GhostButton(icon: Icons.login, label: 'Sign in', onTap: widget.onClientLogin)),
        const SizedBox(width: 10),
        Expanded(child: _GhostButton(icon: Icons.qr_code_scanner, label: 'Scan QR', onTap: widget.onJoinQueue, primary: true)),
      ]),
    );
  }

  // ── Search bar ──
  Widget _buildSearchBar() {
    return Column(children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showAdminHint
            ? Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: QCutGradients.primary, borderRadius: const BorderRadius.all(Radius.circular(12)), boxShadow: QCutShadows.glow()),
                child: const Row(children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Release for admin panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ]),
              )
            : const SizedBox.shrink(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          decoration: BoxDecoration(color: QCutColors.surfaceContainer, borderRadius: BorderRadius.circular(16), border: Border.all(color: QCutColors.outlineVariant)),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: QCutColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Search shops, salons, clinics…',
              hintStyle: const TextStyle(fontSize: 15, color: QCutColors.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search, color: QCutColors.onSurfaceVariant),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear, color: QCutColors.onSurfaceVariant), onPressed: () { _searchCtrl.clear(); _applyFilter(); })
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Location status strip ──
  Widget _buildLocationStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: _locationEnabled
          ? Row(children: [
              const Icon(Icons.my_location, size: 15, color: QCutColors.success),
              const SizedBox(width: 6),
              Text('Sorted by distance from you', style: TextStyle(fontSize: 12, color: QCutColors.success.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
            ])
          : GestureDetector(
              onTap: _retryWithLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: QCutColors.primaryTint, borderRadius: BorderRadius.circular(20), border: Border.all(color: QCutColors.primary.withValues(alpha: 0.3))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_searching, size: 14, color: QCutColors.primary),
                  const SizedBox(width: 6),
                  Text('Enable location for nearest shops', style: TextStyle(fontSize: 12, color: QCutColors.primary, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
    );
  }

  // ── Hero banner ──
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: QCutGradients.hero, borderRadius: const BorderRadius.all(Radius.circular(24)), border: Border.all(color: QCutColors.primary.withValues(alpha: 0.3)), boxShadow: QCutShadows.soft()),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Skip the Queue', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          const Text('Join or book instantly — no waiting, no hassle', style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
        ]),
      ),
    );
  }

  // ── Shop list section ──
  Widget _buildShopList() {
    if (_loading) {
      return const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: QEmptyState(
          icon: Icons.cloud_off,
          title: 'Couldn\'t load shops',
          subtitle: _error,
          tint: QCutColors.error,
          action: QPrimaryButton(onPressed: () => _load(), icon: Icons.refresh, child: const Text('Retry')),
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: QEmptyState(
          icon: Icons.storefront,
          title: _searchCtrl.text.isNotEmpty ? 'No shops match your search' : 'No shops available yet',
          subtitle: _searchCtrl.text.isNotEmpty ? 'Try a different name or type' : 'Check back soon — new shops are joining QCUT daily.',
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: QSectionLabel(icon: Icons.store, title: _locationEnabled ? 'Nearest Shops' : 'All Shops', trailing: '${_filtered.length}'),
      ),
      const SizedBox(height: 12),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final shop = _filtered[i];
          final dist = shop.distanceFrom(_location);
          return _ShopCard(shop: shop, distanceLabel: dist == null ? null : LocationService.distanceLabel(dist), onTap: () => widget.onOpenShop(shop));
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCutColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(withLocation: _locationEnabled),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildHeader(),
              _buildAuthRow(),
              _buildSearchBar(),
              _buildLocationStrip(),
              _buildHeroBanner(),
              const SizedBox(height: 24),
              _buildShopList(),
              const SizedBox(height: 32),
              Center(child: Text('© 2026 QCUT', style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 1))),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ──

class _ShopCard extends StatelessWidget {
  final ShopSummary shop;
  final String? distanceLabel;
  final VoidCallback onTap;

  const _ShopCard({required this.shop, this.distanceLabel, required this.onTap});

  IconData get _icon {
    switch (shop.type.toLowerCase()) {
      case 'salon':
      case 'barbershop':
        return Icons.content_cut;
      case 'spa':
        return Icons.spa;
      case 'clinic':
      case 'dental':
        return Icons.medical_services;
      default:
        return Icons.storefront;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToken = shop.bookingMode == 'token';
    return QGlassCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(gradient: QCutGradients.primary, borderRadius: BorderRadius.circular(14)),
          child: Icon(_icon, color: Colors.white.withValues(alpha: 0.9), size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: QCutColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            shop.address.isNotEmpty ? shop.address : _prettyLocation(),
            style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7)),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(children: [
            QCountChip(label: isToken ? 'TOKEN QUEUE' : 'APPOINTMENT', color: isToken ? QCutColors.primary : QCutColors.success),
            if (distanceLabel != null) ...[
              const SizedBox(width: 6),
              QCountChip(label: distanceLabel!, color: QCutColors.info),
            ],
          ]),
        ])),
        Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
      ]),
    );
  }

  String _prettyLocation() => [shop.city, shop.district].whereType<String>().where((s) => s.isNotEmpty).join(', ');
}

class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _GhostButton({required this.icon, required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: primary ? QCutGradients.primary : null,
          color: primary ? null : QCutColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: primary ? null : Border.all(color: QCutColors.outlineVariant),
          boxShadow: primary ? QCutShadows.glow() : null,
        ),
        child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: primary ? Colors.white : QCutColors.onSurface, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: primary ? Colors.white : QCutColors.onSurface, fontSize: 14)),
        ])),
      ),
    );
  }
}
