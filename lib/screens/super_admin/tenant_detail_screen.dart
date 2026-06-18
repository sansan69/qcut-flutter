import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Super Admin: Tenant detail view — plan change, suspend/activate.
class TenantDetailScreen extends StatefulWidget {
  final Tenant tenant;
  final Function(int planLevel) onUpdatePlan;
  final Function(String status) onUpdateStatus;

  const TenantDetailScreen({
    super.key,
    required this.tenant,
    required this.onUpdatePlan,
    required this.onUpdateStatus,
  });

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  late Tenant _tenant;

  @override
  void initState() {
    super.initState();
    _tenant = widget.tenant;
  }

  @override
  Widget build(BuildContext context) {
    final plan = _tenant.plan;
    final isActive = _tenant.status == 'active';

    return Scaffold(
      appBar: AppBar(title: Text(_tenant.name)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Status banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isActive ? QCutColors.success : QCutColors.error).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (isActive ? QCutColors.success : QCutColors.error).withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(isActive ? Icons.check_circle : Icons.block, color: isActive ? QCutColors.success : QCutColors.error),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tenant.status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w800, color: isActive ? QCutColors.success : QCutColors.error, letterSpacing: 0.5)),
              Text(isActive ? 'Tenant is active and operational' : 'Tenant is suspended', style: TextStyle(fontSize: 12, color: (isActive ? QCutColors.success : QCutColors.error).withValues(alpha: 0.8))),
            ])),
            if (isActive)
              TextButton(
                onPressed: () {
                  widget.onUpdateStatus('suspended');
                  setState(() => _tenant = Tenant(id: _tenant.id, name: _tenant.name, ownerEmail: _tenant.ownerEmail, businessType: _tenant.businessType, planLevel: _tenant.planLevel, status: 'suspended', bookingMode: _tenant.bookingMode, phone: _tenant.phone, address: _tenant.address, ownerName: _tenant.ownerName, ownerPhone: _tenant.ownerPhone, district: _tenant.district, city: _tenant.city, openTime: _tenant.openTime, closeTime: _tenant.closeTime));
                },
                child: const Text('Suspend', style: TextStyle(color: QCutColors.error, fontWeight: FontWeight.w600)),
              )
            else
              TextButton(
                onPressed: () {
                  widget.onUpdateStatus('active');
                  setState(() => _tenant = Tenant(id: _tenant.id, name: _tenant.name, ownerEmail: _tenant.ownerEmail, businessType: _tenant.businessType, planLevel: _tenant.planLevel, status: 'active', bookingMode: _tenant.bookingMode, phone: _tenant.phone, address: _tenant.address, ownerName: _tenant.ownerName, ownerPhone: _tenant.ownerPhone, district: _tenant.district, city: _tenant.city, openTime: _tenant.openTime, closeTime: _tenant.closeTime));
                },
                child: const Text('Activate', style: TextStyle(color: QCutColors.success, fontWeight: FontWeight.w600)),
              ),
          ],
          ),
        ),

        const SizedBox(height: 24),
        QSectionLabel(icon: Icons.store, title: 'Business Details'),
        const SizedBox(height: 12),
        QGlassCard(
          child: Column(children: [
            _DetailRow('Name', _tenant.name),
            _DetailRow('Owner Email', _tenant.ownerEmail),
            if (_tenant.ownerName != null) _DetailRow('Owner', _tenant.ownerName!),
            _DetailRow('Phone', _tenant.phone),
            _DetailRow('Address', _tenant.address),
            _DetailRow('Business Type', _tenant.businessType),
            _DetailRow('Booking Mode', _tenant.bookingMode == 'token' ? 'Token Queue' : 'Appointment'),
            if (_tenant.openTime != null) _DetailRow('Hours', '${_tenant.openTime} – ${_tenant.closeTime ?? "21:00"}'),
          ]),
        ),

        const SizedBox(height: 24),
        QSectionLabel(icon: Icons.workspace_premium, title: 'Subscription Plan'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: QCutColors.primaryTint, borderRadius: BorderRadius.circular(14), border: Border.all(color: QCutColors.primary.withValues(alpha: 0.3))),
          child: Column(children: [
            Row(children: [
              Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: QCutColors.primary)),
              const Spacer(),
              Text('₹${plan.price}/mo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: QCutColors.primary)),
            ]),
            const SizedBox(height: 12),
            Text('${plan.maxBarbers} barbers • ${plan.maxServices} services • ${plan.appointments ? "Appointments + QR" : "Token only"}',
              style: TextStyle(fontSize: 13, color: QCutColors.primary.withValues(alpha: 0.8))),
            const SizedBox(height: 16),
            Text('Change Plan', style: TextStyle(fontSize: 13, color: QCutColors.primary.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: SubscriptionPlan.values.map((p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(p.name, style: const TextStyle(fontSize: 11)),
                  selected: _tenant.planLevel == p.level,
                  onSelected: (v) {
                    if (v) {
                      widget.onUpdatePlan(p.level);
                      setState(() => _tenant = Tenant(id: _tenant.id, name: _tenant.name, ownerEmail: _tenant.ownerEmail, businessType: _tenant.businessType, planLevel: p.level, status: _tenant.status, bookingMode: _tenant.bookingMode, phone: _tenant.phone, address: _tenant.address, ownerName: _tenant.ownerName, ownerPhone: _tenant.ownerPhone, district: _tenant.district, city: _tenant.city, openTime: _tenant.openTime, closeTime: _tenant.closeTime));
                    }
                  },
                ),
              ),
            )).toList()),
          ]),
        ),

        const SizedBox(height: 32),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: QCutColors.onSurface))),
      ]),
    );
  }
}
