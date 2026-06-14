import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';

/// Super Admin: Create new tenant with plan selection
class CreateTenantScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreate;

  const CreateTenantScreen({super.key, required this.onCreate});

  @override
  State<CreateTenantScreen> createState() => _CreateTenantScreenState();
}

class _CreateTenantScreenState extends State<CreateTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _businessType = 'salon';
  String _bookingMode = 'token';
  int _planLevel = 0;
  String _openTime = '09:00';
  String _closeTime = '21:00';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _ownerNameCtrl.dispose(); _ownerPhoneCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _saving = true; _error = null; });
    HapticFeedback.mediumImpact();

    final data = {
      'name': _nameCtrl.text.trim(),
      'ownerEmail': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'ownerName': _ownerNameCtrl.text.trim(),
      'ownerPhone': _ownerPhoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'businessType': _businessType,
      'bookingMode': _bookingMode,
      'planLevel': _planLevel,
      'openTime': _openTime,
      'closeTime': _closeTime,
    };

    widget.onCreate(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tenant'),
        backgroundColor: const Color(0xFF1A0033),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // ── Business Info ──
          _SectionTitle('Business Information'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameCtrl,
            decoration: _deco('Business Name *', 'e.g. Rajesh Salon'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailCtrl,
            decoration: _deco('Owner Email (Gmail) *', 'owner@gmail.com'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            decoration: _deco('Business Phone *', '9876543210'),
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.length < 10) ? '10 digits required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _ownerNameCtrl,
            decoration: _deco('Owner Name', 'e.g. Rajesh Kumar'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _ownerPhoneCtrl,
            decoration: _deco('Owner Phone', '9876543210'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _addressCtrl,
            decoration: _deco('Address', 'Street, City, District'),
            maxLines: 2,
          ),

          const SizedBox(height: 14),
          // Business type
          DropdownButtonFormField<String>(
            value: _businessType,
            decoration: _deco('Business Type', ''),
            items: const [
              DropdownMenuItem(value: 'salon', child: Text('Salon')),
              DropdownMenuItem(value: 'barbershop', child: Text('Barbershop')),
              DropdownMenuItem(value: 'spa', child: Text('Spa')),
              DropdownMenuItem(value: 'clinic', child: Text('Clinic')),
              DropdownMenuItem(value: 'dental', child: Text('Dental Clinic')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _businessType = v ?? 'salon'),
          ),

          const SizedBox(height: 24),
          // ── Booking Mode ──
          _SectionTitle('Booking Mode'),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'token', label: Text('Token Queue'), icon: Icon(Icons.format_list_numbered, size: 16)),
              ButtonSegment(value: 'appointment', label: Text('Appointment'), icon: Icon(Icons.calendar_month, size: 16)),
            ],
            selected: {_bookingMode},
            onSelectionChanged: (v) => setState(() => _bookingMode = v.first),
          ),

          // Hours (for token mode)
          if (_bookingMode == 'token') ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: TextFormField(
                initialValue: _openTime,
                decoration: _deco('Open', '09:00'),
                onChanged: (v) => _openTime = v,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                initialValue: _closeTime,
                decoration: _deco('Close', '21:00'),
                onChanged: (v) => _closeTime = v,
              )),
            ]),
          ],

          const SizedBox(height: 24),
          // ── Subscription Plan ──
          _SectionTitle('Subscription Plan'),
          const SizedBox(height: 12),
          ...SubscriptionPlan.values.map((p) => _PlanCard(
            plan: p, isSelected: _planLevel == p.level,
            onTap: () => setState(() => _planLevel = p.level),
          )),

          const SizedBox(height: 32),
          // ── Submit ──
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: QCutColors.redBg, borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: QCutColors.red, fontSize: 13)),
            ),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: QCutColors.purple, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Create Tenant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  InputDecoration _deco(String label, String hint) => InputDecoration(
    labelText: label, hintText: hint,
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: QCutColors.navy));
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  const _PlanCard({required this.plan, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isSelected ? QCutColors.purple : Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: isSelected ? QCutColors.purpleBg : QCutColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('₹${plan.price}', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? QCutColors.purple : QCutColors.charcoal))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: QCutColors.navy)),
              const SizedBox(height: 2),
              Text('${plan.maxBarbers} barbers • ${plan.maxServices} services • ${plan.appointments ? "Appointments" : "Token only"}',
                style: TextStyle(fontSize: 12, color: QCutColors.charcoal.withValues(alpha: 0.5))),
            ])),
            if (isSelected)
              Container(width: 28, height: 28, decoration: const BoxDecoration(color: QCutColors.purple, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16)),
          ]),
        ),
      ),
    );
  }
}
