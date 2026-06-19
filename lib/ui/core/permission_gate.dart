import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qcut_flutter/services/permission_service.dart';
import 'package:qcut_flutter/services/preferences_service.dart';
import 'package:qcut_flutter/theme/app_theme.dart';

/// Shown once on first launch. Requests every needed permission with
/// rationale cards. After all permissions are visited, the actual app
/// root (AuthRouter) replaces this screen.
class PermissionGate extends StatefulWidget {
  final Widget child;
  final PreferencesService? preferences;

  const PermissionGate({super.key, required this.child, this.preferences});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  static const _seenKey = 'qcut_permissions_shown';
  late final Future<bool> _shouldShowGate;

  @override
  void initState() {
    super.initState();
    _shouldShowGate = _checkShouldShow();
  }

  Future<bool> _checkShouldShow() async {
    try {
      final alreadyDone = await PermissionService.hasAllCritical();
      if (alreadyDone) return false;

      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(_seenKey) ?? false;
      if (seen) return false;
    } catch (_) {
      // Unavailable in tests — skip the gate.
      return false;
    }
    return true;
  }

  Future<void> _request() async {
    if (!mounted) return;
    await PermissionService.requestAll(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    if (mounted) setState(() => _shouldShowGate = Future.value(false));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldShowGate,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: QCutColors.surface,
            body: Center(child: CircularProgressIndicator(color: QCutColors.primary)),
          );
        }
        if (!snapshot.data!) return widget.child;

        return Scaffold(
          backgroundColor: QCutColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/logo_transparent.png',
                    height: 80,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: QCutGradients.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text('Q',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Welcome to QCUT', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: QCutColors.onSurface)),
                  const SizedBox(height: 8),
                  const Text('Queue. Cut. Go.', style: TextStyle(fontSize: 16, color: QCutColors.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 32),
                  const Text('We need a few permissions to give you the best experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: QCutColors.onSurfaceVariant, height: 1.4)),
                  const SizedBox(height: 40),
                  _PermCard(icon: Icons.camera_alt, title: 'Camera', subtitle: 'Scan QR codes to join a queue instantly'),
                  _PermCard(icon: Icons.notifications, title: 'Notifications', subtitle: 'Get alerted when your token is called'),
                  _PermCard(icon: Icons.location_on, title: 'Location', subtitle: 'Find shops near you'),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: _request,
                      style: ElevatedButton.styleFrom(backgroundColor: QCutColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Continue', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _request,
                    child: const Text('Skip — I\'ll enable later', style: TextStyle(color: QCutColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PermCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _PermCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: QCutColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: QCutColors.primary, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: QCutColors.onSurface)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant)),
        ])),
        const Icon(Icons.check_circle_outline, color: QCutColors.outline, size: 20),
      ]),
    );
  }
}
