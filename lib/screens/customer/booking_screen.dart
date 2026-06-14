import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/booking.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';

/// Full booking flow — date picker, time slots, barber, service, confirmation
class BookingScreen extends StatefulWidget {
  final List<Barber> barbers;
  final List<Service> services;
  final String tenantId;
  final String tenantName;
  final Function(Booking) onBook;

  const BookingScreen({
    super.key,
    required this.barbers,
    required this.services,
    required this.tenantId,
    required this.tenantName,
    required this.onBook,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  static const _steps = ['Service', 'Date & Time', 'Barber', 'Details', 'Confirm'];

  // Selections
  Service? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  Barber? _selectedBarber;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;

  // Time slots (30-min intervals from 9:00 to 20:30)
  List<String> get _timeSlots {
    final slots = <String>[];
    for (int h = 9; h < 21; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
      slots.add('${h.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  // Available dates (next 30 days, no Sundays)
  List<DateTime> get _availableDates {
    final dates = <DateTime>[];
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final d = DateTime(today.year, today.month, today.day + i);
      if (d.weekday != DateTime.sunday) dates.add(d);
    }
    return dates;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _canProceed() {
    switch (_step) {
      case 0: return _selectedService != null;
      case 1: return _selectedDate != null && _selectedTimeSlot != null;
      case 2: return _selectedBarber != null;
      case 3: return _nameCtrl.text.trim().isNotEmpty;
      case 4: return true;
      default: return false;
    }
  }

  void _next() {
    if (!_canProceed()) {
      setState(() => _error = 'Please complete all selections');
      return;
    }
    setState(() { _error = null; _step++; });
  }

  void _prev() => setState(() { if (_step > 0) _step--; _error = null; });

  void _confirm() {
    HapticFeedback.heavyImpact();
    final booking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: widget.tenantId,
      customerName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      barberId: _selectedBarber!.id,
      barberName: _selectedBarber!.name,
      date: '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      timeSlot: _selectedTimeSlot!,
      status: 'confirmed',
      serviceType: _selectedService!.name,
      bookingCode: 'QC-${(100 + widget.barbers.indexOf(_selectedBarber!) * 10 + (DateTime.now().second % 90)).toString()}',
      durationMin: _selectedService!.durationMin,
      createdAt: DateTime.now(),
    );
    widget.onBook(booking);

    // Show confirmation
    setState(() => _step = 5);
  }

  @override
  Widget build(BuildContext context) {
    // Confirmation screen
    if (_step == 5) return _ConfirmationScreen(
      service: _selectedService!.name,
      date: _formatDate(_selectedDate!),
      time: _selectedTimeSlot!,
      barber: _selectedBarber!.name,
      name: _nameCtrl.text.trim(),
      onDone: () => Navigator.pop(context),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Book — ${widget.tenantName}'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(_step > 0 ? Icons.arrow_back : Icons.close),
          onPressed: _step > 0 ? _prev : () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        // Step indicator
        _StepIndicator(currentStep: _step, steps: _steps),
        // Error
        if (_error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: QCutColors.redBg, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: QCutColors.red, size: 16),
              const SizedBox(width: 8),
              Text(_error!, style: const TextStyle(color: QCutColors.red, fontSize: 13)),
            ]),
          ),
        // Content
        Expanded(child: _buildStep()),
        // Bottom nav
        _BottomBar(
          canProceed: _canProceed(),
          isLast: _step == 4,
          onBack: _step > 0 ? _prev : null,
          onNext: _step < 4 ? _next : _confirm,
          nextLabel: _step == 4 ? 'Confirm Booking' : 'Next',
        ),
      ]),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _ServiceStep(services: widget.services, selected: _selectedService, onSelect: (s) => setState(() => _selectedService = s));
      case 1: return _DateTimeStep(dates: _availableDates, slots: _timeSlots, selectedDate: _selectedDate, selectedSlot: _selectedTimeSlot, onDatePicked: (d) => setState(() => _selectedDate = d), onSlotPicked: (s) => setState(() => _selectedTimeSlot = s));
      case 2: return _BarberStep(barbers: widget.barbers, selected: _selectedBarber, onSelect: (b) => setState(() => _selectedBarber = b));
      case 3: return _DetailsStep(formKey: _formKey, nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl);
      case 4: return _SummaryStep(service: _selectedService!.name, date: _formatDate(_selectedDate!), time: _selectedTimeSlot!, barber: _selectedBarber!.name, duration: _selectedService!.durationMin, name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
      default: return const SizedBox();
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ──────────────────────────────────────────────
// Step 0: Service Selection
// ──────────────────────────────────────────────
class _ServiceStep extends StatelessWidget {
  final List<Service> services;
  final Service? selected;
  final Function(Service) onSelect;

  const _ServiceStep({required this.services, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Select a Service', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 4),
      Text('Choose what you\'d like to book', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
      const SizedBox(height: 20),
      ...services.map((s) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected?.id == s.id ? QCutColors.purple : Colors.transparent, width: 2),
        ),
        child: InkWell(
          onTap: () => onSelect(s),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: QCutColors.emeraldBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.content_cut, color: QCutColors.emerald, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: QCutColors.navy)),
                const SizedBox(height: 2),
                Text('${s.durationMin} min • ₹${s.price}', style: TextStyle(fontSize: 13, color: QCutColors.charcoal.withValues(alpha: 0.5))),
              ])),
              if (selected?.id == s.id)
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(color: QCutColors.purple, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ]),
          ),
        ),
      )),
    ]);
  }
}

