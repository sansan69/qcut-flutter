import 'package:flutter/material.dart';
import '../../models/shop_models.dart';

/// Owner dashboard — ported from QCUT Kotlin AdminDashboardScreen.kt
class OwnerDashboardScreen extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenStaff;
  final VoidCallback onOpenSettings;

  const OwnerDashboardScreen({
    super.key,
    required this.tenant,
    required this.onOpenQueue,
    required this.onOpenBookings,
    required this.onOpenStaff,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.name),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: onOpenSettings),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Stats row
        Row(children: [
          _StatCard(label: 'Waiting', value: '12', color: colors.primary),
          const SizedBox(width: 12),
          _StatCard(label: 'Serving', value: '3', color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          _StatCard(label: 'Completed', value: '47', color: const Color(0xFF7C3AED)),
        ]),
        const SizedBox(height: 24),
        // Quick actions
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _ActionCard(icon: Icons.format_list_numbered, title: 'Token Queue', subtitle: 'Now Serving / Waiting / Completed', onTap: onOpenQueue),
        _ActionCard(icon: Icons.calendar_month, title: 'Bookings', subtitle: 'Appointments & calendar', onTap: onOpenBookings),
        _ActionCard(icon: Icons.people, title: 'Staff', subtitle: 'Manage barbers & schedule', onTap: onOpenStaff),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
