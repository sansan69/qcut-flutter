import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// What the app needs and why, shown in the permission-rationale dialog.
enum AppPermission {
  camera(
    permission: Permission.camera,
    title: 'Camera',
    icon: Icons.camera_alt,
    reason: 'To scan QR codes and join a queue instantly.',
    android: true, ios: true,
  ),
  notifications(
    permission: Permission.notification,
    title: 'Notifications',
    icon: Icons.notifications,
    reason: 'To alert you when your token is called or booking is confirmed.',
    android: true, ios: true,
  ),
  location(
    permission: Permission.locationWhenInUse,
    title: 'Location',
    icon: Icons.location_on,
    reason: 'To show nearby shops so you can join the closest queue.',
    android: true, ios: true,
  ),

  // Ignored — not available in permission_handler. Biometric is handled by
  // local_auth's in-app dialog on both platforms.
  // Ignored — battery optimisation is a system setting, not a runtime prompt.
  // Kept here for documentation; we can direct users to Settings if needed.
  ignoreBatteryOptimizations(
    permission: Permission.ignoreBatteryOptimizations,
    title: 'Background',
    icon: Icons.battery_saver,
    reason: 'To keep the app responsive for real-time queue updates.',
    android: true, ios: false,
  ),
  ;

  final Permission permission;
  final String title;
  final IconData icon;
  final String reason;
  final bool android;
  final bool ios;

  const AppPermission({
    required this.permission,
    required this.title,
    required this.icon,
    required this.reason,
    required this.android,
    required this.ios,
  });
}

/// Unified runtime-permission gateway. Requests every permission the app
/// needs on first launch, with rationale dialogs shown before each prompt.
class PermissionService {
  /// Permissions the app always needs.
  static const _required = [
    AppPermission.camera,
    AppPermission.notifications,
    AppPermission.location,
  ];

  /// Request every missing required permission, showing a rationale dialog
  /// before each Android prompt. Returns the set of granted permissions.
  static Future<Set<AppPermission>> requestAll(BuildContext context) async {
    final granted = <AppPermission>{};

    for (final p in _required) {
      // Skip if platform doesn't support this permission
      if (Platform.isAndroid && !p.android) continue;
      if (Platform.isIOS && !p.ios) continue;

      final status = await p.permission.status;
      switch (status) {
        case PermissionStatus.granted:
        case PermissionStatus.limited:
          granted.add(p);
          break;

        case PermissionStatus.denied:
          // Show rationale before prompting
          if (!context.mounted) break;
          final shouldRequest = await _showRationale(context, p);
          if (shouldRequest == true) {
            final result = await p.permission.request();
            if (result.isGranted || result.isLimited) {
              granted.add(p);
            }
          }
          break;

        case PermissionStatus.permanentlyDenied:
        case PermissionStatus.restricted:
        case PermissionStatus.provisional:
          // Offer to open settings
          _offerSettings(context, p);
          break;
      }
    }

    return granted;
  }

  /// Check if all critical permissions are already granted.
  static Future<bool> hasAllCritical() async {
    for (final p in _required) {
      if (Platform.isAndroid && !p.android) continue;
      if (Platform.isIOS && !p.ios) continue;
      final status = await p.permission.status;
      if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
        return false;
      }
    }
    return true;
  }

  /// Show a rationale dialog; returns true if user wants to proceed.
  static Future<bool?> _showRationale(BuildContext context, AppPermission p) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: Row(children: [
          Icon(p.icon, color: const Color(0xFF6B4EE6)),
          const SizedBox(width: 12),
          Text(p.title, style: const TextStyle(color: Color(0xFFE8E6F0))),
        ]),
        content: Text(
          p.reason,
          style: const TextStyle(color: Color(0xFF9E9CB0), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4EE6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  /// Show a dialog offering to open app settings.
  static void _offerSettings(BuildContext context, AppPermission p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        title: Row(children: [
          Icon(p.icon, color: const Color(0xFFFBBF24)),
          const SizedBox(width: 12),
          const Text('Permission needed', style: TextStyle(color: Color(0xFFE8E6F0))),
        ]),
        content: Text(
          'QCUT needs ${p.title.toLowerCase()} permission. '
          'Please enable it in your device Settings.',
          style: const TextStyle(color: Color(0xFF9E9CB0), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4EE6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