// ──────────────────────────────────────────────
// Step 1: Date & Time
// ──────────────────────────────────────────────
class _DateTimeStep extends StatefulWidget {
  final List<DateTime> dates;
  final List<String> slots;
  final DateTime? selectedDate;
  final String? selectedSlot;
  final Function(DateTime) onDatePicked;
  final Function(String?) onSlotPicked;

  const _DateTimeStep({
    required this.dates, required this.slots,
    required this.selectedDate, required this.selectedSlot,
    required this.onDatePicked, required this.onSlotPicked,
  });

  @override
  State<_DateTimeStep> createState() => _DateTimeStepState();
}

class _DateTimeStepState extends State<_DateTimeStep> {
  late ScrollController _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    // Scroll to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todayIdx = widget.dates.indexWhere((d) =>
        d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year);
      if (todayIdx >= 0 && _scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(todayIdx * 76.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Pick a Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 4),
      Text('Available dates (Mon–Sat)', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
      const SizedBox(height: 16),
      // Horizontal date strip
      SizedBox(
        height: 80,
        child: ListView.builder(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          itemCount: widget.dates.length,
          itemBuilder: (_, i) {
            final d = widget.dates[i];
            final isToday = d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year;
            final isSelected = widget.selectedDate != null &&
              d.day == widget.selectedDate!.day && d.month == widget.selectedDate!.month && d.year == widget.selectedDate!.year;
            return GestureDetector(
              onTap: () { widget.onDatePicked(d); widget.onSlotPicked(null); },
              child: Container(
                width: 64, height: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected ? QCutColors.purple : (isToday ? QCutColors.purpleBg : QCutColors.surfaceVariant),
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected ? Border.all(color: QCutColors.purple, width: 2) : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(isToday ? 'Today' : _dayAbbr(d.weekday),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : QCutColors.charcoal.withValues(alpha: 0.6))),
                  const SizedBox(height: 4),
                  Text('${d.day}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : QCutColors.navy)),
                  Text(_monthAbbr(d.month), style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : QCutColors.charcoal.withValues(alpha: 0.4))),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 28),
      // Time slots
      if (widget.selectedDate != null) ...[
        const Text('Pick a Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
        const SizedBox(height: 4),
        Text('30-minute slots from 9:00 AM to 9:00 PM', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.slots.map((slot) {
            final isSelected = widget.selectedSlot == slot;
            return GestureDetector(
              onTap: () => widget.onSlotPicked(slot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? QCutColors.purple : QCutColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: QCutColors.purple, width: 2) : null,
                ),
                child: Text(
                  _formatTime(slot),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : QCutColors.charcoal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ]);
  }

  String _dayAbbr(int wd) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1];
  String _monthAbbr(int m) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
  String _formatTime(String t) {
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $ampm';
  }
}

// ──────────────────────────────────────────────
// Step 2: Barber Selection
// ──────────────────────────────────────────────
class _BarberStep extends StatelessWidget {
  final List<Barber> barbers;
  final Barber? selected;
  final Function(Barber) onSelect;

  const _BarberStep({required this.barbers, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Choose Your Barber', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 4),
      Text('Select who you\'d like', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
      const SizedBox(height: 20),
      ...barbers.where((b) => b.isActive).map((b) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected?.id == b.id ? QCutColors.purple : Colors.transparent, width: 2),
        ),
        child: InkWell(
          onTap: () => onSelect(b),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: QCutColors.navy,
                child: Text(b.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: QCutColors.navy))),
              if (selected?.id == b.id)
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(color: QCutColors.purple, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ]),
          ),
        ),
      )),
    ]);
  }
}

