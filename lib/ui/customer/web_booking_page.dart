import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:qcut_flutter/data/repositories/booking_repository.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';
import 'package:qcut_flutter/models/shop_models.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/q_logo_header.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

class WebBookingPage extends StatefulWidget {
  final String shopSlug;
  const WebBookingPage({super.key, required this.shopSlug});

  @override
  State<WebBookingPage> createState() => _WebBookingPageState();
}

class _WebBookingPageState extends State<WebBookingPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  String? _error;
  Tenant? _tenant;
  List<Service> _services = [];
  Service? _selectedService;
  DateTime? _selectedDate;
  List<String> _timeSlots = [];
  String? _selectedSlot;
  bool _loadingSlots = false;
  bool _submitting = false;
  bool _success = false;
  String? _bookingError;

  late final BookingRepository _bookingRepo;

  @override
  void initState() {
    super.initState();
    final functions = FunctionsService(FirebaseFunctions.instance);
    _bookingRepo = BookingRepository(functions, FirebaseFirestore.instance);
    _loadTenant();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadTenant() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tenants')
          .where('slug', isEqualTo: widget.shopSlug)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() { _loading = false; _error = 'Shop not found'; });
        return;
      }
      final tenant = Tenant.fromMap(snap.docs.first.data(), snap.docs.first.id);
      setState(() { _tenant = tenant; });
      await _loadServices(tenant.id);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadServices(String tenantId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tenants').doc(tenantId)
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();
      final services = snap.docs.map((d) => Service.fromMap(d.data(), d.id)).toList();
      setState(() { _services = services; _loading = false; });
    } catch (e) {
      setState(() { _loading = false; });
    }
  }

  Future<void> _loadSlots() async {
    if (_tenant == null || _selectedService == null || _selectedDate == null) return;
    setState(() { _loadingSlots = true; _selectedSlot = null; });
    try {
      final date = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final slots = await _bookingRepo.availableSlots(
        tenantId: _tenant!.id,
        serviceId: _selectedService!.id,
        date: date,
      );
      setState(() { _timeSlots = slots; _loadingSlots = false; });
    } catch (e) {
      setState(() { _timeSlots = []; _loadingSlots = false; });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedService == null || _selectedDate == null || _selectedSlot == null) return;
    setState(() { _submitting = true; _bookingError = null; });
    try {
      final date = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      await _bookingRepo.createBooking(
        tenantId: _tenant!.id,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        serviceId: _selectedService!.id,
        date: date,
        timeSlot: _selectedSlot!,
      );
      setState(() { _submitting = false; _success = true; });
    } catch (e) {
      setState(() { _submitting = false; _bookingError = e.toString(); });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedService = null;
      _selectedDate = null;
      _timeSlots = [];
      _selectedSlot = null;
      _success = false;
      _bookingError = null;
      _nameController.clear();
      _phoneController.clear();
    });
  }

  List<DateTime> get _next7Days {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: QCutColors.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: QCutColors.surface,
        body: QEmptyState(
          icon: Icons.error_outline,
          title: 'Error loading shop',
          subtitle: _error,
          tint: QCutColors.error,
        ),
      );
    }
    if (_success) {
      return Scaffold(
        backgroundColor: QCutColors.surface,
        appBar: AppBar(
          title: const QLogoHeader(height: 28, showText: false),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: QCutGradients.success, shape: BoxShape.circle,
                  boxShadow: QCutShadows.glow(QCutColors.success),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              Text('Booking Confirmed!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('at ${_tenant?.name ?? 'Shop'}', style: const TextStyle(color: QCutColors.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text('${_selectedService?.name ?? ''} — $_selectedSlot on ${_formatDate(_selectedDate)}',
                style: const TextStyle(color: QCutColors.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 32),
              QPrimaryButton(onPressed: _resetForm, icon: Icons.add, child: const Text('Book Another')),
            ]),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: QCutColors.surface,
      appBar: AppBar(
        title: const QLogoHeader(height: 28, showText: false),
        actions: [TextButton(onPressed: () {}, child: const Text('Help'))],
      ),
      body: ListView(padding: EdgeInsets.zero, children: [
        Container(
          decoration: const BoxDecoration(gradient: QCutGradients.hero),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_tenant?.name ?? 'Shop', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(_tenant?.address ?? '', style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ]),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: QSectionLabel(icon: Icons.spa, title: 'Select Service'),
        ),
        ..._services.map((s) => QSelectionTile(
          selected: _selectedService?.id == s.id,
          onTap: () => setState(() => _selectedService = s),
          leading: QIconChip(icon: Icons.cut, color: QCutColors.primary, size: 42),
          title: Row(children: [
            Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.onSurface))),
            Text('\u20B9${s.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: QCutColors.success)),
          ]),
          subtitle: Text('${s.durationMin} min', style: const TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
        )),

        if (_selectedService != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: QSectionLabel(icon: Icons.calendar_today, title: 'Select Date'),
          ),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 7,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = _next7Days[i];
                final isToday = i == 0;
                final selected = _selectedDate != null &&
                    d.year == _selectedDate!.year &&
                    d.month == _selectedDate!.month &&
                    d.day == _selectedDate!.day;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = d);
                    _loadSlots();
                  },
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      color: selected ? QCutColors.primary : QCutColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? QCutColors.primary : QCutColors.outlineVariant, width: selected ? 1.5 : 1),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d.weekday-1],
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: selected ? Colors.white70 : QCutColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text('${d.day}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: selected ? Colors.white : QCutColors.onSurface)),
                      Text(isToday ? 'Today' : _monthShort(d.month),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: selected ? Colors.white70 : QCutColors.onSurfaceVariant)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],

        if (_selectedDate != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: QSectionLabel(icon: Icons.access_time, title: _loadingSlots ? 'Loading slots...' : 'Select Time'),
          ),
          if (_loadingSlots)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_timeSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: QEmptyState(
                icon: Icons.event_busy,
                title: 'No slots available',
                subtitle: 'Try a different date or service.',
                tint: QCutColors.onSurfaceVariant,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(spacing: 10, runSpacing: 10, children: _timeSlots.map((slot) {
                final selected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? QCutColors.primary : QCutColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? QCutColors.primary : QCutColors.outlineVariant, width: selected ? 1.5 : 1),
                    ),
                    child: Text(slot, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : QCutColors.onSurface,
                    )),
                  ),
                );
              }).toList()),
            ),
        ],

        if (_selectedSlot != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: QSectionLabel(icon: Icons.person, title: 'Your Details'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    hintText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    if (v.trim().length < 10) return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: QPrimaryButton(
              onPressed: _submitting ? null : _submitBooking,
              icon: Icons.check_circle,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm Booking'),
            ),
          ),
          if (_bookingError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(_bookingError!, style: const TextStyle(color: QCutColors.error, fontSize: 13)),
            ),
        ],
        const SizedBox(height: 40),
      ]),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }

  String _monthShort(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}
