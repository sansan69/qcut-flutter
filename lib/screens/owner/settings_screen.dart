import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_models.dart';
import '../../services/slug_utils.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Shop Settings — general / services / payments tabs.
class SettingsScreen extends StatefulWidget {
  final Tenant tenant;
  final Function(Tenant) onSave;
  final List<Service> services;
  final Function(Service)? onAddService;
  final Function(String)? onDeleteService;

  const SettingsScreen({
    super.key,
    required this.tenant,
    required this.onSave,
    this.services = const [],
    this.onAddService,
    this.onDeleteService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _upiIdCtrl;
  late TextEditingController _upiPhoneCtrl;
  late TextEditingController _openTimeCtrl;
  late TextEditingController _closeTimeCtrl;
  late String _bookingMode;

  final List<Service> _services = [];
  final _svcNameCtrl = TextEditingController();
  final _svcPriceCtrl = TextEditingController();
  final _svcDurationCtrl = TextEditingController();
  String? _message;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _nameCtrl = TextEditingController(text: widget.tenant.name);
    _addressCtrl = TextEditingController(text: widget.tenant.address);
    _upiIdCtrl = TextEditingController(text: '');
    _upiPhoneCtrl = TextEditingController(text: widget.tenant.phone);
    _openTimeCtrl = TextEditingController(text: widget.tenant.openTime ?? '09:00');
    _closeTimeCtrl = TextEditingController(text: widget.tenant.closeTime ?? '21:00');
    _bookingMode = widget.tenant.bookingMode;
    if (widget.services.isNotEmpty) {
      _services.addAll(widget.services);
    } else {
      _services.addAll([
        Service(id: 's1', name: 'Haircut', price: 150, durationMin: 30),
        Service(id: 's2', name: 'Beard Trim', price: 80, durationMin: 15),
        Service(id: 's3', name: 'Haircut + Beard', price: 200, durationMin: 45),
        Service(id: 's4', name: 'Facial', price: 250, durationMin: 40),
      ]);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _upiIdCtrl.dispose();
    _upiPhoneCtrl.dispose();
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    _svcNameCtrl.dispose();
    _svcPriceCtrl.dispose();
    _svcDurationCtrl.dispose();
    super.dispose();
  }

  String get _bookingLink {
    final slug = widget.tenant.slug ?? generateSlug(widget.tenant.name);
    return slug.isNotEmpty ? '$qcutBookingBaseUrl/s/$slug' : 'Enter a shop name to generate booking link';
  }

  void _save() {
    HapticFeedback.mediumImpact();
    final updated = Tenant(
      id: widget.tenant.id,
      name: _nameCtrl.text.trim(),
      ownerEmail: widget.tenant.ownerEmail,
      businessType: widget.tenant.businessType,
      planLevel: widget.tenant.planLevel,
      status: widget.tenant.status,
      bookingMode: _bookingMode,
      phone: _upiPhoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      openTime: _openTimeCtrl.text.trim(),
      closeTime: _closeTimeCtrl.text.trim(),
    );
    widget.onSave(updated);
    setState(() => _message = 'Settings saved successfully');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _addService() {
    final name = _svcNameCtrl.text.trim();
    final price = int.tryParse(_svcPriceCtrl.text) ?? 0;
    final dur = int.tryParse(_svcDurationCtrl.text) ?? 30;
    if (name.isEmpty) return;
    final svc = Service(id: 's${DateTime.now().millisecondsSinceEpoch}', name: name, price: price, durationMin: dur);
    setState(() {
      _services.add(svc);
      _svcNameCtrl.clear();
      _svcPriceCtrl.clear();
      _svcDurationCtrl.clear();
    });
    widget.onAddService?.call(svc);
    Navigator.pop(context);
  }

  void _showAddService() {
    _svcNameCtrl.clear();
    _svcPriceCtrl.clear();
    _svcDurationCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Service'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _svcNameCtrl, decoration: _deco('Service Name', 'e.g. Haircut')),
          const SizedBox(height: 12),
          TextField(controller: _svcPriceCtrl, decoration: _deco('Price (₹)', '150'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _svcDurationCtrl, decoration: _deco('Duration (min)', '30'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addService, child: const Text('Add')),
        ],
      ),
    );
  }

  InputDecoration _deco(String label, String hint) => InputDecoration(labelText: label, hintText: hint);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Settings'),
        bottom: TabBar(controller: _tabCtrl, tabs: const [
          Tab(icon: Icon(Icons.store, size: 18), text: 'General'),
          Tab(icon: Icon(Icons.content_cut, size: 18), text: 'Services'),
          Tab(icon: Icon(Icons.payment, size: 18), text: 'Payments'),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            _buildGeneralTab(),
            _buildServicesTab(),
            _buildPaymentsTab(),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: QCutColors.surface, border: Border(top: BorderSide(color: QCutColors.outlineVariant))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle, color: QCutColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text(_message!, style: const TextStyle(color: QCutColors.success, fontWeight: FontWeight.w600)),
                ]),
              ),
            QPrimaryButton(onPressed: _save, icon: Icons.save, child: const Text('Save All Changes')),
          ]),
        ),
      ]),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(padding: const EdgeInsets.all(20), children: [
      QGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Shop Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: QCutColors.onSurface))),
            QCountChip(
              label: _bookingMode == 'token' ? 'TOKEN QUEUE' : 'APPOINTMENT',
              color: _bookingMode == 'token' ? QCutColors.primary : QCutColors.success,
            ),
          ]),
          const SizedBox(height: 20),
          TextField(controller: _nameCtrl, decoration: _deco('Shop Name', 'e.g. Rajesh Salon')),
          const SizedBox(height: 16),
          TextField(controller: _addressCtrl, decoration: _deco('Address', 'Street, City, District').copyWith(prefixIcon: const Icon(Icons.location_on))),
          const SizedBox(height: 20),
          Row(children: [
            const Text('Booking Mode', style: TextStyle(fontWeight: FontWeight.w600, color: QCutColors.onSurfaceVariant)),
            const Spacer(),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'token', label: Text('Token'), icon: Icon(Icons.format_list_numbered, size: 16)),
                ButtonSegment(value: 'appointment', label: Text('Book'), icon: Icon(Icons.calendar_month, size: 16)),
              ],
              selected: {_bookingMode},
              onSelectionChanged: (v) => setState(() => _bookingMode = v.first),
            ),
          ]),
          const SizedBox(height: 20),
          const Text('Booking Link', style: TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: QCutColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12), border: Border.all(color: QCutColors.outlineVariant)),
            child: Text(_bookingLink, style: const TextStyle(color: QCutColors.primary, fontWeight: FontWeight.w500)),
          ),
          if (_bookingMode == 'token') ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Token Queue Hours', style: TextStyle(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _openTimeCtrl, decoration: _deco('Open', '09:00'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _closeTimeCtrl, decoration: _deco('Close', '21:00'))),
            ]),
          ],
        ]),
      ),
    ]);
  }

  Widget _buildServicesTab() {
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(20), children: [
        ..._services.map((s) => QGlassCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: QIconChip(icon: Icons.content_cut, color: QCutColors.success, size: 40),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
            subtitle: Text('${s.durationMin} min • ₹${s.price}', style: const TextStyle(color: QCutColors.onSurfaceVariant)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: QCutColors.error),
              onPressed: () {
                final id = s.id;
                setState(() => _services.removeWhere((x) => x.id == id));
                widget.onDeleteService?.call(id);
              },
            ),
          ),
        )),
        if (_services.isEmpty)
          const QEmptyState(icon: Icons.content_cut, title: 'No services yet', subtitle: 'Tap + to add your first service.'),
      ]),
      Positioned(bottom: 20, right: 20, child: FloatingActionButton(onPressed: _showAddService, child: const Icon(Icons.add))),
    ]);
  }

  Widget _buildPaymentsTab() {
    return ListView(padding: const EdgeInsets.all(20), children: [
      QGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('UPI Payment Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: QCutColors.onSurface)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: QCutColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Coming Soon', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: QCutColors.warning)),
            ),
          ]),
          const SizedBox(height: 20),
          TextField(controller: _upiIdCtrl, decoration: _deco('UPI ID', 'shopname@bank')),
          const SizedBox(height: 16),
          TextField(controller: _upiPhoneCtrl, decoration: _deco('UPI Phone', '9876543210'), keyboardType: TextInputType.phone),
        ]),
      ),
    ]);
  }
}
