import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Customer-centric landing — like Swiggy/Zomato
/// Long press logo for admin access
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
    return Container(
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
              color: _logoHeld ? QCutColors.purple : QCutColors.navy,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _logoHeld
                  ? [BoxShadow(color: QCutColors.purple.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2)]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _logoHeld
                    ? const Icon(Icons.admin_panel_settings, color: Colors.white, size: 22, key: ValueKey('a'))
                    : const Text('Q', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), key: ValueKey('q')),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Q - CUT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: QCutColors.navy, letterSpacing: 1.5)),
          Text('Find & book nearby shops', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ])),
        GestureDetector(
          onTap: widget.onMyBookings,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
            child: const Icon(Icons.receipt_long, color: QCutColors.navy, size: 22),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [QCutColors.purple, QCutColors.navy]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))]),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search barber shops, salons, clinics...',
              hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: QCutColors.navy),
              suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner, color: QCutColors.purple), onPressed: widget.onJoinQueue, tooltip: 'Scan shop QR'),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [QCutColors.navy, Color(0xFF1E1B4B)]), borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Skip the Queue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Join or book instantly — no waiting, no hassle', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: widget.onJoinQueue,
              icon: const Icon(Icons.qr_code, size: 18),
              label: const Text('Scan & Join', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(backgroundColor: QCutColors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: widget.onMyBookings,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
          const Text('Nearby Shops', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: QCutColors.navy)),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('View all', style: TextStyle(color: QCutColors.purple))),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 200,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const Text('How It Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: QCutColors.navy)),
        const SizedBox(height: 16),
        Row(children: const [
          _HowStep(icon: Icons.qr_code_scanner, label: 'Scan QR at shop', color: QCutColors.purple),
          _HowStep(icon: Icons.person_add, label: 'Enter your name', color: QCutColors.emerald),
          _HowStep(icon: Icons.confirmation_number, label: 'Get token instantly', color: QCutColors.amber),
          _HowStep(icon: Icons.notifications, label: 'Get notified when ready', color: QCutColors.navy),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildHeroBanner(),
            const SizedBox(height: 28),
            _buildNearbyShops(),
            const SizedBox(height: 28),
            _buildHowItWorks(),
            const SizedBox(height: 40),
            Center(child: Text('© 2026 Q-CUT', style: TextStyle(fontSize: 11, color: Colors.grey[400]))),
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
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [QCutColors.navy, QCutColors.purple]), borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
          child: Center(child: Icon(img, color: Colors.white, size: 36)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: QCutColors.navy), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(type, style: TextStyle(fontSize: 11, color: QCutColors.charcoal.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star, size: 14, color: QCutColors.amber), const SizedBox(width: 2),
              Text(rating, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: QCutColors.navy)),
              const SizedBox(width: 8),
              Text(distance, style: TextStyle(fontSize: 11, color: QCutColors.charcoal.withValues(alpha: 0.4))),
            ]),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: QCutColors.emeraldBg, borderRadius: BorderRadius.circular(6)),
              child: Text(wait, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: QCutColors.emerald)),
            ),
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
        Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 26)),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.3, color: QCutColors.charcoal.withValues(alpha: 0.6))),
      ]),
    );
  }
}
