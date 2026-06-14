import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/onboarding_models.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// 4-step onboarding — from QCUT Kotlin OnboardingScreen.kt
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onBackToHome;

  const OnboardingScreen({super.key, required this.onBackToHome});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _form = OnboardingFormData();
  final _errors = <String, String>{};
  bool _loading = false;
  bool _submitted = false;

  static const _steps = ['Business', 'Owner', 'Operations', 'Review'];

  void _next() => setState(() {
    if (_validate()) _step++;
  });

  bool _validate() {
    _errors.clear();
    switch (_step) {
      case 0:
        if (_form.businessName.isEmpty) _errors['businessName'] = 'Required';
        if (_form.businessType.isEmpty) _errors['businessType'] = 'Required';
        if (_form.street.isEmpty) _errors['street'] = 'Required';
        if (_form.district.isEmpty) _errors['district'] = 'Required';
        if (_form.city.isEmpty) _errors['city'] = 'Required';
        if (_form.pinCode.length != 6) _errors['pinCode'] = 'Enter 6 digits';
        if (_form.businessPhone.length != 10) _errors['businessPhone'] = 'Enter 10 digits';
        if (!OnboardingConstants.isGmail(_form.businessEmail)) _errors['businessEmail'] = 'Gmail required';
        break;
      case 1:
        if (_form.ownerName.isEmpty) _errors['ownerName'] = 'Required';
        if (!OnboardingConstants.isGmail(_form.ownerEmail)) _errors['ownerEmail'] = 'Gmail required';
        if (_form.ownerPhone.length != 10) _errors['ownerPhone'] = 'Enter 10 digits';
        break;
      case 3:
        if (!_form.termsAccepted) _errors['termsAccepted'] = 'Required';
        if (!_form.privacyAccepted) _errors['privacyAccepted'] = 'Required';
        if (!_form.dataProcessingConsent) _errors['dataProcessingConsent'] = 'Required';
        break;
    }
    return _errors.isEmpty;
  }

  void _submit() {
    if (!_validate()) return;
    setState(() { _loading = true; _submitted = true; });
    // Submit to Firestore
    FirestoreService().submitOnboarding(_form.toMap()).then((_) {
      setState(() => _loading = false);
    }).catchError((e) {
      debugPrint('Onboarding submit error: $e');
      setState(() => _loading = false);
    });
  }

  void _prev() => setState(() { if (_step > 0) _step--; });

  @override
  Widget build(BuildContext context) {
    if (_submitted && !_loading) return _SuccessScreen(onBackToHome: widget.onBackToHome);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Q-CUT'),
        backgroundColor: const Color(0xFF4A148C),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(_step > 0 ? Icons.arrow_back : Icons.close),
          onPressed: _step > 0 ? _prev : widget.onBackToHome,
        ),
      ),
      body: Column(children: [
        // Step indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(4, (i) {
            final done = i < _step;
            final active = i == _step;
            return Column(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF4A148C) : (done ? QCutColors.emerald : Colors.grey[200]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${i + 1}', style: TextStyle(color: active ? Colors.white : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 4),
              Text(_steps[i], style: TextStyle(fontSize: 10, color: active ? const Color(0xFF4A148C) : Colors.grey)),
            ]);
          })),
        ),
        const Divider(),

        // Form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildStep(),
          ),
        ),

        // Bottom bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : (_step == 3 ? _submit : _next),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A148C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(_step == 3 ? 'Submit Application' : 'Next', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_step < 3) ...[const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 18)],
                    ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _BusinessStep(form: _form, errors: _errors);
      case 1: return _OwnerStep(form: _form, errors: _errors);
      case 2: return _OperationsStep(form: _form);
      case 3: return _ReviewStep(form: _form, errors: _errors);
      default: return const SizedBox();
    }
  }
}

