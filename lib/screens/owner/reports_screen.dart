import 'package:flutter/material.dart';
import '../../models/token_entry.dart';
import '../../models/booking.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Reports & Analytics — daily stats, trends, KPIs.
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

  List<_DayStat> get _weekStats {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final ds = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final tokensToday = completedTokens.where((t) => t.date == ds).length;
      final bookingsToday = completedBookings.where((b) => b.date == ds).length;
      int revenue = 0;
      for (final b in completedBookings.where((b) => b.date == ds)) {
        final svc = services.cast<Service?>().firstWhere(
          (s) => s!.name == b.serviceType,
          orElse: () => null,
        );
        if (svc != null) {
          revenue += svc.price;
        }
      }
      if (revenue == 0 && tokensToday > 0) {
        revenue = tokensToday * _avgTicketSize;
      }
      return _DayStat(
        day: _dayLabel(d.weekday),
        tokens: tokensToday,
        bookings: bookingsToday,
        revenue: revenue,
      );
    });
  }

  String _dayLabel(int wd) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][wd - 1];

  @override
  Widget build(BuildContext context) {
    final stats = _weekStats;
    final maxTokens = stats.map((s) => s.tokens).reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        QSectionLabel(icon: Icons.today, title: 'Today'),
        const SizedBox(height: 12),
        Row(children: [
          QStatCard(label: 'Served', value: '$_totalServed', color: QCutColors.success),
          const SizedBox(width: 10),
          QStatCard(label: 'Waiting', value: '${waitingTokens.length}', color: QCutColors.warning),
          const SizedBox(width: 10),
          QStatCard(label: 'No-Shows', value: '$_noShows', color: QCutColors.error),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          QStatCard(label: 'Completion', value: '${_completionRate.round()}%', color: QCutColors.primary, icon: Icons.trending_up),
        ]),

        const SizedBox(height: 28),
        QSectionLabel(icon: Icons.donut_small, title: 'Status Breakdown'),
        const SizedBox(height: 12),
        QGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _StatusRow(label: 'Completed', count: completedTokens.where((t) => t.status == 'completed').length, color: QCutColors.success),
            _StatusRow(label: 'No-Show', count: _noShows, color: QCutColors.error),
            _StatusRow(label: 'Cancelled', count: completedTokens.where((t) => t.status == 'cancelled').length, color: QCutColors.warning),
            _StatusRow(label: 'Bookings Done', count: completedBookings.length, color: QCutColors.primary),
          ]),
        ),

        const SizedBox(height: 28),
        QSectionLabel(icon: Icons.bar_chart, title: 'Tokens Per Day', trailing: '7d'),
        const SizedBox(height: 12),
        QGlassCard(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((s) {
                final tall = s.tokens > 15;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${s.tokens}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: QCutColors.onSurface)),
                      const SizedBox(height: 4),
                      Container(
                        height: maxTokens > 0 ? (s.tokens / maxTokens * 120) : 0,
                        decoration: BoxDecoration(
                          gradient: tall ? QCutGradients.primary : LinearGradient(colors: [QCutColors.primary.withValues(alpha: 0.5), QCutColors.primary.withValues(alpha: 0.25)]),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(s.day, style: TextStyle(fontSize: 10, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 28),
        QSectionLabel(icon: Icons.currency_rupee, title: 'Estimated Revenue'),
        const SizedBox(height: 12),
        QGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _RevCard(label: 'Today', amount: _totalServed * _avgTicketSize, color: QCutColors.success),
              _RevCard(label: 'This Week', amount: stats.fold<int>(0, (s, d) => s + d.revenue), color: QCutColors.primary),
              _RevCard(label: 'Avg/Day', amount: stats.fold<int>(0, (s, d) => s + d.revenue) ~/ 7, color: QCutColors.secondary),
            ]),
            const SizedBox(height: 16),
            Text('*Based on ₹$_avgTicketSize avg ticket size', style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.5))),
          ]),
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

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusRow({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxVal = 20.0;
    final pct = maxVal > 0 ? (count / maxVal).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 92, child: Text(label, style: TextStyle(fontSize: 13, color: QCutColors.onSurfaceVariant))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: color.withValues(alpha: 0.12), color: color),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 24, child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: QCutColors.onSurface))),
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
      Text('₹$amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.6))),
    ]);
  }
}
