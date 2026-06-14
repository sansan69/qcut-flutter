import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';

/// Customer My Bookings — ported from QCUT Kotlin MyBookingsScreen.kt
class MyBookingsScreen extends StatelessWidget {
  final List<Booking> bookings;
  final Function(Booking) onCancel;
  final VoidCallback? onNewBooking;

  const MyBookingsScreen({
    super.key,
    required this.bookings,
    required this.onCancel,
    this.onNewBooking,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = bookings.where((b) => b.status == 'confirmed').toList();
    final past = bookings.where((b) => b.status != 'confirmed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
        actions: [
          if (onNewBooking != null)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onNewBooking,
              tooltip: 'New Booking',
            ),
        ],
      ),
      body: bookings.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today, size: 64, color: QCutColors.charcoal.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text('No bookings yet', style: TextStyle(fontSize: 16, color: QCutColors.charcoal.withValues(alpha: 0.5))),
                if (onNewBooking != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onNewBooking,
                    icon: const Icon(Icons.add),
                    label: const Text('New Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QCutColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ]),
            )
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(title: 'Upcoming', count: upcoming.length),
                const SizedBox(height: 8),
                ...upcoming.map((b) => _BookingCard(booking: b, onCancel: () => onCancel(b))),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                _SectionHeader(title: 'Past', count: past.length),
                const SizedBox(height: 8),
                ...past.map((b) => _BookingCard(booking: b, onCancel: null)),
              ],
            ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: QCutColors.navy)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: QCutColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
        child: Text('$count', style: TextStyle(fontSize: 12, color: QCutColors.charcoal.withValues(alpha: 0.6))),
      ),
    ]);
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const _BookingCard({required this.booking, this.onCancel});

  Color get _statusColor {
    switch (booking.status) {
      case 'confirmed':
        return QCutColors.emerald;
      case 'completed':
        return QCutColors.purple;
      case 'cancelled':
        return QCutColors.red;
      case 'no-show':
        return QCutColors.amber;
      default:
        return QCutColors.charcoal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(booking.serviceType.isNotEmpty ? booking.serviceType : 'Haircut',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: QCutColors.navy)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(booking.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor, letterSpacing: 0.5)),
            ),
          ]),
          const SizedBox(height: 8),
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
                  foregroundColor: QCutColors.red,
                  side: const BorderSide(color: QCutColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        Icon(icon, size: 14, color: QCutColors.charcoal.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: QCutColors.charcoal.withValues(alpha: 0.7))),
      ]),
    );
  }
}
