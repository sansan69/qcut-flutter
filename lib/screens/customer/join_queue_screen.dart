import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/token_entry.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../common/qr_screen.dart';

/// Customer Join Queue — scan QR or walk-in to get a token
class JoinQueueScreen extends StatefulWidget {
  final List<Barber> barbers;
  final Function(String barberId, String name, String phone) onJoin;
  final String bookingUrl;
  final String shopName;

  const JoinQueueScreen({
    super.key,
    required this.barbers,
    required this.onJoin,
    required this.bookingUrl,
    required this.shopName,
  });

  @override
  State<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends State<JoinQueueScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Barber? _selectedBarber;
  final _formKey = GlobalKey<FormState>();

  // Simulated token display after joining
  TokenEntry? _issuedToken;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _join() {
    if (!_formKey.currentState!.validate() || _selectedBarber == null) return;

    HapticFeedback.mediumImpact();
    widget.onJoin(_selectedBarber!.id, _nameCtrl.text.trim(), _phoneCtrl.text.trim());

    // Simulate token issuance
    final token = TokenEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenNumber: 8,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      status: 'waiting',
      staffName: _selectedBarber!.name,
      date: DateTime.now().toIso8601String().substring(0, 10),
      createdAt: DateTime.now(),
    );

    setState(() => _issuedToken = token);
  }

  void _reset() {
    setState(() {
      _issuedToken = null;
      _selectedBarber = null;
      _nameCtrl.clear();
      _phoneCtrl.clear();
    });
  }

  void _showQR() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ShopQRScreen(shopName: widget.shopName, bookingUrl: widget.bookingUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Token issued screen
    if (_issuedToken != null) {
      return _TokenIssuedScreen(token: _issuedToken!, onDone: _reset);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Queue'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // QR code section
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  GestureDetector(
                    onTap: _showQR,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: QCutColors.navy.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: QCutColors.navy.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.qr_code_scanner, size: 44, color: QCutColors.navy),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showQR,
                    child: Text('Scan shop QR code',
                      style: TextStyle(color: QCutColors.purple, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  const SizedBox(height: 4),
                  Text('Tap to view full QR',
                    style: TextStyle(fontSize: 12, color: QCutColors.charcoal.withValues(alpha: 0.4))),
                  const SizedBox(height: 16),
                  const Row(children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR')),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),
                  Text('Walk-in Registration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Select barber
            Text('Select Barber',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: QCutColors.navy)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.barbers.map((b) => ChoiceChip(
                label: Text(b.name),
                selected: _selectedBarber?.id == b.id,
                selectedColor: QCutColors.navy,
                labelStyle: TextStyle(
                  color: _selectedBarber?.id == b.id ? Colors.white : QCutColors.charcoal,
                  fontWeight: FontWeight.w500,
                ),
                onSelected: (_) => setState(() => _selectedBarber = b),
              )).toList(),
            ),
            if (widget.barbers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('No barbers available',
                  style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
              ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number (optional)',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),

            // Join button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _join,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QCutColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Join Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Token confirmation screen after joining
class _TokenIssuedScreen extends StatelessWidget {
  final TokenEntry token;
  final VoidCallback onDone;

  const _TokenIssuedScreen({required this.token, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Issued'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 72, color: QCutColors.emerald),
                  const SizedBox(height: 16),
                  Text('Token #${token.tokenNumber}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: QCutColors.navy)),
                  const SizedBox(height: 8),
                  Text(token.name, style: const TextStyle(fontSize: 18)),
                  if (token.staffName != null) ...[
                    const SizedBox(height: 4),
                    Text('Barber: ${token.staffName}',
                      style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.6))),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: QCutColors.amberBg,
                      borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.access_time, size: 16, color: QCutColors.amber),
                      const SizedBox(width: 6),
                      Text('~15 min wait',
                        style: TextStyle(color: QCutColors.amber, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QCutColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
