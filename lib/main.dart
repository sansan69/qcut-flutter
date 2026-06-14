import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/owner/token_queue_screen.dart';
import 'screens/owner/staff_screen.dart';
import 'screens/owner/settings_screen.dart';
import 'screens/owner/customer_list_screen.dart';
import 'screens/owner/reports_screen.dart';
import 'screens/customer/join_queue_screen.dart';
import 'screens/customer/my_bookings_screen.dart';
import 'models/shop_models.dart';
import 'models/token_entry.dart';
import 'models/booking.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
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
      home: const AppRoot(),
    );
  }
}

/// Root navigation — LandingScreen → everything else
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final AuthService _auth = FirebaseAuthService();
  final FirestoreService _db = FirestoreService();
  StreamSubscription<AuthUser?>? _sub;
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _sub = _auth.authStateChanges.listen((user) => setState(() => _user = user));
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_auth is FirebaseAuthService) (_auth as FirebaseAuthService).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If signed in as owner → go directly to dashboard
    if (_user != null && _user!.isOwner) {
      return QCutHome(auth: _auth, user: _user!, db: _db);
    }

    // Customer signed in anonymously → take to join queue
    if (_user != null) {
      return QCutHome(auth: _auth, user: _user!, db: _db);
    }

    // Not signed in → Landing page
    return LandingScreen(
      onGetStarted: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => OnboardingScreen(onBackToHome: () => Navigator.pop(context)),
      )),
      onMyAppointments: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => MyBookingsScreen(bookings: [], onCancel: (_) {}),
      )),
      onAdminLogin: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => LoginScreen(auth: _auth),
      )),
    );
  }
}

// ──────────────────────────────────────────────
// Main App (after auth)
// ──────────────────────────────────────────────

class QCutHome extends StatefulWidget {
  final AuthService auth;
  final AuthUser user;
  final FirestoreService db;

  const QCutHome({super.key, required this.auth, required this.user, required this.db});

  @override
  State<QCutHome> createState() => _QCutHomeState();
}

class _QCutHomeState extends State<QCutHome> {
  int _currentIndex = 0;

  late final Tenant _demoTenant;
  late final List<Barber> _barbers;
  late final List<TokenEntry> _serving;
  late final List<TokenEntry> _waiting;
  late final List<TokenEntry> _completed;
  late final List<Booking> _bookings;
  int _nextToken = 8;

  @override
  void initState() {
    super.initState();
    _demoTenant = Tenant(
      id: widget.user.uid, name: 'My Shop', ownerEmail: widget.user.email ?? '',
      businessType: 'salon', planLevel: 1, bookingMode: 'token',
      phone: '+919****3210', address: 'Kerala',
    );
    _barbers = [
      Barber(id: 'b1', name: 'Rajesh', order: 0), Barber(id: 'b2', name: 'Faisal', order: 1), Barber(id: 'b3', name: 'Sujith', order: 2),
    ];
    _serving = [TokenEntry(id: '1', tokenNumber: 4, name: 'Ramesh Kumar', phone: '+919****3211', status: 'serving', staffName: 'Faisal')];
    _waiting = [
      TokenEntry(id: '2', tokenNumber: 5, name: 'Suresh Nair', status: 'waiting', staffName: 'Faisal'),
      TokenEntry(id: '3', tokenNumber: 6, name: 'Abdul Rahim', status: 'waiting', staffName: 'Faisal'),
      TokenEntry(id: '4', tokenNumber: 7, name: 'Joseph Mathew', status: 'waiting', staffName: 'Rajesh'),
      TokenEntry(id: '5', tokenNumber: 2, name: 'Vijay Menon', status: 'waiting', staffName: 'Rajesh'),
    ];
    _completed = [
      TokenEntry(id: '6', tokenNumber: 1, name: 'Aravind', status: 'completed', staffName: 'Rajesh'),
      TokenEntry(id: '7', tokenNumber: 2, name: 'Deepak', status: 'completed', staffName: 'Faisal'),
      TokenEntry(id: '8', tokenNumber: 3, name: 'Harish', status: 'completed', staffName: 'Faisal'),
    ];
    _bookings = [
      Booking(id: 'bk1', tenantId: widget.user.uid, customerName: 'Anil Kumar', phoneNumber: '+919****5555', barberId: 'b1', barberName: 'Rajesh', date: '2026-05-23', timeSlot: '10:30', status: 'confirmed', serviceType: 'Haircut + Beard', bookingCode: 'QC-101', durationMin: 45),
      Booking(id: 'bk2', tenantId: widget.user.uid, customerName: 'Manoj Nair', phoneNumber: '+919****6666', barberId: 'b2', barberName: 'Faisal', date: '2026-05-23', timeSlot: '11:30', status: 'confirmed', serviceType: 'Beard Trim', bookingCode: 'QC-102', durationMin: 20),
      Booking(id: 'bk3', tenantId: widget.user.uid, customerName: 'Sunil Varma', phoneNumber: '+919****7777', barberId: 'b1', barberName: 'Rajesh', date: '2026-05-21', timeSlot: '14:00', status: 'completed', serviceType: 'Haircut', bookingCode: 'QC-98', durationMin: 30),
    ];
  }

