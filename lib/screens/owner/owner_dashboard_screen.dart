import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Owner dashboard — branded gradient header, KPI row, and quick-action cards.
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
    return Scaffold(
      backgroundColor: QCutColors.surface,
      body: ListView(padding: EdgeInsets.zero, children: [
        // ── Branded gradient header ──
        Container(
          decoration: const BoxDecoration(gradient: QCutGradients.hero),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome back', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(tenant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  QCountChip(label: plan.name, color: _planColor(plan), filled: true),
                  IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: onSignOut, tooltip: 'Sign out'),
                ]),
                const SizedBox(height: 24),
                // KPI row
                Row(children: [
                  QStatCard(value: waitingCount.toString(), label: 'Waiting', color: QCutColors.primary, icon: Icons.hourglass_top),
                  const SizedBox(width: 10),
                  QStatCard(value: servingCount.toString(), label: 'Serving', color: QCutColors.success, icon: Icons.cut),
                  const SizedBox(width: 10),
                  QStatCard(value: completedCount.toString(), label: 'Done', color: QCutColors.secondary, icon: Icons.check_circle),
                ]),
              ]),
            ),
          ),
        ),

        // ── Quick actions ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: QSectionLabel(icon: Icons.bolt, title: 'Quick Actions'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _ActionCard(icon: Icons.format_list_numbered, title: 'Token Queue', subtitle: 'Now Serving / Waiting / Completed', onTap: onOpenQueue, accent: QCutColors.primary),
            _ActionCard(
              icon: Icons.calendar_month,
              title: 'Bookings',
              subtitle: plan.appointments ? 'Appointments & calendar' : 'Upgrade to Pro/Clinic',
              locked: !plan.appointments,
              onTap: onOpenBookings,
              accent: QCutColors.secondary,
            ),
            _ActionCard(icon: Icons.people, title: 'Staff', subtitle: 'Manage barbers & schedule', onTap: onOpenStaff, accent: QCutColors.success),
            _ActionCard(
              icon: Icons.qr_code,
              title: 'Shop QR',
              subtitle: plan.qrCode ? 'Display for customer scanning' : 'Upgrade to Pro/Clinic',
              locked: !plan.qrCode,
              onTap: onOpenQR,
              accent: QCutColors.info,
            ),
            _ActionCard(icon: Icons.bar_chart, title: 'Reports', subtitle: 'Daily stats & analytics', onTap: onOpenReports, accent: QCutColors.warning),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Color _planColor(SubscriptionPlan p) {
    switch (p.level) {
      case 1: return QCutColors.secondary; // Pro
      case 2: return QCutColors.info; // Clinic
      default: return QCutColors.onSurfaceVariant; // Starter
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool locked;
  final VoidCallback onTap;
  final Color accent;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.locked = false,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = locked ? QCutColors.onSurfaceVariant : accent;
    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(children: [
        QIconChip(icon: locked ? Icons.lock : icon, color: color, size: 46),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: locked ? QCutColors.onSurfaceVariant : QCutColors.onSurface)),
            if (locked) ...[
              const SizedBox(width: 8),
              QCountChip(label: 'PRO', color: QCutColors.secondary),
            ],
          ]),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant, height: 1.3)),
        ])),
        Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
      ]),
    );
  }
}
