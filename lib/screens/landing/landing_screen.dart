import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Landing screen — brand intro, from QCUT Kotlin LandingScreen.kt
class LandingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onMyAppointments;
  final VoidCallback onAdminLogin;

  const LandingScreen({
    super.key,
    required this.onGetStarted,
    required this.onMyAppointments,
    required this.onAdminLogin,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _logoClickCount = 0;

  void _onLogoClick() {
    _logoClickCount++;
    if (_logoClickCount >= 5) {
      _logoClickCount = 0;
      HapticFeedback.heavyImpact();
      widget.onAdminLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              GestureDetector(
                onTap: _onLogoClick,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
                  child: const Center(child: Text('Q', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: QCutColors.navy))),
                ),
              ),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Q - C U T', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: QCutColors.navy, letterSpacing: 2)),
                Text('CUT THE QUEUE', style: TextStyle(fontSize: 10, color: QCutColors.navy, letterSpacing: 1)),
              ]),
            ]),
            const SizedBox(height: 40),

            // Hero text
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D0C57)),
                children: const [
                  TextSpan(text: 'Queue-less bookings for '),
                  TextSpan(text: 'modern businesses', style: TextStyle(color: Color(0xFF7B1FA2))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('A sleek platform for token queues and smart appointment scheduling — fast to set up, delightful to use.',
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[600])),
            const SizedBox(height: 32),

            // Action cards
            _ActionCard(icon: Icons.store, title: 'Get Started', subtitle: 'Setup your business in seconds', onTap: widget.onGetStarted),
            const SizedBox(height: 12),
            _ActionCard(icon: Icons.calendar_month, title: 'My Appointments', subtitle: 'Find your booking', onTap: widget.onMyAppointments),
            const SizedBox(height: 32),

            // Feature card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.calendar_month, color: Color(0xFF7B1FA2))),
                  const SizedBox(height: 16),
                  const Text('Smart Scheduling', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D0C57))),
                  const SizedBox(height: 8),
                  Text('Book appointments that fit your schedule perfectly.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ]),
              ),
            ),
            const SizedBox(height: 48),

            Center(child: Text('© 2025 Q-CUT. All rights reserved.', style: TextStyle(fontSize: 11, color: Colors.grey[400]))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF3F0F5), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFF4A148C))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D0C57))),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      ),
    );
  }
}