  void _callNext() => setState(() {
    HapticFeedback.mediumImpact();
    if (_serving.isNotEmpty) { _completed.insert(0, _serving.first.copyWith(status: 'completed')); _serving.clear(); }
    if (_waiting.isNotEmpty) { _serving.add(_waiting.first.copyWith(status: 'serving')); _waiting.removeAt(0); }
  });
  void _complete(TokenEntry t) => setState(() {
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
    _waiting.add(TokenEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), tokenNumber: _nextToken++, name: name, phone: phone, status: 'waiting', staffName: barber.name, date: DateTime.now().toIso8601String().substring(0, 10), createdAt: DateTime.now()));
  });
  void _cancelBooking(Booking b) => setState(() {
    _bookings[_bookings.indexOf(b)] = Booking(id: b.id, tenantId: b.tenantId, customerName: b.customerName, phoneNumber: b.phoneNumber, barberId: b.barberId, barberName: b.barberName, date: b.date, timeSlot: b.timeSlot, status: 'cancelled', serviceType: b.serviceType, bookingCode: b.bookingCode, durationMin: b.durationMin, createdAt: b.createdAt, updatedAt: DateTime.now());
  });
  void _addBarber(String name) => setState(() => _barbers.add(Barber(id: 'b${_barbers.length + 1}', name: name, order: _barbers.length)));
  void _toggleBarber(Barber b) => setState(() { final i = _barbers.indexOf(b); _barbers[i] = Barber(id: b.id, name: b.name, isActive: !b.isActive, photoURL: b.photoURL, order: b.order); });
  void _deleteBarber(String id) => setState(() => _barbers.removeWhere((b) => b.id == id));
  void _saveSettings(Tenant updated) => setState(() {});

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  Future<void> _signOut() async => widget.auth.signOut();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        OwnerDashboardScreen(
          tenant: _demoTenant,
          onOpenQueue: () => _push(TokenQueueScreen(serving: _serving, waiting: _waiting, completed: _completed, onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel)),
          onOpenBookings: () => _push(MyBookingsScreen(bookings: _bookings, onCancel: _cancelBooking)),
          onOpenStaff: () => _push(StaffScreen(barbers: _barbers, onAdd: _addBarber, onToggle: _toggleBarber, onDelete: _deleteBarber)),
          onOpenSettings: () => _push(SettingsScreen(tenant: _demoTenant, onSave: _saveSettings)),
          onOpenReports: () => _push(ReportsScreen(completedTokens: _completed, completedBookings: _bookings.where((b) => b.status == 'completed').toList(), waitingTokens: _waiting, servingTokens: _serving)),
          onSignOut: _signOut,
        ),
        TokenQueueScreen(serving: _serving, waiting: _waiting, completed: _completed, onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel),
        CustomerListScreen(completedTokens: _completed, completedBookings: _bookings.where((b) => b.status == 'completed').toList()),
        JoinQueueScreen(barbers: _barbers, onJoin: _customerJoin),
        ReportsScreen(completedTokens: _completed, completedBookings: _bookings.where((b) => b.status == 'completed').toList(), waitingTokens: _waiting, servingTokens: _serving),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard), label: l10n.dashboard),
          NavigationDestination(icon: const Icon(Icons.format_list_numbered), label: l10n.queue),
          NavigationDestination(icon: const Icon(Icons.people), label: l10n.customers),
          NavigationDestination(icon: const Icon(Icons.qr_code), label: 'Join'),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: l10n.reports),
        ],
      ),
    );
  }
}
