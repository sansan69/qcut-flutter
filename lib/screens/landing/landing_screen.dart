import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Customer-centric landing — dark, premium, brand-forward.
/// Long-press the logo for admin access.
class LandingScreen extends StatefulWidget {
  final VoidCallback onJoinQueue;
  final VoidCallback onMyBookings;
  final VoidCallback onAdminLogin;

  const LandingScreen({
    super.key,
    required this.onJoinQueue,
    required this.onMyBookings,
    required this.onAdminLogin,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _searchCtrl = TextEditingController();
  bool _logoHeld = false;
  bool _showAdminHint = false;

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
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  // ── Header with logo + long press ──
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
              gradient: _logoHeld ? QCutGradients.accent : QCutGradients.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _logoHeld ? QCutShadows.glow() : [BoxShadow(color: QCutColors.primary.withValues(alpha: 0.25), blurRadius: 10)],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _logoHeld
                    ? const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22, key: ValueKey('a'))
                    : const Text('Q', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white), key: ValueKey('q')),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('QCUT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: QCutColors.onSurface, letterSpacing: 2)),
          Text('Find & book nearby shops', style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
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

  // ── Search bar ──
  Widget _buildSearchBar() {
    return Column(children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showAdminHint
            ? Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: QCutGradients.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  boxShadow: QCutShadows.glow(),
                ),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: QCutColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: QCutColors.outlineVariant),
          ),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: QCutColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Search barber shops, salons, clinics...',
              hintStyle: const TextStyle(fontSize: 15, color: QCutColors.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search, color: QCutColors.onSurfaceVariant),
              suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner, color: QCutColors.primary), onPressed: widget.onJoinQueue, tooltip: 'Scan shop QR'),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Hero banner ──
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: QCutGradients.hero,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          border: Border.all(color: QCutColors.primary.withValues(alpha: 0.3)),
          boxShadow: QCutShadows.soft(),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Skip the Queue', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          const Text('Join or book instantly — no waiting, no hassle', style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: QPrimaryButton(
              onPressed: widget.onJoinQueue,
              icon: Icons.qr_code_scanner,
              height: 48,
              child: const Text('Scan & Join'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _OutlineLightButton(
              onPressed: widget.onMyBookings,
              icon: Icons.calendar_month,
              label: 'My Bookings',
            )),
          ]),
        ]),
      ),
    );
  }

  // ── Nearby shops ──
  Widget _buildNearbyShops() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          const Text('Nearby Shops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('View all', style: TextStyle(color: QCutColors.primary, fontWeight: FontWeight.w600))),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 208,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: const [
            _ShopCard(name: 'Rajesh Salon', type: 'Barbershop', rating: '4.8', distance: '0.5 km', wait: '~15 min', img: Icons.content_cut),
            _ShopCard(name: 'Faisal Gents Spa', type: 'Spa & Salon', rating: '4.6', distance: '1.2 km', wait: '~5 min', img: Icons.spa),
            _ShopCard(name: 'City Dental Clinic', type: 'Dental', rating: '4.9', distance: '2.0 km', wait: 'By appt', img: Icons.medical_services),
            _ShopCard(name: 'Sujith Hair Studio', type: 'Barbershop', rating: '4.5', distance: '0.8 km', wait: '~20 min', img: Icons.style),
          ],
        ),
      ),
    ]);
  }

  // ── How it works ──
  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('How It Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
        const SizedBox(height: 16),
        const Row(children: [
          _HowStep(icon: Icons.qr_code_scanner, label: 'Scan QR at shop', color: QCutColors.primary),
          _HowStep(icon: Icons.person_add, label: 'Enter your name', color: QCutColors.success),
          _HowStep(icon: Icons.confirmation_number, label: 'Get token instantly', color: QCutColors.warning),
          _HowStep(icon: Icons.notifications, label: 'Get notified', color: QCutColors.secondary),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCutColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildHeroBanner(),
            const SizedBox(height: 32),
            _buildNearbyShops(),
            const SizedBox(height: 32),
            _buildHowItWorks(),
            const SizedBox(height: 40),
            Center(child: Text('© 2026 QCUT', style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5), letterSpacing: 1))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

// ── Helper widgets ──

class _ShopCard extends StatelessWidget {
  final String name, type, rating, distance, wait;
  final IconData img;
  const _ShopCard({required this.name, required this.type, required this.rating, required this.distance, required this.wait, required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: QCutColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: QCutColors.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 82,
          decoration: BoxDecoration(
            gradient: QCutGradients.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
          ),
          child: Center(child: Icon(img, color: Colors.white.withValues(alpha: 0.9), size: 36)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: QCutColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(type, style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star, size: 14, color: QCutColors.warning),
              const SizedBox(width: 2),
              Text(rating, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: QCutColors.onSurface)),
              const SizedBox(width: 8),
              Text(distance, style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
            ]),
            const SizedBox(height: 6),
            QCountChip(label: wait, color: QCutColors.success),
          ]),
        ),
      ]),
    );
  }
}

class _HowStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HowStep({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.3, color: QCutColors.onSurfaceVariant)),
      ]),
    );
  }
}

/// Light-outlined ghost button for use on dark gradient surfaces.
class _OutlineLightButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const _OutlineLightButton({required this.onPressed, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
          ])),
        ),
      ),
    );
  }
}
