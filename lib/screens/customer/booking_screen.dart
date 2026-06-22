import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/booking.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Full booking flow — date picker, time slots, barber, service, confirmation.
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

  Service? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  Barber? _selectedBarber;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;

  List<String> get _timeSlots {
    final slots = <String>[];
    for (int h = 9; h < 21; h++) {
      slots.add('${h.toString().padLeft(2, '0')}:00');
      slots.add('${h.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

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
      case 3: return _nameCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;
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
    setState(() => _step = 5);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 5) {
      return _ConfirmationScreen(
        service: _selectedService!.name,
        date: _formatDate(_selectedDate!),
        time: _selectedTimeSlot!,
        barber: _selectedBarber!.name,
        name: _nameCtrl.text.trim(),
        onDone: () => Navigator.pop(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Book — ${widget.tenantName}'),
        leading: IconButton(
          icon: Icon(_step > 0 ? Icons.arrow_back : Icons.close),
          onPressed: _step > 0 ? _prev : () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        _StepIndicator(currentStep: _step, steps: _steps),
        if (_error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: QCutColors.errorTint, borderRadius: BorderRadius.circular(10), border: Border.all(color: QCutColors.error.withValues(alpha: 0.4))),
            child: Row(children: [
              const Icon(Icons.info_outline, color: QCutColors.error, size: 16),
              const SizedBox(width: 8),
              Text(_error!, style: const TextStyle(color: QCutColors.error, fontSize: 13)),
            ]),
          ),
        Expanded(child: _buildStep()),
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
      case 3: return _DetailsStep(formKey: _formKey, nameCtrl: _nameCtrl, phoneCtrl: _phoneCtrl, onChanged: () => setState(() {}));
      case 4: return _SummaryStep(service: _selectedService!.name, date: _formatDate(_selectedDate!), time: _selectedTimeSlot!, barber: _selectedBarber!.name, duration: _selectedService!.durationMin, name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
      default: return const Center(child: Text('Something went wrong', style: TextStyle(color: QCutColors.onSurfaceVariant)));
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
    return ListView(padding: const EdgeInsets.all(20), children: [
      QSectionLabel(icon: Icons.content_cut, title: 'Select a Service'),
      const SizedBox(height: 4),
      Text('Choose what you\'d like to book', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
      const SizedBox(height: 20),
      ...services.map((s) => QSelectionTile(
        selected: selected?.id == s.id,
        onTap: () => onSelect(s),
        leading: QIconChip(icon: Icons.content_cut, color: QCutColors.success, size: 44),
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: QCutColors.onSurface)),
        subtitle: Text('${s.durationMin} min • ₹${s.price}', style: const TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant)),
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
    return ListView(padding: const EdgeInsets.all(20), children: [
      QSectionLabel(icon: Icons.calendar_today, title: 'Pick a Date'),
      const SizedBox(height: 4),
      Text('Available dates (Mon–Sat)', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
      const SizedBox(height: 16),
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
                  gradient: isSelected ? QCutGradients.primary : null,
                  color: isSelected ? null : (isToday ? QCutColors.primaryTint : QCutColors.surfaceContainer),
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected ? Border.all(color: QCutColors.primary, width: 1.5) : Border.all(color: QCutColors.outlineVariant),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(isToday ? 'Today' : _dayAbbr(d.weekday),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : QCutColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('${d.day}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : QCutColors.onSurface)),
                  Text(_monthAbbr(d.month), style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 28),
      if (widget.selectedDate != null) ...[
        QSectionLabel(icon: Icons.access_time, title: 'Pick a Time'),
        const SizedBox(height: 4),
        Text('30-minute slots from 9:00 AM to 9:00 PM', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
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
                  gradient: isSelected ? QCutGradients.primary : null,
                  color: isSelected ? null : QCutColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? QCutColors.primary : QCutColors.outlineVariant),
                ),
                child: Text(
                  _formatTime(slot),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isSelected ? Colors.white : QCutColors.onSurface),
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
    return ListView(padding: const EdgeInsets.all(20), children: [
      QSectionLabel(icon: Icons.person, title: 'Choose Your Barber'),
      const SizedBox(height: 4),
      Text('Select who you\'d like', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
      const SizedBox(height: 20),
      ...barbers.where((b) => b.isActive).map((b) => QSelectionTile(
        selected: selected?.id == b.id,
        onTap: () => onSelect(b),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: QCutColors.primary,
          child: Text(b.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: QCutColors.onSurface)),
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
  final VoidCallback onChanged;

  const _DetailsStep({required this.formKey, required this.nameCtrl, required this.phoneCtrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        QSectionLabel(icon: Icons.badge, title: 'Your Details'),
        const SizedBox(height: 4),
        Text('We\'ll save these for your booking', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
        const SizedBox(height: 24),
        TextFormField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneCtrl,
          decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone)),
          keyboardType: TextInputType.phone,
          validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid 10-digit number' : null,
          onChanged: (_) => onChanged(),
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
    return ListView(padding: const EdgeInsets.all(20), children: [
      QSectionLabel(icon: Icons.receipt_long, title: 'Booking Summary'),
      const SizedBox(height: 4),
      Text('Review and confirm your appointment', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
      const SizedBox(height: 20),
      QGlassCard(
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
      Icon(icon, size: 18, color: QCutColors.primary),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.onSurface, fontSize: 14)),
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
      backgroundColor: QCutColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Container(
              decoration: BoxDecoration(
                color: QCutColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: QCutColors.success.withValues(alpha: 0.4)),
                boxShadow: [BoxShadow(color: QCutColors.success.withValues(alpha: 0.18), blurRadius: 24)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(gradient: QCutGradients.success, shape: BoxShape.circle, boxShadow: QCutShadows.glow(QCutColors.success)),
                    child: const Icon(Icons.check, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text('Appointment Booked!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: QCutColors.onSurface)),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(fontSize: 16, color: QCutColors.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  _ConfirmationRow(icon: Icons.content_cut, text: service),
                  _ConfirmationRow(icon: Icons.calendar_today, text: date),
                  _ConfirmationRow(icon: Icons.access_time, text: time),
                  _ConfirmationRow(icon: Icons.person, text: 'Barber: $barber'),
                  const SizedBox(height: 32),
                  QPrimaryButton(onPressed: onDone, icon: Icons.check, child: const Text('Done')),
                ]),
              ),
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
        Icon(icon, size: 16, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: QCutColors.onSurfaceVariant, fontSize: 14)),
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
                gradient: active ? QCutGradients.primary : null,
                color: active ? null : (done ? QCutColors.success : QCutColors.surfaceContainerHigh),
                shape: BoxShape.circle,
                border: active ? Border.all(color: QCutColors.primary.withValues(alpha: 0.5)) : null,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: active ? Colors.white : QCutColors.onSurfaceVariant)),
              ),
            ),
            const SizedBox(width: 6),
            Text(steps[i], style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? QCutColors.primary : QCutColors.onSurfaceVariant,
            )),
            if (i < steps.length - 1) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 14, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.3)),
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
      decoration: const BoxDecoration(color: QCutColors.surface, border: Border(top: BorderSide(color: QCutColors.outlineVariant))),
      child: Row(children: [
        if (onBack != null)
          SizedBox(
            width: 50, height: 50,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
        if (onBack != null) const SizedBox(width: 12),
        Expanded(
          child: QPrimaryButton(
            onPressed: canProceed ? onNext : null,
            icon: isLast ? Icons.event_available : Icons.arrow_forward,
            gradient: isLast ? QCutGradients.success : QCutGradients.primary,
            child: Text(nextLabel),
          ),
        ),
      ]),
    );
  }
}