// ──────────────────────────────────────────────
// Step 3: Customer Details
// ──────────────────────────────────────────────
class _DetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  const _DetailsStep({required this.formKey, required this.nameCtrl, required this.phoneCtrl});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Your Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
        const SizedBox(height: 4),
        Text('We\'ll save these for your booking', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
        const SizedBox(height: 24),
        TextFormField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneCtrl,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          keyboardType: TextInputType.phone,
        ),
      ]),
    );
  }
}

// ──────────────────────────────────────────────
// Step 4: Summary & Confirm
// ──────────────────────────────────────────────
class _SummaryStep extends StatelessWidget {
  final String service, date, time, barber, name;
  final int duration;
  final String phone;

  const _SummaryStep({
    required this.service, required this.date, required this.time,
    required this.barber, required this.duration, required this.name, required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Booking Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 4),
      Text('Review and confirm your appointment', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
      const SizedBox(height: 20),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            _SummaryRow(icon: Icons.content_cut, label: 'Service', value: service),
            const Divider(height: 24),
            _SummaryRow(icon: Icons.calendar_today, label: 'Date', value: date),
            const Divider(height: 24),
            _SummaryRow(icon: Icons.access_time, label: 'Time', value: time),
            const Divider(height: 24),
            _SummaryRow(icon: Icons.timer, label: 'Duration', value: '$duration min'),
            const Divider(height: 24),
            _SummaryRow(icon: Icons.person, label: 'Barber', value: barber),
            const Divider(height: 24),
            _SummaryRow(icon: Icons.badge, label: 'Your Name', value: name),
            if (phone.isNotEmpty) ...[
              const Divider(height: 24),
              _SummaryRow(icon: Icons.phone, label: 'Phone', value: phone),
            ],
          ]),
        ),
      ),
    ]);
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: QCutColors.purple),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(fontSize: 13, color: QCutColors.charcoal.withValues(alpha: 0.5))),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.navy, fontSize: 14)),
    ]);
  }
}

// ──────────────────────────────────────────────
// Confirmation screen
// ──────────────────────────────────────────────
class _ConfirmationScreen extends StatelessWidget {
  final String service, date, time, barber, name;
  final VoidCallback onDone;

  const _ConfirmationScreen({
    required this.service, required this.date, required this.time,
    required this.barber, required this.name, required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        backgroundColor: QCutColors.emerald,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle, size: 72, color: QCutColors.emerald),
                const SizedBox(height: 16),
                const Text('Appointment Booked!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: QCutColors.navy)),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                _ConfirmationRow(icon: Icons.content_cut, text: service),
                _ConfirmationRow(icon: Icons.calendar_today, text: date),
                _ConfirmationRow(icon: Icons.access_time, text: time),
                _ConfirmationRow(icon: Icons.person, text: 'Barber: $barber'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QCutColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ConfirmationRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: QCutColors.charcoal.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.7), fontSize: 14)),
      ]),
    );
  }
}

// ──────────────────────────────────────────────
// Shared widgets
// ──────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(steps.length, (i) {
          final done = i < currentStep;
          final active = i == currentStep;
          return Row(children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: active ? QCutColors.purple : (done ? QCutColors.emerald : QCutColors.surfaceVariant),
                shape: BoxShape.circle,
                border: !active && !done ? Border.all(color: QCutColors.charcoal.withValues(alpha: 0.2)) : null,
              ),
              child: Center(
                child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : QCutColors.charcoal.withValues(alpha: 0.4))),
              ),
            ),
            const SizedBox(width: 6),
            Text(steps[i], style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? QCutColors.purple : QCutColors.charcoal.withValues(alpha: 0.4),
            )),
            if (i < steps.length - 1) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 14, color: QCutColors.charcoal.withValues(alpha: 0.2)),
              const SizedBox(width: 6),
            ],
          ]);
        })),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool canProceed;
  final bool isLast;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const _BottomBar({
    required this.canProceed, required this.isLast,
    this.onBack, required this.onNext, required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        if (onBack != null)
          SizedBox(
            width: 50, height: 50,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: QCutColors.charcoal.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: QCutColors.charcoal),
            ),
          ),
        if (onBack != null) const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: canProceed ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? QCutColors.emerald : QCutColors.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: QCutColors.surfaceVariant,
                disabledForegroundColor: QCutColors.charcoal.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(nextLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}
