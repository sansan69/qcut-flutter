import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Super Admin: Onboarding approval queue.
class OnboardingQueueScreen extends StatelessWidget {
  final List<Map<String, dynamic>> submissions;
  final Function(String id, Map<String, dynamic> data, int planLevel) onApprove;
  final Function(String id) onReject;

  const OnboardingQueueScreen({
    super.key,
    required this.submissions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding Queue')),
      body: submissions.isEmpty
          ? const QEmptyState(
              icon: Icons.check_circle_outline,
              title: 'All clear!',
              subtitle: 'No pending onboarding requests',
            )
          : ListView(padding: const EdgeInsets.all(20), children: [
              Text('${submissions.length} pending', style: TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...submissions.map((s) => _SubmissionCard(
                data: s,
                onApprove: (planLevel) => onApprove(s['id'] as String, s, planLevel),
                onReject: () => onReject(s['id'] as String),
              )),
            ]),
    );
  }
}

class _SubmissionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(int planLevel) onApprove;
  final VoidCallback onReject;

  const _SubmissionCard({required this.data, required this.onApprove, required this.onReject});

  @override
  State<_SubmissionCard> createState() => _SubmissionCardState();
}

class _SubmissionCardState extends State<_SubmissionCard> {
  int _selectedPlan = 0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final submittedAt = d['submittedAt'];
    final dateStr = submittedAt != null ? _formatTimestamp(submittedAt) : 'Recently';

    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: QCutColors.primary,
                child: Text((d['businessName'] as String? ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['businessName'] as String? ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
                Text(d['businessEmail'] as String? ?? d['ownerEmail'] as String? ?? '', style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text('$dateStr • ${d['bookingMode'] ?? 'token'}', style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
              ])),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: QCutColors.onSurfaceVariant),
            ]),
          ),
        ),

        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(),
              const SizedBox(height: 8),
              _Field('Owner', d['ownerName'] as String? ?? '—'),
              _Field('Phone', d['businessPhone'] as String? ?? d['ownerPhone'] as String? ?? '—'),
              _Field('Address', '${d['street'] ?? ''}${d['city'] != null ? ', ${d['city']}' : ''}${d['district'] != null ? ', ${d['district']}' : ''}'),
              _Field('Business Type', d['businessType'] as String? ?? '—'),
              _Field('Staff Count', d['staffCount'] as String? ?? '—'),
              _Field('Hours', '${d['openingTime'] ?? "09:00"} – ${d['closingTime'] ?? "18:00"}'),
              const SizedBox(height: 16),

              Text('Assign Plan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: QCutColors.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(children: SubscriptionPlan.values.map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${p.name}\n₹${p.price}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, height: 1.2)),
                    selected: _selectedPlan == p.level,
                    onSelected: (v) => setState(() => _selectedPlan = p.level),
                  ),
                ),
              )).toList()),

              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: widget.onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: QCutColors.error,
                    side: BorderSide(color: QCutColors.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: QPrimaryButton(
                  onPressed: () => widget.onApprove(_selectedPlan),
                  gradient: QCutGradients.success,
                  icon: Icons.check,
                  height: 48,
                  child: Text('Approve', style: const TextStyle(fontSize: 13)),
                )),
              ]),
            ]),
          ),
      ]),
    );
  }

  String _formatTimestamp(dynamic ts) {
    try {
      if (ts is DateTime) {
        return '${ts.day}/${ts.month}/${ts.year}';
      }
      final ms = (ts as dynamic).millisecondsSinceEpoch as int;
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Recently';
    }
  }
}

class _Field extends StatelessWidget {
  final String label, value;
  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: QCutColors.onSurface))),
      ]),
    );
  }
}
