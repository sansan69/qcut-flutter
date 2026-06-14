import 'package:flutter/material.dart';
import '../../models/token_entry.dart';
import '../../models/booking.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';

/// Reports & Analytics — daily stats, trends, KPIs
class ReportsScreen extends StatelessWidget {
  final List<TokenEntry> completedTokens;
  final List<Booking> completedBookings;
  final List<TokenEntry> waitingTokens;
  final List<TokenEntry> servingTokens;
  final List<Barber> barbers;
  final List<Service> services;

  const ReportsScreen({
    super.key,
    required this.completedTokens,
    required this.completedBookings,
    required this.waitingTokens,
    required this.servingTokens,
    this.barbers = const [],
    this.services = const [],
  });

  int get _totalServed => completedTokens.length + completedBookings.length;
  int get _noShows => completedTokens.where((t) => t.status == 'no-show').length;
  double get _completionRate => _totalServed > 0 ? ((completedTokens.where((t) => t.status == 'completed').length + completedBookings.where((b) => b.status == 'completed').length) / _totalServed * 100) : 0;

  int get _avgTicketSize {
    if (services.isNotEmpty) {
      return services.where((s) => s.isActive).fold<int>(0, (sum, s) => sum + s.price) ~/ services.where((s) => s.isActive).length;
    }
    return 150;
  }

  // Simulated daily stats for the chart (last 7 days)
  List<_DayStat> get _weekStats {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final tokensToday = 10 + i * 2 + (d.weekday == 6 ? 8 : 0) + (d.weekday == 7 ? 5 : 0);
      return _DayStat(
        day: _dayLabel(d.weekday),
        tokens: tokensToday,
        bookings: 3 + (d.weekday == 6 ? 4 : 0),
        revenue: tokensToday * _avgTicketSize,
      );
    });
  }

  String _dayLabel(int wd) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1];

  @override
  Widget build(BuildContext context) {
    final stats = _weekStats;
    final maxTokens = stats.map((s) => s.tokens).reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Today's KPIs
        Text('Today', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: QCutColors.navy)),
        const SizedBox(height: 12),
        Row(children: [
          _KpiCard(label: 'Served', value: '$_totalServed', color: QCutColors.emerald, bg: QCutColors.emeraldBg),
          const SizedBox(width: 10),
          _KpiCard(label: 'Waiting', value: '${waitingTokens.length}', color: QCutColors.amber, bg: QCutColors.amberBg),
          const SizedBox(width: 10),
          _KpiCard(label: 'No-Shows', value: '$_noShows', color: QCutColors.red, bg: QCutColors.redBg),
          const SizedBox(width: 10),
          _KpiCard(label: 'Rate', value: '${_completionRate.round()}%', color: QCutColors.purple, bg: QCutColors.purpleBg),
        ]),
        const SizedBox(height: 24),

        // Completion breakdown
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Status Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: QCutColors.navy)),
              const SizedBox(height: 16),
              _StatusRow(label: 'Completed', count: completedTokens.where((t) => t.status == 'completed').length, color: QCutColors.emerald),
              _StatusRow(label: 'No-Show', count: _noShows, color: QCutColors.red),
              _StatusRow(label: 'Cancelled', count: completedTokens.where((t) => t.status == 'cancelled').length, color: QCutColors.amber),
              _StatusRow(label: 'Bookings Done', count: completedBookings.length, color: QCutColors.purple),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // Weekly chart
        Text('Last 7 Days', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: QCutColors.navy)),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tokens Per Day', style: TextStyle(fontWeight: FontWeight.w600, color: QCutColors.charcoal)),
              const SizedBox(height: 20),
              // Bar chart
              SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: stats.map((s) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('${s.tokens}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: QCutColors.navy)),
                        const SizedBox(height: 4),
                        Container(
                          height: maxTokens > 0 ? (s.tokens / maxTokens * 120) : 0,
                          decoration: BoxDecoration(
                            color: s.tokens > 15 ? QCutColors.navy : QCutColors.navy.withValues(alpha: 0.6),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(s.day, style: TextStyle(fontSize: 10, color: QCutColors.charcoal.withValues(alpha: 0.5))),
                      ]),
                    ),
                  )).toList(),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 24),

        // Revenue estimates
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Estimated Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: QCutColors.navy)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _RevCard(label: 'Today', amount: _totalServed * _avgTicketSize, color: QCutColors.emerald),
                _RevCard(label: 'This Week', amount: stats.fold<int>(0, (s, d) => s + d.revenue), color: QCutColors.navy),
                _RevCard(label: 'Avg/Day', amount: stats.fold<int>(0, (s, d) => s + d.revenue) ~/ 7, color: QCutColors.purple),
              ]),
              const SizedBox(height: 16),
              Text('*Based on ₹$_avgTicketSize avg ticket size', style: TextStyle(fontSize: 11, color: QCutColors.charcoal.withValues(alpha: 0.4))),
            ]),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _DayStat {
  final String day;
  final int tokens;
  final int bookings;
  final int revenue;
  const _DayStat({required this.day, required this.tokens, required this.bookings, required this.revenue});
}

class _KpiCard extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _KpiCard({required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusRow({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxVal = 20.0; // reference max
    final pct = maxVal > 0 ? (count / maxVal).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: QCutColors.charcoal.withValues(alpha: 0.7)))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: color.withValues(alpha: 0.1), valueColor: AlwaysStoppedAnimation(color)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 24, child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      ]),
    );
  }
}

class _RevCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _RevCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('₹$amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: TextStyle(fontSize: 11, color: QCutColors.charcoal.withValues(alpha: 0.5))),
    ]);
  }
}
