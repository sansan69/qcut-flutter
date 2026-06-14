import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/owner/token_queue_screen.dart';
import 'screens/customer/join_queue_screen.dart';
import 'screens/customer/my_bookings_screen.dart';
import 'models/shop_models.dart';
import 'models/token_entry.dart';
import 'models/booking.dart';

void main() {
  runApp(const QCutApp());
}

class QCutApp extends StatelessWidget {
  const QCutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q - CUT',
      debugShowCheckedModeBanner: false,
      theme: QCutTheme.light,
      locale: const Locale('ml'),
      supportedLocales: const [Locale('en'), Locale('ml')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const QCutHome(),
    );
  }
}

class QCutHome extends StatefulWidget {
  const QCutHome({super.key});

  @override
  State<QCutHome> createState() => _QCutHomeState();
}

class _QCutHomeState extends State<QCutHome> {
  int _currentIndex = 0;

  // Demo data
  final Tenant _demoTenant = Tenant(
    id: 'demo-1', name: 'Rajesh Salon', ownerEmail: 'rajesh@demo.com',
    businessType: 'salon', planLevel: 1, bookingMode: 'token',
    phone: '+919****3210', address: 'Near Bus Stand, Kollam',
  );

  final List<Barber> _barbers = [
    Barber(id: 'b1', name: 'Rajesh', order: 0),
    Barber(id: 'b2', name: 'Faisal', order: 1),
    Barber(id: 'b3', name: 'Sujith', order: 2),
  ];

  late final List<TokenEntry> _serving;
  late final List<TokenEntry> _waiting;
  late final List<TokenEntry> _completed;
  late final List<Booking> _bookings;

  int _nextToken = 8;

  @override
  void initState() {
    super.initState();
    _serving = [
      TokenEntry(id: '1', tokenNumber: 4, name: 'Ramesh Kumar', phone: '+919****3211', status: 'serving', staffName: 'Faisal'),
    ];
    _waiting = [
      TokenEntry(id: '2', tokenNumber: 5, name: 'Suresh Nair', phone: '+919****3212', status: 'waiting', staffName: 'Faisal'),
      TokenEntry(id: '3', tokenNumber: 6, name: 'Abdul Rahim', phone: '+919****3213', status: 'waiting', staffName: 'Faisal'),
      TokenEntry(id: '4', tokenNumber: 7, name: 'Joseph Mathew', phone: '+919****3214', status: 'waiting', staffName: 'Rajesh'),
      TokenEntry(id: '5', tokenNumber: 2, name: 'Vijay Menon', status: 'waiting', staffName: 'Rajesh'),
    ];
    _completed = [
      TokenEntry(id: '6', tokenNumber: 1, name: 'Aravind', status: 'completed', staffName: 'Rajesh'),
      TokenEntry(id: '7', tokenNumber: 2, name: 'Deepak', status: 'completed', staffName: 'Faisal'),
      TokenEntry(id: '8', tokenNumber: 3, name: 'Harish', status: 'completed', staffName: 'Faisal'),
    ];
    _bookings = [
      Booking(id: 'bk1', tenantId: 'demo-1', customerName: 'Anil Kumar', phoneNumber: '+919****5555',
        barberId: 'b1', barberName: 'Rajesh', date: '2026-05-23', timeSlot: '10:30',
        status: 'confirmed', serviceType: 'Haircut + Beard', bookingCode: 'QC-101', durationMin: 45,
        createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      Booking(id: 'bk2', tenantId: 'demo-1', customerName: 'Manoj Nair', phoneNumber: '+919****6666',
        barberId: 'b2', barberName: 'Faisal', date: '2026-05-23', timeSlot: '11:30',
        status: 'confirmed', serviceType: 'Beard Trim', bookingCode: 'QC-102', durationMin: 20,
        createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      Booking(id: 'bk3', tenantId: 'demo-1', customerName: 'Sunil Varma', phoneNumber: '+919****7777',
        barberId: 'b1', barberName: 'Rajesh', date: '2026-05-21', timeSlot: '14:00',
        status: 'completed', serviceType: 'Haircut', bookingCode: 'QC-98', durationMin: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ];
  }

  void _callNext() => setState(() {
    HapticFeedback.mediumImpact();
    if (_serving.isNotEmpty) { _completed.insert(0, _serving.first.copyWith(status: 'completed')); _serving.clear(); }
    if (_waiting.isNotEmpty) { _serving.add(_waiting.first.copyWith(status: 'serving')); _waiting.removeAt(0); }
  });

  void _complete(TokenEntry t) => setState(() {
    HapticFeedback.lightImpact();
    _serving.remove(t); _completed.insert(0, t.copyWith(status: 'completed'));
    if (_waiting.isNotEmpty) { _serving.add(_waiting.first.copyWith(status: 'serving')); _waiting.removeAt(0); }
  });

  void _noShow(TokenEntry t) => setState(() {
    _serving.remove(t); _completed.insert(0, t.copyWith(status: 'no-show'));
    if (_waiting.isNotEmpty) { _serving.add(_waiting.first.copyWith(status: 'serving')); _waiting.removeAt(0); }
  });

  void _cancel(TokenEntry t) => setState(() => _waiting.remove(t));

  void _customerJoin(String barberId, String name, String phone) => setState(() {
    final barber = _barbers.firstWhere((b) => b.id == barberId);
    _waiting.add(TokenEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenNumber: _nextToken++,
      name: name,
      phone: phone,
      status: 'waiting',
      staffName: barber.name,
      date: DateTime.now().toIso8601String().substring(0, 10),
      createdAt: DateTime.now(),
    ));
  });

  void _cancelBooking(Booking b) => setState(() {
    _bookings[_bookings.indexOf(b)] = Booking(
      id: b.id, tenantId: b.tenantId, customerName: b.customerName,
      phoneNumber: b.phoneNumber, barberId: b.barberId, barberName: b.barberName,
      date: b.date, timeSlot: b.timeSlot, status: 'cancelled',
      serviceType: b.serviceType, bookingCode: b.bookingCode, durationMin: b.durationMin,
      createdAt: b.createdAt, updatedAt: DateTime.now(),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        // Tab 0: Owner Dashboard
        OwnerDashboardScreen(
          tenant: _demoTenant,
          onOpenQueue: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TokenQueueScreen(
            serving: _serving, waiting: _waiting, completed: _completed,
            onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel,
          ))),
          onOpenBookings: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MyBookingsScreen(
            bookings: _bookings, onCancel: _cancelBooking,
          ))),
          onOpenStaff: () {},
          onOpenSettings: () {},
        ),
        // Tab 1: Queue
        TokenQueueScreen(serving: _serving, waiting: _waiting, completed: _completed,
          onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel),
        // Tab 2: Customer Join
        JoinQueueScreen(
          barbers: _barbers,
          onJoin: _customerJoin,
        ),
        // Tab 3: Customer Bookings
        MyBookingsScreen(bookings: _bookings, onCancel: _cancelBooking),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard), label: l10n.dashboard),
          NavigationDestination(icon: const Icon(Icons.format_list_numbered), label: l10n.queue),
          NavigationDestination(icon: const Icon(Icons.qr_code), label: 'Join'),
          NavigationDestination(icon: const Icon(Icons.calendar_month), label: l10n.bookings),
        ],
      ),
    );
  }
}
