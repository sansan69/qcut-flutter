import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

class WebBookingPage extends StatefulWidget {
  final String shopSlug;
  const WebBookingPage({super.key, required this.shopSlug});

  @override
  State<WebBookingPage> createState() => _WebBookingPageState();
}

class _WebBookingPageState extends State<WebBookingPage> {
  bool _loading = true;
  String? _error;
  Tenant? _tenant;

  @override
  void initState() {
    super.initState();
    _loadTenant();
  }

  Future<void> _loadTenant() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tenants')
          .where('slug', isEqualTo: widget.shopSlug)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() { _loading = false; _error = 'Shop not found'; });
        return;
      }
      setState(() {
        _tenant = Tenant.fromMap(snap.docs.first.data(), snap.docs.first.id);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: QCutColors.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: QCutColors.surface,
        body: QEmptyState(
          icon: Icons.error_outline,
          title: 'Error loading shop',
          subtitle: _error,
          tint: QCutColors.error,
        ),
      );
    }
    return Scaffold(
      backgroundColor: QCutColors.surface,
      appBar: AppBar(
        title: const QLogoHeader(height: 28, showText: false),
        actions: [TextButton(onPressed: () {}, child: const Text('Help'))],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_tenant?.name ?? 'Shop', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Booking flow for ${widget.shopSlug}', style: const TextStyle(color: QCutColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
