import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/q_logo_header.dart';

/// Super Admin Dashboard — all tenants overview
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
        child: ListView(padding: const EdgeInsets.all(16), children: [
        // Platform stats
        Text('Platform Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: QCutColors.onSurface)),
        const SizedBox(height: 12),
        Row(children: [
          _StatBadge(label: 'Active', value: '$active', color: QCutColors.success, bg: QCutColors.success.withValues(alpha: 0.15)),
          const SizedBox(width: 8),
          _StatBadge(label: 'Pending', value: '$pending', color: QCutColors.warning, bg: QCutColors.warning.withValues(alpha: 0.15)),
          const SizedBox(width: 8),
          _StatBadge(label: 'Suspended', value: '$suspended', color: QCutColors.error, bg: QCutColors.error.withValues(alpha: 0.15)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatBadge(label: 'Starter', value: '$starterCount', color: QCutColors.onSurfaceVariant, bg: QCutColors.surfaceContainer),
          const SizedBox(width: 8),
          _StatBadge(label: 'Pro', value: '$proCount', color: QCutColors.primary, bg: QCutColors.primaryContainer),
          const SizedBox(width: 8),
          _StatBadge(label: 'Clinic', value: '$clinicCount', color: QCutColors.secondary, bg: QCutColors.secondaryContainer),
        ]),

        const SizedBox(height: 24),
        // Quick actions
        Row(children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_business, label: 'Create Tenant', color: QCutColors.primary, onTap: onCreateTenant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.pending_actions, label: 'Onboarding Queue', color: QCutColors.warning, onTap: onViewOnboarding,
            ),
          ),
        ]),

        const SizedBox(height: 24),
        Text('All Tenants', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: QCutColors.onSurface)),
        const SizedBox(height: 12),

        if (tenants.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(Icons.business, size: 48, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No tenants yet', style: TextStyle(color: QCutColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onCreateTenant,
                  icon: const Icon(Icons.add),
                  label: const Text('Create your first tenant'),
                ),
              ]),
            ),
          )
        else
          ...tenants.map((t) => _TenantCard(tenant: t, onTap: () => onTapTenant(t))),

        // ── Reset Database (danger zone) ──
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    style: OutlinedButton.styleFrom(foregroundColor: QCutColors.error, side: const BorderSide(color: QCutColors.error)),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ]),
    ));
  }
}

class _StatBadge extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _StatBadge({required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: QCutColors.primary,
              child: Text(tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: QCutColors.onSurface)),
              const SizedBox(height: 2),
              Text(tenant.ownerEmail, style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: QCutColors.primaryContainer, borderRadius: BorderRadius.circular(6)),
                child: Text('₹${plan.price}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: QCutColors.primary)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(tenant.status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ]),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}