import 'package:flutter/material.dart';
import '../../models/shop_models.dart';

/// Owner dashboard — shows plan badge and gated features
class OwnerDashboardScreen extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenBookings;
  final VoidCallback onOpenStaff;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenQR;
  final VoidCallback onSignOut;
  final SubscriptionPlan plan;
  final int waitingCount;
  final int servingCount;
  final int completedCount;

  const OwnerDashboardScreen({
    super.key,
    required this.tenant,
    required this.onOpenQueue,
    required this.onOpenBookings,
    required this.onOpenStaff,
    required this.onOpenSettings,
    required this.onOpenReports,
    required this.onOpenQR,
    required this.onSignOut,
    this.plan = SubscriptionPlan.starter,
    this.waitingCount = 0,
    this.servingCount = 0,
    this.completedCount = 0,
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
          // Plan badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _planColor(plan).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(plan.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _planColor(plan))),
            ]),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: onSignOut, tooltip: 'Sign out'),
          IconButton(icon: const Icon(Icons.settings), onPressed: onOpenSettings),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Stats row
        Row(children: [
          _StatCard(label: 'Waiting', value: waitingCount.toString(), color: colors.primary),
          const SizedBox(width: 12),
          _StatCard(label: 'Serving', value: servingCount.toString(), color: const Color(0xFF10B981)),
          const SizedBox(width: 12),
          _StatCard(label: 'Completed', value: completedCount.toString(), color: const Color(0xFF7C3AED)),
        ]),
        const SizedBox(height: 24),

        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _ActionCard(icon: Icons.format_list_numbered, title: 'Token Queue', subtitle: 'Now Serving / Waiting / Completed', onTap: onOpenQueue),
        _ActionCard(
          icon: Icons.calendar_month,
          title: 'Bookings',
          subtitle: plan.appointments ? 'Appointments & calendar' : 'Upgrade to Pro/Clinic',
          locked: !plan.appointments,
          onTap: onOpenBookings,
        ),
        _ActionCard(icon: Icons.people, title: 'Staff', subtitle: 'Manage barbers & schedule', onTap: onOpenStaff),
        _ActionCard(
          icon: Icons.qr_code,
          title: 'Shop QR',
          subtitle: plan.qrCode ? 'Display for customer scanning' : 'Upgrade to Pro/Clinic',
          locked: !plan.qrCode,
          onTap: onOpenQR,
        ),
        _ActionCard(icon: Icons.bar_chart, title: 'Reports', subtitle: 'Daily stats & analytics', onTap: onOpenReports),
      ]),
    );
  }

  Color _planColor(SubscriptionPlan p) {
    switch (p.level) {
      case 1: return const Color(0xFF7C3AED); // Pro
      case 2: return const Color(0xFF0284C7); // Clinic
      default: return const Color(0xFF64748B); // Starter
    }
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
  final bool locked;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, this.locked = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(locked ? Icons.lock : icon, color: locked ? Colors.grey[400] : Theme.of(context).colorScheme.primary),
        title: Row(children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: locked ? Colors.grey : null)),
          if (locked) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
            ),
          ],
        ]),
        subtitle: Text(subtitle, style: TextStyle(color: locked ? Colors.grey[400] : null)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
