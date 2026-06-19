import 'package:flutter/material.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

class ProviderDashboardScreen extends StatelessWidget {
  final Future<void> Function()? onRefresh;
  final int waitingCount;
  final int servingCount;
  final int completedCount;
  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenStaff;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenQR;

  const ProviderDashboardScreen({
    super.key,
    this.onRefresh,
    this.waitingCount = 0,
    this.servingCount = 0,
    this.completedCount = 0,
    this.onOpenQueue,
    this.onOpenStaff,
    this.onOpenCalendar,
    this.onOpenQR,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCutColors.surface,
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: ListView(padding: EdgeInsets.zero, children: [
          Container(
            decoration: const BoxDecoration(gradient: QCutGradients.hero),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const QLogoHeader(height: 28, textColor: Colors.white),
                  ]),
                  const SizedBox(height: 24),
                  Text("Today's Overview", style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: QSectionLabel(icon: Icons.bolt, title: 'Quick Actions'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              _ActionCard(
                icon: Icons.format_list_numbered,
                title: 'Open Queue',
                subtitle: 'Now Serving / Waiting / Completed',
                onTap: onOpenQueue ?? () {},
                accent: QCutColors.primary,
              ),
              _ActionCard(
                icon: Icons.people,
                title: 'Manage Staff',
                subtitle: 'Barbers, schedules & services',
                onTap: onOpenStaff ?? () {},
                accent: QCutColors.success,
              ),
              _ActionCard(
                icon: Icons.calendar_month,
                title: 'Calendar',
                subtitle: 'View & manage appointments',
                onTap: onOpenCalendar ?? () {},
                accent: QCutColors.secondary,
              ),
              _ActionCard(
                icon: Icons.qr_code,
                title: 'QR Code',
                subtitle: 'Display for customer scanning',
                onTap: onOpenQR ?? () {},
                accent: QCutColors.info,
              ),
            ]),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(children: [
        QIconChip(icon: icon, color: accent, size: 46),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: QCutColors.onSurface)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant, height: 1.3)),
        ])),
        Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
      ]),
    );
  }
}