class _BusinessStep extends StatelessWidget {
  final OnboardingFormData form;
  final Map<String, String> errors;
  const _BusinessStep({required this.form, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Business Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 16),
      _Field(label: 'Business Name *', value: form.businessName, onChanged: (v) => form.businessName = v, error: errors['businessName']),
      _Dropdown(label: 'Business Type *', value: form.businessType, options: OnboardingConstants.businessTypes, onChanged: (v) => form.businessType = v, error: errors['businessType']),
      _Dropdown(label: 'Industry *', value: form.industryCategory, options: OnboardingConstants.industryCategories, onChanged: (v) => form.industryCategory = v),
      _Field(label: 'GST Number (Optional)', value: form.gstNumber, onChanged: (v) => form.gstNumber = v.toUpperCase()),
      _Field(label: 'Street Address *', value: form.street, onChanged: (v) => form.street = v, error: errors['street']),
      _Dropdown(label: 'District *', value: form.district, options: OnboardingConstants.keralaDistricts, onChanged: (v) => form.district = v, error: errors['district']),
      _Field(label: 'City *', value: form.city, onChanged: (v) => form.city = v, error: errors['city']),
      _Field(label: 'PIN Code *', value: form.pinCode, onChanged: (v) => form.pinCode = v.replaceAll(RegExp(r'[^0-9]'), '').substring(0, min(6, v.length)), keyboardType: TextInputType.number, error: errors['pinCode']),
      _Field(label: 'Business Phone *', value: form.businessPhone, onChanged: (v) => form.businessPhone = v.replaceAll(RegExp(r'[^0-9]'), '').substring(0, min(10, v.length)), keyboardType: TextInputType.phone, error: errors['businessPhone']),
      _Field(label: 'Business Email (Gmail) *', value: form.businessEmail, onChanged: (v) => form.businessEmail = v, keyboardType: TextInputType.emailAddress, error: errors['businessEmail']),
      const SizedBox(height: 24),
    ]);
  }
}

class _OwnerStep extends StatelessWidget {
  final OnboardingFormData form;
  final Map<String, String> errors;
  const _OwnerStep({required this.form, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Owner Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 16),
      _Field(label: 'Owner Name *', value: form.ownerName, onChanged: (v) => form.ownerName = v, error: errors['ownerName']),
      _Field(label: 'Owner Email (Gmail) *', value: form.ownerEmail, onChanged: (v) => form.ownerEmail = v, keyboardType: TextInputType.emailAddress, error: errors['ownerEmail']),
      _Field(label: 'Owner Phone *', value: form.ownerPhone, onChanged: (v) => form.ownerPhone = v.replaceAll(RegExp(r'[^0-9]'), '').substring(0, min(10, v.length)), keyboardType: TextInputType.phone, error: errors['ownerPhone']),
      _Field(label: 'PAN Number (Optional)', value: form.panNumber, onChanged: (v) => form.panNumber = v.toUpperCase()),
      _Field(label: 'Aadhaar (Optional)', value: form.aadhaarNumber, onChanged: (v) => form.aadhaarNumber = v.replaceAll(RegExp(r'[^0-9]'), '').substring(0, min(12, v.length)), keyboardType: TextInputType.number),
      _Field(label: 'Referral Code (Optional)', value: form.referralCode, onChanged: (v) => form.referralCode = v.toUpperCase()),
      const SizedBox(height: 24),
    ]);
  }
}

