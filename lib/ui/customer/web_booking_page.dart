import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qcut_flutter/domain/models/tenant.dart';

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
        setState(() {
          _loading = false;
          _error = 'Shop not found';
        });
        return;
      }
      setState(() {
        _tenant = Tenant.fromMap(snap.docs.first.data(), snap.docs.first.id);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_tenant?.name ?? 'Shop')),
      body: Center(child: Text('Booking flow for ${widget.shopSlug}')),
    );
  }
}
