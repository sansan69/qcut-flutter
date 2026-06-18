import 'package:flutter/material.dart';
import '../../models/token_entry.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Customer History — searchable customer list with visit history.
class CustomerListScreen extends StatefulWidget {
  final List<TokenEntry> completedTokens;
  final List<Booking> completedBookings;

  const CustomerListScreen({
    super.key,
    required this.completedTokens,
    required this.completedBookings,
  });

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _query = '';
  final _searchCtrl = TextEditingController();

  List<_CustomerSummary> get _customers {
    final map = <String, _CustomerSummary>{};

    for (final t in widget.completedTokens) {
      final key = t.name.toLowerCase();
      map.putIfAbsent(key, () => _CustomerSummary(name: t.name, phone: t.phone));
      map[key]!.visits++;
      map[key]!.statuses.add(t.status);
      if (t.staffName != null && !map[key]!.barbers.contains(t.staffName)) {
        map[key]!.barbers.add(t.staffName!);
      }
    }

    for (final b in widget.completedBookings) {
      final key = b.customerName.toLowerCase();
      map.putIfAbsent(key, () => _CustomerSummary(name: b.customerName, phone: b.phoneNumber));
      map[key]!.visits++;
      map[key]!.statuses.add(b.status);
      if (!map[key]!.barbers.contains(b.barberName)) {
        map[key]!.barbers.add(b.barberName);
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => b.visits.compareTo(a.visits));
    return list;
  }

  List<_CustomerSummary> get _filtered {
    if (_query.isEmpty) return _customers;
    return _customers.where((c) => c.name.toLowerCase().contains(_query.toLowerCase()) || c.phone.contains(_query)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: QCutColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); }) : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            QStatCard(label: 'Total', value: '${_customers.length}', color: QCutColors.primary),
            const SizedBox(width: 10),
            QStatCard(label: 'Visits', value: '${_customers.fold<int>(0, (s, c) => s + c.visits)}', color: QCutColors.success),
            const SizedBox(width: 10),
            QStatCard(label: 'No-shows', value: '${_customers.fold<int>(0, (s, c) => s + c.statuses.where((st) => st == 'no-show').length)}', color: QCutColors.warning),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: customers.isEmpty
              ? QEmptyState(icon: Icons.people_outline, title: _query.isNotEmpty ? 'No matches' : 'No customer history yet', subtitle: _query.isNotEmpty ? 'No customers match "$_query"' : 'Completed visits will appear here.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: customers.length,
                  itemBuilder: (_, i) => _CustomerCard(customer: customers[i], onTap: () => _showDetails(customers[i])),
                ),
        ),
      ]),
    );
  }

  void _showDetails(_CustomerSummary c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: QCutColors.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: QCutColors.primary, radius: 24, child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: QCutColors.onSurface)),
              if (c.phone.isNotEmpty) Text(c.phone, style: const TextStyle(color: QCutColors.onSurfaceVariant)),
            ])),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _DetailChip(icon: Icons.repeat, label: '${c.visits} visits'),
            _DetailChip(icon: Icons.people, label: '${c.barbers.length} barbers'),
            _DetailChip(icon: Icons.cancel, label: '${c.statuses.where((s) => s == 'no-show').length} no-shows'),
          ]),
          const SizedBox(height: 16),
          if (c.barbers.isNotEmpty) ...[
            const Text('Preferred Barbers', style: TextStyle(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, children: c.barbers.map((b) => Chip(label: Text(b), labelStyle: const TextStyle(fontSize: 12, color: QCutColors.onSurface))).toList()),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

class _CustomerSummary {
  final String name;
  final String phone;
  int visits = 0;
  final List<String> statuses = [];
  final List<String> barbers = [];

  _CustomerSummary({required this.name, required this.phone});
}

class _CustomerCard extends StatelessWidget {
  final _CustomerSummary customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final noShows = customer.statuses.where((s) => s == 'no-show').length;

    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(backgroundColor: QCutColors.primary, child: Text(customer.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
        subtitle: Text('${customer.visits} visits • ${customer.barbers.length} barbers', style: const TextStyle(color: QCutColors.onSurfaceVariant)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (noShows > 0) QCountChip(label: '$noShows NS', color: QCutColors.error),
          if (noShows > 0) const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: QCutColors.primary),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
    ]);
  }
}
