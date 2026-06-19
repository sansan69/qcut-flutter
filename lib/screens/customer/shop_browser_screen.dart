import 'package:flutter/material.dart';
import 'package:qcut_flutter/data/repositories/shop_repository.dart';
import 'package:qcut_flutter/models/booking.dart';
import 'package:qcut_flutter/screens/customer/booking_screen.dart';
import 'package:qcut_flutter/screens/customer/join_queue_screen.dart';
import 'package:qcut_flutter/models/token_entry.dart';
import 'package:qcut_flutter/models/shop_models.dart';
import 'package:qcut_flutter/services/firestore_service.dart';
import 'package:qcut_flutter/theme/app_theme.dart';
import 'package:qcut_flutter/ui/core/qcut_components.dart';

/// Opens a shop's customer flow: fetches its detail from Firestore, then
/// pushes [JoinQueueScreen] (token shops) or [BookingScreen] (appointment
/// shops) and **persists** the issued token / created booking via
/// [FirestoreService] — the same path the owner app uses.
class ShopBrowserScreen extends StatefulWidget {
  final ShopSummary shop;
  final ShopRepository? shopRepository;
  final FirestoreService? firestoreService;

  const ShopBrowserScreen({
    super.key,
    required this.shop,
    this.shopRepository,
    this.firestoreService,
  });

  @override
  State<ShopBrowserScreen> createState() => _ShopBrowserScreenState();
}

class _ShopBrowserScreenState extends State<ShopBrowserScreen> {
  late final ShopRepository _repo;
  late final FirestoreService _db;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = widget.shopRepository ?? ShopRepository();
    _db = widget.firestoreService ?? FirestoreService();
    _open();
  }

  Future<void> _open() async {
    try {
      final detail = await _repo.fetchShopDetail(widget.shop.id);
      if (!mounted) return;
      setState(() => _loading = false);
      await _pushFlow(detail);
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  /// Called by JoinQueueScreen when the customer confirms — persists the token.
  Future<void> _persistToken({
    required String tenantId,
    required String barberId,
    required String name,
    required String phone,
    required int tokenNumber,
    required String barberName,
  }) async {
    final token = TokenEntry(
      id: 'tok_${DateTime.now().millisecondsSinceEpoch}',
      tokenNumber: tokenNumber,
      name: name,
      phone: phone,
      status: 'waiting',
      staffId: barberId,
      staffName: barberName,
      date: DateTime.now().toIso8601String().substring(0, 10),
      createdAt: DateTime.now(),
    );
    try {
      await _db.addToken(tenantId, token);
    } catch (e) {
      debugPrint('Token persistence failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your token. Please try again.')),
        );
      }
    }
  }

  /// Called by BookingScreen on confirm — persists the booking.
  Future<void> _persistBooking({required String tenantId, required Booking booking}) async {
    try {
      await _db.addBooking(tenantId, booking);
    } catch (e) {
      debugPrint('Booking persistence failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save your booking. Please try again.')),
        );
      }
    }
  }

  Future<void> _pushFlow(ShopDetail detail) async {
    final isToken = detail.summary.bookingMode == 'token';
    if (isToken) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JoinQueueScreen(
          barbers: detail.barbers,
          onJoin: (barberId, name, phone) => _persistToken(
            tenantId: detail.summary.id,
            barberId: barberId,
            name: name,
            phone: phone,
            tokenNumber: detail.nextToken,
            barberName: detail.barbers.firstWhere(
              (b) => b.id == barberId,
              orElse: () => detail.barbers.isNotEmpty ? detail.barbers.first : Barber(id: barberId, name: 'Any'),
            ).name,
          ),
          bookingUrl: detail.summary.bookingUrl,
          shopName: detail.summary.name,
          nextToken: detail.nextToken,
        ),
      ));
    } else {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BookingScreen(
          barbers: detail.barbers,
          services: detail.services,
          tenantId: detail.summary.id,
          tenantName: detail.summary.name,
          onBook: (booking) => _persistBooking(tenantId: detail.summary.id, booking: booking),
        ),
      ));
    }
    // After the customer finishes (pops back), close the browser too.
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCutColors.surface,
      appBar: AppBar(title: Text(widget.shop.name)),
      body: _loading
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Opening ${widget.shop.name}…', style: const TextStyle(color: QCutColors.onSurfaceVariant)),
            ]))
          : _error != null
              ? QEmptyState(
                  icon: Icons.error_outline,
                  title: 'Couldn\'t open this shop',
                  subtitle: _error,
                  tint: QCutColors.error,
                  action: QPrimaryButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icons.arrow_back,
                    child: const Text('Back'),
                  ),
                )
              : const SizedBox(), // resolved → flow pushed
    );
  }
}
