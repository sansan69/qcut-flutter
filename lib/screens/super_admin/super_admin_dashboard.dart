import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/q_logo_header.dart';
import '../../ui/core/qcut_components.dart';

/// Super Admin Dashboard — all tenants overview.
class SuperAdminDashboard extends StatelessWidget {
  final List<Tenant> tenants;
  final VoidCallback onCreateTenant;
  final Function(Tenant) onTapTenant;
  final VoidCallback onViewOnboarding;
  final VoidCallback onSignOut;
  final VoidCallback? onResetDatabase;
  final bool isResetting;

  const SuperAdminDashboard({
    super.key,
    required this.tenants,
    required this.onCreateTenant,
    required this.onTapTenant,
    required this.onViewOnboarding,
    required this.onSignOut,
    this.onResetDatabase,
    this.isResetting = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = tenants.where((t) => t.status == 'active').length;
    final pending = tenants.where((t) => t.status == 'pending').length;
    final suspended = tenants.where((t) => t.status == 'suspended').length;
    final starterCount = tenants.where((t) => t.planLevel == 0).length;
    final proCount = tenants.where((t) => t.planLevel == 1).length;
    final clinicCount = tenants.where((t) => t.planLevel == 2).length;

    return Scaffold(
      appBar: AppBar(
        title: const QLogoHeader(height: 28),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await HapticService.trigger(HapticType.medium);
            onSignOut();
          }, tooltip: 'Sign out'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await HapticService.trigger(HapticType.light);
        },
        child: ListView(padding: const EdgeInsets.all(20), children: [
          QSectionLabel(icon: Icons.insights, title: 'Platform Overview'),
          const SizedBox(height: 12),
          Row(children: [
            QStatCard(label: 'Active', value: '$active', color: QCutColors.success),
            const SizedBox(width: 10),
            QStatCard(label: 'Pending', value: '$pending', color: QCutColors.warning),
            const SizedBox(width: 10),
            QStatCard(label: 'Suspended', value: '$suspended', color: QCutColors.error),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            QStatCard(label: 'Starter', value: '$starterCount', color: QCutColors.onSurfaceVariant, icon: Icons.star_outline),
            const SizedBox(width: 10),
            QStatCard(label: 'Pro', value: '$proCount', color: QCutColors.primary, icon: Icons.workspace_premium),
            const SizedBox(width: 10),
            QStatCard(label: 'Clinic', value: '$clinicCount', color: QCutColors.info, icon: Icons.local_hospital),
          ]),

          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: QPrimaryButton(onPressed: onCreateTenant, icon: Icons.add_business, height: 48, child: const Text('Create Tenant', style: TextStyle(fontSize: 13)))),
            const SizedBox(width: 10),
            Expanded(child: QPrimaryButton(onPressed: onViewOnboarding, gradient: QCutGradients.accent, icon: Icons.pending_actions, height: 48, child: const Text('Onboarding', style: TextStyle(fontSize: 13)))),
          ]),

          const SizedBox(height: 28),
          QSectionLabel(icon: Icons.business, title: 'All Tenants', trailing: '${tenants.length}'),
          const SizedBox(height: 12),

          if (tenants.isEmpty)
            const QEmptyState(
              icon: Icons.business,
              title: 'No tenants yet',
              subtitle: 'Create your first tenant to get started',
            )
          else
            ...tenants.map((t) => _TenantCard(tenant: t, onTap: () => onTapTenant(t))),

          if (onResetDatabase != null) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: isResetting
                  ? const Column(children: [
                      SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                      SizedBox(height: 8),
                      Text('Wiping database...', style: TextStyle(fontSize: 12, color: QCutColors.error)),
                    ])
                  : OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Row(children: [Icon(Icons.warning_amber, color: QCutColors.error), SizedBox(width: 8), Text('Reset Database?')]),
                            content: const Text('This will permanently delete ALL tenants, tokens, bookings, barbers, services, and onboarding submissions. This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () { Navigator.pop(ctx); onResetDatabase?.call(); },
                                style: ElevatedButton.styleFrom(backgroundColor: QCutColors.error, foregroundColor: Colors.white),
                                child: const Text('Yes, Delete Everything'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever, size: 16),
                      label: const Text('Reset Database'),
                      style: OutlinedButton.styleFrom(foregroundColor: QCutColors.error, side: BorderSide(color: QCutColors.error.withValues(alpha: 0.4))),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ]),
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onTap;
  const _TenantCard({required this.tenant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final plan = tenant.plan;
    final statusColor = tenant.status == 'active' ? QCutColors.success : tenant.status == 'suspended' ? QCutColors.error : QCutColors.warning;

    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: QCutColors.primary,
            child: Text(tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: QCutColors.onSurface)),
            const SizedBox(height: 2),
            Text(tenant.ownerEmail, style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            QCountChip(label: '₹${plan.price}', color: QCutColors.primary),
            const SizedBox(height: 6),
            QCountChip(label: tenant.status.toUpperCase(), color: statusColor),
          ]),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}
