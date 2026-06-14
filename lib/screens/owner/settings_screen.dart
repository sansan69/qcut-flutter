import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';

/// Shop Settings — ported from QCUT Kotlin ClientSettingsScreen.kt
class SettingsScreen extends StatefulWidget {
  final Tenant tenant;
  final Function(Tenant) onSave;

  const SettingsScreen({super.key, required this.tenant, required this.onSave});

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

  // Service management
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
    _openTimeCtrl = TextEditingController(text: '09:00');
    _closeTimeCtrl = TextEditingController(text: '21:00');
    _bookingMode = widget.tenant.bookingMode;
    // Demo services
    _services.addAll([
      Service(id: 's1', name: 'Haircut', price: 150, durationMin: 30),
      Service(id: 's2', name: 'Beard Trim', price: 80, durationMin: 15),
      Service(id: 's3', name: 'Haircut + Beard', price: 200, durationMin: 45),
      Service(id: 's4', name: 'Facial', price: 250, durationMin: 40),
    ]);
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
    final slug = _nameCtrl.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return slug.isNotEmpty ? 'https://qcut.in/$slug' : 'Enter a shop name to generate booking link';
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
    setState(() {
      _services.add(Service(id: 's${_services.length + 1}', name: name, price: price, durationMin: dur));
      _svcNameCtrl.clear();
      _svcPriceCtrl.clear();
      _svcDurationCtrl.clear();
    });
    Navigator.pop(context);
  }

  void _showAddService() {
    _svcNameCtrl.clear();
    _svcPriceCtrl.clear();
    _svcDurationCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Service', style: TextStyle(color: QCutColors.navy, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _svcNameCtrl, decoration: _deco('Service Name', 'e.g. Haircut')),
          const SizedBox(height: 12),
          TextField(controller: _svcPriceCtrl, decoration: _deco('Price (₹)', '150'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _svcDurationCtrl, decoration: _deco('Duration (min)', '30'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addService, style: ElevatedButton.styleFrom(backgroundColor: QCutColors.purple, foregroundColor: Colors.white), child: const Text('Add')),
        ],
      ),
    );
  }

  InputDecoration _deco(String label, String hint) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Settings'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: QCutColors.purple,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.store, size: 18), text: 'General'),
            Tab(icon: Icon(Icons.content_cut, size: 18), text: 'Services'),
            Tab(icon: Icon(Icons.payment, size: 18), text: 'Payments'),
          ],
        ),
      ),
      body: Column(children: [
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            _buildGeneralTab(),
            _buildServicesTab(),
            _buildPaymentsTab(),
          ]),
        ),
        // Save bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle, color: QCutColors.emerald, size: 16),
                  const SizedBox(width: 6),
                  Text(_message!, style: const TextStyle(color: QCutColors.emerald, fontWeight: FontWeight.w500)),
                ]),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save All Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: QCutColors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Shop Details Card
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Shop Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: QCutColors.navy))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _bookingMode == 'token' ? QCutColors.purpleBg : QCutColors.emeraldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _bookingMode == 'token' ? 'TOKEN QUEUE' : 'APPOINTMENT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _bookingMode == 'token' ? QCutColors.purple : QCutColors.emerald, letterSpacing: 0.5),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            TextField(controller: _nameCtrl, decoration: _deco('Shop Name', 'e.g. Rajesh Salon')),
            const SizedBox(height: 16),
            TextField(controller: _addressCtrl, decoration: _deco('Address', 'Street, City, District').copyWith(prefixIcon: const Icon(Icons.location_on))),
            const SizedBox(height: 20),
            // Booking Mode Toggle
            Row(children: [
              const Text('Booking Mode', style: TextStyle(fontWeight: FontWeight.w500, color: QCutColors.charcoal)),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'token', label: Text('Token'), icon: Icon(Icons.format_list_numbered, size: 16)),
                  ButtonSegment(value: 'appointment', label: Text('Book'), icon: Icon(Icons.calendar_month, size: 16)),
                ],
                selected: {_bookingMode},
                onSelectionChanged: (v) => setState(() => _bookingMode = v.first),
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(QCutColors.purple),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            // Booking Link (read-only)
            Text('Booking Link', style: TextStyle(fontSize: 13, color: QCutColors.charcoal.withValues(alpha: 0.6))),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: QCutColors.surfaceVariant, borderRadius: BorderRadius.circular(12), border: Border.all(color: QCutColors.charcoal.withValues(alpha: 0.1))),
              child: Text(_bookingLink, style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.6))),
            ),
            if (_bookingMode == 'token') ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Text('Token Queue Hours', style: TextStyle(fontWeight: FontWeight.w600, color: QCutColors.navy)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _openTimeCtrl, decoration: _deco('Open', '09:00'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _closeTimeCtrl, decoration: _deco('Close', '21:00'))),
              ]),
            ],
          ]),
        ),
      ),
    ]);
  }

  Widget _buildServicesTab() {
    return Stack(children: [
      ListView(padding: const EdgeInsets.all(16), children: [
        ..._services.map((s) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: QCutColors.emeraldBg, child: Icon(Icons.content_cut, color: QCutColors.emerald, size: 18)),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.navy)),
            subtitle: Text('${s.durationMin} min • ₹${s.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: QCutColors.red),
              onPressed: () => setState(() => _services.removeWhere((x) => x.id == s.id)),
            ),
          ),
        )),
        if (_services.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No services. Tap + to add.', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
            ),
          ),
      ]),
      Positioned(bottom: 16, right: 16, child: FloatingActionButton(onPressed: _showAddService, backgroundColor: QCutColors.purple, child: const Icon(Icons.add, color: Colors.white))),
    ]);
  }

  Widget _buildPaymentsTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('UPI Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: QCutColors.navy)),
            const SizedBox(height: 20),
            TextField(controller: _upiIdCtrl, decoration: _deco('UPI ID', 'shopname@bank')),
            const SizedBox(height: 16),
            TextField(controller: _upiPhoneCtrl, decoration: _deco('UPI Phone', '9876543210'), keyboardType: TextInputType.phone),
          ]),
        ),
      ),
    ]);
  }
}