class _OperationsStep extends StatelessWidget {
  final OnboardingFormData form;
  const _OperationsStep({required this.form});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Operational Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 16),
      _Field(label: 'Staff Count *', value: form.staffCount, onChanged: (v) => form.staffCount = v.replaceAll(RegExp(r'[^0-9]'), ''), keyboardType: TextInputType.number),
      Row(children: [
        Expanded(child: _Field(label: 'Opening Time', value: form.openingTime, onChanged: (v) => form.openingTime = v)),
        const SizedBox(width: 12),
        Expanded(child: _Field(label: 'Closing Time', value: form.closingTime, onChanged: (v) => form.closingTime = v)),
      ]),
      _Field(label: 'Expected Monthly Bookings', value: form.expectedMonthlyBookings, onChanged: (v) => form.expectedMonthlyBookings = v),
      const SizedBox(height: 16),
      const Text('Booking Mode', style: TextStyle(fontWeight: FontWeight.w600, color: QCutColors.charcoal)),
      const SizedBox(height: 8),
      Row(children: [
        ChoiceChip(label: const Text('Appointment'), selected: form.bookingMode == 'appointment', onSelected: (_) => form.bookingMode = 'appointment', selectedColor: const Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Token Queue'), selected: form.bookingMode == 'token', onSelected: (_) => form.bookingMode = 'token', selectedColor: QCutColors.emerald),
      ]),
      const SizedBox(height: 24),
    ]);
  }
}

class _ReviewStep extends StatelessWidget {
  final OnboardingFormData form;
  final Map<String, String> errors;
  const _ReviewStep({required this.form, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Review & Submit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
      const SizedBox(height: 16),
      Card(
        color: QCutColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Business: ${form.businessName}', style: const TextStyle(fontWeight: FontWeight.bold, color: QCutColors.navy)),
            Text('Owner: ${form.ownerName}'),
            Text('Email: ${form.ownerEmail}'),
            Text('Phone: ${form.ownerPhone}'),
            Text('District: ${form.district}, ${form.city}'),
            Text('Mode: ${form.bookingMode == 'token' ? 'Token Queue' : 'Appointment'}'),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      _Checkbox(label: 'I accept the Terms & Conditions', value: form.termsAccepted, onChanged: (v) => form.termsAccepted = v!, error: errors['termsAccepted']),
      _Checkbox(label: 'I accept the Privacy Policy', value: form.privacyAccepted, onChanged: (v) => form.privacyAccepted = v!, error: errors['privacyAccepted']),
      _Checkbox(label: 'I consent to data processing', value: form.dataProcessingConsent, onChanged: (v) => form.dataProcessingConsent = v!, error: errors['dataProcessingConsent']),
      const SizedBox(height: 24),
    ]);
  }
}

// Shared widgets
class _Field extends StatefulWidget {
  final String label, value;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final String? error;
  const _Field({required this.label, required this.value, required this.onChanged, this.keyboardType, this.error});

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late TextEditingController _ctrl;

  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: widget.value); }

  @override
  void didUpdateWidget(_Field old) { super.didUpdateWidget(old); if (widget.value != _ctrl.text) _ctrl.text = widget.value; }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.error,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}

class _Dropdown extends StatefulWidget {
  final String label, value;
  final List<String> options;
  final Function(String) onChanged;
  final String? error;
  const _Dropdown({required this.label, required this.value, required this.options, required this.onChanged, this.error});

  @override
  State<_Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<_Dropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: widget.value.isEmpty ? null : widget.value,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: widget.error,
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        items: widget.options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) => widget.onChanged(v ?? ''),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool?) onChanged;
  final String? error;
  const _Checkbox({required this.label, required this.value, required this.onChanged, this.error});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
      ]),
      if (error != null) Padding(padding: const EdgeInsets.only(left: 12), child: Text(error!, style: const TextStyle(color: QCutColors.red, fontSize: 12))),
    ]);
  }
}

class _SuccessScreen extends StatelessWidget {
  final VoidCallback onBackToHome;
  const _SuccessScreen({required this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle, size: 72, color: QCutColors.emerald),
            const SizedBox(height: 24),
            const Text('Registration Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: QCutColors.navy)),
            const SizedBox(height: 16),
            Text('Thank you for registering. We\'ve sent a confirmation email. Our team will review your application within 24-48 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[600])),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(onPressed: onBackToHome, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A148C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Back to Home'))),
          ]),
        ),
      ),
    );
  }
}

int min(int a, int b) => a < b ? a : b;
