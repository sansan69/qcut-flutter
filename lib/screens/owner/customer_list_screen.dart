import 'package:flutter/material.dart';
import '../../models/token_entry.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';

/// Customer History — searchable customer list with visit history
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

  // Build customer summary from completed tokens + bookings
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
    list.sort((a, b) => b.visits.compareTo(a.visits)); // Most visits first
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
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); }) : null,
              filled: true,
              fillColor: QCutColors.surfaceVariant,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),

        // Stats summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _MiniStat(label: 'Total', value: '${_customers.length}'),
            const SizedBox(width: 16),
            _MiniStat(label: 'Visits', value: '${_customers.fold<int>(0, (s, c) => s + c.visits)}'),
            const SizedBox(width: 16),
            _MiniStat(label: 'No-shows', value: '${_customers.fold<int>(0, (s, c) => s + c.statuses.where((st) => st == 'no-show').length)}'),
          ]),
        ),
        const SizedBox(height: 8),

        // Customer list
        Expanded(
          child: customers.isEmpty
              ? Center(child: Text(_query.isNotEmpty ? 'No customers match "$_query"' : 'No customer history yet', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: QCutColors.navy, radius: 24, child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: QCutColors.navy)),
              if (c.phone.isNotEmpty) Text(c.phone, style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.5))),
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
            Text('Preferred Barbers', style: TextStyle(fontWeight: FontWeight.w600, color: QCutColors.navy)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, children: c.barbers.map((b) => Chip(label: Text(b), backgroundColor: QCutColors.surfaceVariant, labelStyle: const TextStyle(fontSize: 12))).toList()),
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

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: QCutColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: QCutColors.navy)),
          Text(label, style: TextStyle(fontSize: 11, color: QCutColors.charcoal.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final _CustomerSummary customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final noShows = customer.statuses.where((s) => s == 'no-show').length;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: QCutColors.navy, child: Text(customer.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.navy)),
        subtitle: Text('${customer.visits} visits • ${customer.barbers.length} barbers'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (noShows > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: QCutColors.redBg, borderRadius: BorderRadius.circular(8)),
              child: Text('$noShows NS', style: const TextStyle(fontSize: 10, color: QCutColors.red)),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ]),
        onTap: onTap,
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
      Icon(icon, color: QCutColors.navy),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.navy)),
    ]);
  }
}
