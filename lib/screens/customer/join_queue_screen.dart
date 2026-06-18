import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/token_entry.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';
import '../common/qr_screen.dart';

/// Customer Join Queue — scan QR or walk-in to get a token.
class JoinQueueScreen extends StatefulWidget {
  final List<Barber> barbers;
  final Function(String barberId, String name, String phone) onJoin;
  final String bookingUrl;
  final String shopName;
  final int nextToken;

  const JoinQueueScreen({
    super.key,
    required this.barbers,
    required this.onJoin,
    required this.bookingUrl,
    required this.shopName,
    this.nextToken = 1,
  });

  @override
  State<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends State<JoinQueueScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Barber? _selectedBarber;
  final _formKey = GlobalKey<FormState>();
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

    final token = TokenEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenNumber: widget.nextToken,
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
    if (_issuedToken != null) {
      return _TokenIssuedScreen(token: _issuedToken!, onDone: _reset);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Join Queue')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // QR / scan card
            QGlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                GestureDetector(
                  onTap: _showQR,
                  child: Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: QCutGradients.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: QCutShadows.glow(),
                    ),
                    child: const Icon(Icons.qr_code_scanner, size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _showQR,
                  child: const Text('Scan shop QR code', style: TextStyle(color: QCutColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                const SizedBox(height: 4),
                Text('Tap to view full QR', style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
                const SizedBox(height: 18),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6), fontWeight: FontWeight.w600))),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                Text('Walk-in Registration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 28),

            // Barber selection
            QSectionLabel(icon: Icons.person, title: 'Select Barber'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.barbers.map((b) {
                final selected = _selectedBarber?.id == b.id;
                return ChoiceChip(
                  label: Text(b.name),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedBarber = b),
                  avatar: CircleAvatar(backgroundColor: selected ? Colors.white24 : QCutColors.primaryTint, child: Text(b.name[0].toUpperCase(), style: TextStyle(color: selected ? Colors.white : QCutColors.primary, fontWeight: FontWeight.w700, fontSize: 12))),
                );
              }).toList(),
            ),
            if (widget.barbers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('No barbers available', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
              ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Your Name', prefixIcon: Icon(Icons.person)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number (optional)', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            QPrimaryButton(onPressed: _join, icon: Icons.login, child: const Text('Join Queue')),
          ],
        ),
      ),
    );
  }
}

/// Token confirmation screen after joining.
class _TokenIssuedScreen extends StatelessWidget {
  final TokenEntry token;
  final VoidCallback onDone;

  const _TokenIssuedScreen({required this.token, required this.onDone});

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(gradient: QCutGradients.success, shape: BoxShape.circle, boxShadow: QCutShadows.glow(QCutColors.success)),
                      child: const Icon(Icons.check, color: Colors.white, size: 44),
                    ),
                    const SizedBox(height: 20),
                    Text('Token #${token.tokenNumber}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: QCutColors.onSurface, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text(token.name, style: const TextStyle(fontSize: 18, color: QCutColors.onSurfaceVariant)),
                    if (token.staffName != null) ...[
                      const SizedBox(height: 4),
                      Text('Barber: ${token.staffName}', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
                    ],
                    const SizedBox(height: 24),
                    QCountChip(label: '~15 min wait', color: QCutColors.warning),
                    const SizedBox(height: 32),
                    QPrimaryButton(onPressed: onDone, child: const Text('Done')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
