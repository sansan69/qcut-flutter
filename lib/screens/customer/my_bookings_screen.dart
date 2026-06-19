import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qcut_flutter/models/booking.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Customer My Bookings — self-loading. Queries all booking subcollections
/// (collection group) for the signed-in user's phone number, so bookings made
/// across different shops appear together.
class MyBookingsScreen extends StatefulWidget {
  final Function(Booking)? onCancel;

  const MyBookingsScreen({super.key, this.onCancel});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final phone = user?.phoneNumber ?? '';
      // Collection-group query across all tenants' bookings, filtered by phone.
      // Falls back to email if no phone is set.
      final field = phone.isNotEmpty ? 'phoneNumber' : null;
      final value = phone.isNotEmpty ? phone : (user?.email ?? '');
      if (value.isEmpty) {
        if (!mounted) return;
        setState(() { _loading = false; });
        return;
      }
      final q = FirebaseFirestore.instance
          .collectionGroup('bookings')
          .where(field ?? 'customerName', isEqualTo: value);
      final snap = await q.get();
      final bookings = snap.docs.map((d) => Booking.fromMap(d.data(), d.id)).toList();
      bookings.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      if (!mounted) return;
      setState(() { _bookings = bookings; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _bookings.where((b) => b.status == 'confirmed').toList();
    final past = _bookings.where((b) => b.status != 'confirmed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Refresh'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? QEmptyState(
                  icon: Icons.cloud_off,
                  title: 'Couldn\'t load bookings',
                  subtitle: _error,
                  tint: QCutColors.error,
                  action: QPrimaryButton(onPressed: _load, icon: Icons.refresh, child: const Text('Retry')),
                )
              : _bookings.isEmpty
                  ? const QEmptyState(
                      icon: Icons.calendar_today,
                      title: 'No bookings yet',
                      subtitle: 'Book a slot at any shop to see it here.',
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(padding: const EdgeInsets.all(20), children: [
                        if (upcoming.isNotEmpty) ...[
                          QSectionLabel(icon: Icons.upcoming, title: 'Upcoming', trailing: '${upcoming.length}'),
                          const SizedBox(height: 12),
                          ...upcoming.map((b) => _BookingCard(booking: b, onCancel: () => _cancel(b))),
                          const SizedBox(height: 24),
                        ],
                        if (past.isNotEmpty) ...[
                          QSectionLabel(icon: Icons.history, title: 'Past', trailing: '${past.length}'),
                          const SizedBox(height: 12),
                          ...past.map((b) => _BookingCard(booking: b)),
                        ],
                      ]),
                    ),
    );
  }

  Future<void> _cancel(Booking b) async {
    try {
      await FirebaseFirestore.instance
          .collection('tenants').doc(b.tenantId)
          .collection('bookings').doc(b.id)
          .update({'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
      widget.onCancel?.call(b);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
      }
    }
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const _BookingCard({required this.booking, this.onCancel});

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed': return QCutColors.success;
      case 'completed': return QCutColors.primary;
      case 'cancelled': return QCutColors.error;
      case 'no-show': return QCutColors.warning;
      default: return QCutColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(booking.serviceType.isNotEmpty ? booking.serviceType : 'Appointment',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: QCutColors.onSurface))),
            QCountChip(label: booking.status.toUpperCase(), color: _statusColor),
          ]),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.person, text: booking.barberName),
          _InfoRow(icon: Icons.calendar_today, text: '${booking.date} at ${booking.timeSlot}'),
          if (booking.bookingCode.isNotEmpty) _InfoRow(icon: Icons.confirmation_number, text: 'Code: ${booking.bookingCode}'),
          if (onCancel != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: QCutColors.error,
                  side: BorderSide(color: QCutColors.error.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel Booking'),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant)),
      ]),
    );
  }
}
