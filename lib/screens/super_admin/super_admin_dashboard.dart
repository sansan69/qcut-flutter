import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';

/// Super Admin Dashboard — all tenants overview
class SuperAdminDashboard extends StatelessWidget {
  final List<Tenant> tenants;
  final VoidCallback onCreateTenant;
  final Function(Tenant) onTapTenant;
  final VoidCallback onViewOnboarding;
  final VoidCallback onSignOut;

  const SuperAdminDashboard({
    super.key,
    required this.tenants,
    required this.onCreateTenant,
    required this.onTapTenant,
    required this.onViewOnboarding,
    required this.onSignOut,
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
        title: const Text('Super Admin'),
        backgroundColor: const Color(0xFF1A0033),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: onSignOut, tooltip: 'Sign out'),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Platform stats
        Text('Platform Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1A0033))),
        const SizedBox(height: 12),
        Row(children: [
          _StatBadge(label: 'Active', value: '$active', color: QCutColors.emerald, bg: QCutColors.emeraldBg),
          const SizedBox(width: 8),
          _StatBadge(label: 'Pending', value: '$pending', color: QCutColors.amber, bg: QCutColors.amberBg),
          const SizedBox(width: 8),
          _StatBadge(label: 'Suspended', value: '$suspended', color: QCutColors.red, bg: QCutColors.redBg),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatBadge(label: 'Starter', value: '$starterCount', color: QCutColors.charcoal, bg: QCutColors.surfaceVariant),
          const SizedBox(width: 8),
          _StatBadge(label: 'Pro', value: '$proCount', color: QCutColors.purple, bg: QCutColors.purpleBg),
          const SizedBox(width: 8),
          _StatBadge(label: 'Clinic', value: '$clinicCount', color: const Color(0xFF0284C7), bg: const Color(0xFFE0F2FE)),
        ]),

        const SizedBox(height: 24),
        // Quick actions
        Row(children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_business, label: 'Create Tenant', color: QCutColors.purple, onTap: onCreateTenant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.pending_actions, label: 'Onboarding Queue', color: QCutColors.amber, onTap: onViewOnboarding,
            ),
          ),
        ]),

        const SizedBox(height: 24),
        Text('All Tenants', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1A0033))),
        const SizedBox(height: 12),

        if (tenants.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(Icons.business, size: 48, color: QCutColors.charcoal.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
                Text('No tenants yet', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
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
      ]),
    );
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
    final statusColor = tenant.status == 'active' ? QCutColors.emerald : tenant.status == 'suspended' ? QCutColors.red : QCutColors.amber;

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
              backgroundColor: QCutColors.navy,
              child: Text(tenant.name.isNotEmpty ? tenant.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: QCutColors.navy)),
              const SizedBox(height: 2),
              Text(tenant.ownerEmail, style: TextStyle(fontSize: 12, color: QCutColors.charcoal.withValues(alpha: 0.5))),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: QCutColors.purpleBg, borderRadius: BorderRadius.circular(6)),
                child: Text('₹${plan.price}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: QCutColors.purple)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(tenant.status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ]),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ),
      ),
    );
  }
}
