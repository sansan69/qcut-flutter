import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Customer My Bookings — upcoming & past bookings.
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
        actions: [
          if (onNewBooking != null)
            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onNewBooking, tooltip: 'New Booking'),
        ],
      ),
      body: bookings.isEmpty
          ? QEmptyState(
              icon: Icons.calendar_today,
              title: 'No bookings yet',
              action: onNewBooking != null
                  ? QPrimaryButton(onPressed: onNewBooking, icon: Icons.add, child: const Text('New Booking'))
                  : null,
            )
          : ListView(padding: const EdgeInsets.all(20), children: [
              if (upcoming.isNotEmpty) ...[
                QSectionLabel(icon: Icons.upcoming, title: 'Upcoming', trailing: '${upcoming.length}'),
                const SizedBox(height: 12),
                ...upcoming.map((b) => _BookingCard(booking: b, onCancel: () => onCancel(b))),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                QSectionLabel(icon: Icons.history, title: 'Past', trailing: '${past.length}'),
                const SizedBox(height: 12),
                ...past.map((b) => _BookingCard(booking: b, onCancel: null)),
              ],
            ]),
    );
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
            Expanded(child: Text(booking.serviceType.isNotEmpty ? booking.serviceType : 'Haircut',
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
