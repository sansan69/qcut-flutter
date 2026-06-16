import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'screens/customer/booking_screen.dart';
import 'screens/common/qr_screen.dart';
import 'screens/super_admin/super_admin_dashboard.dart';
import 'screens/super_admin/create_tenant_screen.dart';
import 'screens/super_admin/tenant_detail_screen.dart';
import 'screens/super_admin/onboarding_queue_screen.dart';
import 'models/shop_models.dart';
import 'models/token_entry.dart';
import 'models/booking.dart';

Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSy...B3Y0',
        appId: '1:909538604832:android:4570f72010453de684cd45',
        messagingSenderId: '909538604832',
        projectId: 'appointment-32f4a',
        storageBucket: 'appointment-32f4a.firebasestorage.app',
      ),
    );
  } catch (e) {
    debugPrint('Firebase init skipped (demo mode): $e');
  }
}

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

// ═══════════════════════════════════════════════
// Root — routes to Super Admin / Owner / Customer
// ═══════════════════════════════════════════════

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AuthService _auth;
  final FirestoreService _db = FirestoreService();
  StreamSubscription<AuthUser?>? _sub;
  AuthUser? _user;
  bool _loadingTenant = false;

  @override
  void initState() {
    super.initState();
    // Try Firebase — fall back to demo if Firebase isn't initialized
    try {
      _auth = FirebaseAuthService();
    } catch (e) {
      debugPrint('Falling back to DemoAuthService: $e');
      _auth = DemoAuthService();
    }
    _user = _auth.currentUser;
    _sub = _auth.authStateChanges.listen((user) {
      setState(() { _user = user; _loadingTenant = false; });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTenant) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Super admin → separate dashboard
    if (_user != null && _user!.isSuperAdmin) {
      return SuperAdminApp(auth: _auth, db: _db);
    }

    // Owner → find or create tenant, then show dashboard
    if (_user != null && _user!.isOwner) {
      return _OwnerApp(auth: _auth, db: _db, user: _user!);
    }

    // Customer (anonymous) → normal app
    if (_user != null) {
      return QCutHome(auth: _auth, user: _user!, db: _db, tenantId: 'demo');
    }

    // Not signed in → Customer-centric Landing
    return LandingScreen(
      onJoinQueue: () async {
        try {
          await _auth.signInAnonymously(displayName: 'Customer');
        } catch (e) {
          debugPrint('Anonymous sign-in failed: $e');
        }
      },
      onMyBookings: () async {
        try {
          await _auth.signInAnonymously(displayName: 'Customer');
        } catch (e) {
          debugPrint('Anonymous sign-in failed: $e');
        }
      },
      onAdminLogin: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => LoginScreen(
          auth: _auth,
          onRegisterShop: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => OnboardingScreen(onBackToHome: () => Navigator.pop(context), auth: _auth),
          )),
        ),
      )),
    );
  }
}

/// Wraps owner tenant lookup — finds or auto-creates tenant doc
class _OwnerApp extends StatefulWidget {
  final AuthService auth;
  final FirestoreService db;
  final AuthUser user;
  const _OwnerApp({required this.auth, required this.db, required this.user});

  @override
  State<_OwnerApp> createState() => _OwnerAppState();
}

class _OwnerAppState extends State<_OwnerApp> {
  Tenant? _tenant;

  @override
  void initState() {
    super.initState();
    _findOrCreateTenant();
  }

  Future<void> _findOrCreateTenant() async {
    final email = widget.user.email ?? '';
    try {
      // Look up existing tenant
      var tenant = await widget.db.getTenantByEmail(email);

      // If not found, auto-create with Starter plan
      if (tenant == null) {
        final tid = await widget.db.createTenantForOwner(
          name: widget.user.displayName ?? 'My Shop',
          ownerEmail: email,
        );
        tenant = await widget.db.getTenant(tid);
      }

      if (mounted) setState(() => _tenant = tenant);
    } catch (e) {
      debugPrint('Tenant lookup error: $e');
      // Fallback: demo tenant
      if (mounted) {
        setState(() => _tenant = Tenant(
          id: widget.user.uid, name: 'My Shop', ownerEmail: email,
        businessType: 'salon', planLevel: 0, bookingMode: 'token',
        status: 'active', phone: '', address: '',
      ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tenant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return QCutHome(auth: widget.auth, user: widget.user, db: widget.db, tenantId: _tenant!.id);
  }
}

// ═══════════════════════════════════════════════
// SUPER ADMIN APP
// ═══════════════════════════════════════════════

class SuperAdminApp extends StatefulWidget {
  final AuthService auth;
  final FirestoreService db;
  const SuperAdminApp({super.key, required this.auth, required this.db});

  @override
  State<SuperAdminApp> createState() => _SuperAdminAppState();
}

class _SuperAdminAppState extends State<SuperAdminApp> {
  StreamSubscription<List<Tenant>>? _tenantsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _onboardingSub;
  List<Tenant> _tenants = [];
  List<Map<String, dynamic>> _onboarding = [];
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    _tenantsSub = widget.db.allTenants().listen((list) {
      if (mounted) setState(() => _tenants = list);
    });
    _onboardingSub = widget.db.pendingOnboarding().listen((list) {
      if (mounted) setState(() => _onboarding = list);
    });
  }

  @override
  void dispose() {
    _tenantsSub?.cancel();
    _onboardingSub?.cancel();
    super.dispose();
  }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _resetDatabase() async {
    setState(() => _resetting = true);
    try {
      final result = await widget.db.resetAllData();
      if (mounted) {
        setState(() => _resetting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Database reset: ${result['tenants']} tenants, ${result['subDocs']} sub-documents, ${result['submissions']} submissions deleted'),
          backgroundColor: QCutColors.emerald,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _resetting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Reset failed: $e'),
          backgroundColor: QCutColors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminDashboard(
      tenants: _tenants,
      onCreateTenant: () => _push(CreateTenantScreen(
        onCreate: (data) => widget.db.createTenant(data).catchError((_) => ''),
      )),
      onTapTenant: (t) => _push(TenantDetailScreen(
        tenant: t,
        onUpdatePlan: (level) => widget.db.updateTenantPlan(t.id, level).catchError((_) {}),
        onUpdateStatus: (s) => widget.db.updateTenantStatus(t.id, s).catchError((_) {}),
      )),
      onViewOnboarding: () => _push(OnboardingQueueScreen(
        submissions: _onboarding,
        onApprove: (id, data, planLevel) => widget.db.approveOnboarding(id, data, planLevel).catchError((_) {}),
        onReject: (id) => widget.db.rejectOnboarding(id).catchError((_) {}),
      )),
      onSignOut: () => widget.auth.signOut(),
      onResetDatabase: _resetDatabase,
      isResetting: _resetting,
    );
  }
}

// ═══════════════════════════════════════════════
// CLIENT APP (Owner / Customer)
// ═══════════════════════════════════════════════

class QCutHome extends StatefulWidget {
  final AuthService auth;
  final AuthUser user;
  final FirestoreService db;
  final String tenantId;

  const QCutHome({
    super.key,
    required this.auth,
    required this.user,
    required this.db,
    required this.tenantId,
  });

  @override
  State<QCutHome> createState() => _QCutHomeState();
}

class _QCutHomeState extends State<QCutHome> {
  int _currentIndex = 0;

  StreamSubscription<List<TokenEntry>>? _tokensSub;
  StreamSubscription<List<Booking>>? _bookingsSub;
  StreamSubscription<List<Barber>>? _barbersSub;
  StreamSubscription<List<Service>>? _servicesSub;
  StreamSubscription<Tenant?>? _tenantSub;

  // Live data
  List<TokenEntry> _serving = [];
  List<TokenEntry> _waiting = [];
  List<TokenEntry> _completed = [];
  List<Booking> _bookings = [];
  List<Barber> _barbers = [];
  List<Service> _services = [];
  Tenant? _tenant;
  int _nextToken = 1;

  String get _tenantId => widget.tenantId;
  SubscriptionPlan get _plan => _tenant?.plan ?? SubscriptionPlan.starter;

  @override
  void initState() {
    super.initState();
    _seedDemoData();
    _connectFirestore();
  }

  /// Minimal seed so UI renders instantly while Firestore loads
  void _seedDemoData() {
    _tenant = Tenant(id: _tenantId, name: 'Loading...', ownerEmail: widget.user.email ?? '', planLevel: 0, bookingMode: 'token');
    _barbers = [];
    _services = [];
    _serving = [];
    _waiting = [];
    _completed = [];
    _bookings = [];
    _nextToken = 1;
  }

  /// Subscribe to all Firestore streams — real-time sync
  void _connectFirestore() {
    final tid = _tenantId;

    _tenantSub = widget.db.tenantStream(tid).listen((t) {
      if (!mounted) return;
      setState(() { if (t != null) { _tenant = t; } });
    });

    _barbersSub = widget.db.barbers(tid).listen((list) {
      if (!mounted) return;
      setState(() { _barbers = list; });
    });

    _servicesSub = widget.db.services(tid).listen((list) {
      if (!mounted) return;
      setState(() { _services = list; });
    });

    _tokensSub = widget.db.tokenQueue(tid).listen((list) {
      if (!mounted) return;
      setState(() {
        _serving = list.where((t) => t.status == 'serving').toList();
        _waiting = list.where((t) => t.status == 'waiting').toList();
        _completed = list.where((t) => t.status != 'waiting' && t.status != 'serving').toList();
        if (list.isNotEmpty) {
          _nextToken = list.map((t) => t.tokenNumber).reduce((a, b) => a > b ? a : b) + 1;
        }
      });
    });

    _bookingsSub = widget.db.bookings(tid).listen((list) {
      if (!mounted) return;
      setState(() { _bookings = list; });
    });
  }

  @override
  void dispose() {
    _tokensSub?.cancel(); _bookingsSub?.cancel(); _barbersSub?.cancel();
    _servicesSub?.cancel(); _tenantSub?.cancel();
    super.dispose();
  }

  // ── Plan helpers ──
  bool get _canUseAppointments => _plan.appointments;
  bool get _canUseQR => _plan.qrCode;
  bool get _canSeeCustomerHistory => _plan.customerHistory;

  // ── Actions (all persist to Firestore) ──
  void _callNext() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_serving.isNotEmpty) {
        final done = _serving.first.copyWith(status: 'completed');
        _completed.insert(0, done); _serving.clear();
        widget.db.addToken(_tenantId, done).catchError((_) {});
      }
      if (_waiting.isNotEmpty) {
        final next = _waiting.first.copyWith(status: 'serving');
        _serving.add(next); _waiting.removeAt(0);
        widget.db.addToken(_tenantId, next).catchError((_) {});
      }
    });
  }

  void _complete(TokenEntry t) {
    setState(() { _serving.remove(t); final done = t.copyWith(status: 'completed'); _completed.insert(0, done); widget.db.addToken(_tenantId, done).catchError((_) {}); _autoNext(); });
  }
  void _noShow(TokenEntry t) {
    setState(() { _serving.remove(t); final ns = t.copyWith(status: 'no-show'); _completed.insert(0, ns); widget.db.addToken(_tenantId, ns).catchError((_) {}); _autoNext(); });
  }
  void _cancel(TokenEntry t) {
    setState(() { _waiting.remove(t); final c = t.copyWith(status: 'cancelled'); _completed.insert(0, c); widget.db.addToken(_tenantId, c).catchError((_) {}); });
  }
  void _autoNext() {
    if (_serving.isEmpty && _waiting.isNotEmpty) {
      final next = _waiting.first.copyWith(status: 'serving'); _serving.add(next); _waiting.removeAt(0); widget.db.addToken(_tenantId, next).catchError((_) {});
    }
  }

  void _customerJoin(String barberId, String name, String phone) {
    final barber = _barbers.cast<Barber?>().firstWhere(
      (b) => b!.id == barberId,
      orElse: () => null,
    );
    if (barber == null) return;
    final token = TokenEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tokenNumber: _nextToken++, name: name, phone: phone,
      status: 'waiting', staffName: barber.name,
      date: DateTime.now().toIso8601String().substring(0, 10),
      createdAt: DateTime.now(),
    );
    setState(() => _waiting.add(token));
    widget.db.addToken(_tenantId, token).catchError((_) {});
  }

  void _cancelBooking(Booking b) {
    setState(() {
      final i = _bookings.indexOf(b);
      _bookings[i] = Booking(id: b.id, tenantId: b.tenantId, customerName: b.customerName, phoneNumber: b.phoneNumber, barberId: b.barberId, barberName: b.barberName, date: b.date, timeSlot: b.timeSlot, status: 'cancelled', serviceType: b.serviceType, bookingCode: b.bookingCode, durationMin: b.durationMin, createdAt: b.createdAt, updatedAt: DateTime.now());
    });
    widget.db.updateBookingStatus(_tenantId, b.id, 'cancelled').catchError((_) {});
  }
  void _addBooking(Booking b) {
    setState(() => _bookings.insert(0, b));
    widget.db.addBooking(_tenantId, b).catchError((_) {});
  }

  void _addBarber(String name) {
    final b = Barber(id: 'b${DateTime.now().millisecondsSinceEpoch}', name: name, order: _barbers.length);
    setState(() => _barbers.add(b));
    widget.db.addBarber(_tenantId, b).catchError((_) {});
  }
  void _toggleBarber(Barber b) {
    final u = Barber(id: b.id, name: b.name, isActive: !b.isActive, photoURL: b.photoURL, order: b.order, scheduleStart: b.scheduleStart, scheduleEnd: b.scheduleEnd, serviceIds: b.serviceIds);
    setState(() { final i = _barbers.indexOf(b); _barbers[i] = u; });
    widget.db.updateBarber(_tenantId, u).catchError((_) {});
  }
  void _deleteBarber(String id) {
    setState(() => _barbers.removeWhere((b) => b.id == id));
    widget.db.deleteBarber(_tenantId, id).catchError((_) {});
  }

  void _saveSettings(Tenant updated) {
    setState(() => _tenant = updated);
    // Persist to Firestore
    widget.db.saveTenantDoc(_tenantId, updated).catchError((_) {});
  }

  void _addService(Service s) {
    setState(() => _services.add(s));
    widget.db.addService(_tenantId, s).catchError((_) {});
  }
  void _deleteService(String id) {
    setState(() => _services.removeWhere((s) => s.id == id));
    widget.db.deleteService(_tenantId, id).catchError((_) {});
  }

  void _push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  Future<void> _signOut() async => widget.auth.signOut();

  String get _bookingUrl {
    final name = _tenant?.name ?? 'my-shop';
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return 'https://qcut.in/$slug';
  }

  void _showUpgradePrompt(String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.lock, color: QCutColors.purple), SizedBox(width: 8), Text('Plan Upgrade Required', style: TextStyle(color: QCutColors.navy))]),
        content: Text('$feature is available on the Pro (₹499/mo) or Clinic (₹349/mo) plan. Contact your administrator to upgrade.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        OwnerDashboardScreen(
          tenant: _tenant!,
          waitingCount: _waiting.length,
          servingCount: _serving.length,
          completedCount: _completed.length,
          onOpenQueue: () => _push(TokenQueueScreen(serving: _serving, waiting: _waiting, completed: _completed, onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel)),
          onOpenBookings: () => _canUseAppointments
              ? _push(MyBookingsScreen(bookings: _bookings, onCancel: _cancelBooking, onNewBooking: () => _push(BookingScreen(barbers: _barbers, services: _services, tenantId: _tenantId, tenantName: _tenant!.name, onBook: _addBooking))))
              : _showUpgradePrompt('Appointment Booking'),
          onOpenStaff: () => _push(StaffScreen(barbers: _barbers, onAdd: _addBarber, onToggle: _toggleBarber, onDelete: _deleteBarber)),
          onOpenSettings: () => _push(SettingsScreen(tenant: _tenant!, services: _services, onSave: _saveSettings, onAddService: _addService, onDeleteService: _deleteService)),
          onOpenReports: () => _push(ReportsScreen(completedTokens: _completed, completedBookings: _bookings.where((b) => b.status == 'completed').toList(), waitingTokens: _waiting, servingTokens: _serving, barbers: _barbers, services: _services)),
          onOpenQR: () => _canUseQR ? _push(ShopQRScreen(shopName: _tenant!.name, bookingUrl: _bookingUrl)) : _showUpgradePrompt('QR Booking Link'),
          onSignOut: _signOut,
          plan: _plan,
        ),
        TokenQueueScreen(serving: _serving, waiting: _waiting, completed: _completed, onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel),
        if (_canSeeCustomerHistory)
          CustomerListScreen(completedTokens: _completed, completedBookings: _bookings.where((b) => b.status == 'completed').toList())
        else
          _UpgradePlaceholder(feature: 'Customer History', onUpgrade: () => _showUpgradePrompt('Customer History')),
        JoinQueueScreen(barbers: _barbers, onJoin: _customerJoin, bookingUrl: _bookingUrl, shopName: _tenant!.name, nextToken: _nextToken),
        ReportsScreen(completedTokens: _completed, completedBookings: _bookings.where((b) => b.status == 'completed').toList(), waitingTokens: _waiting, servingTokens: _serving, barbers: _barbers, services: _services),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard), label: l10n.dashboard),
          NavigationDestination(icon: const Icon(Icons.format_list_numbered), label: l10n.queue),
          NavigationDestination(icon: const Icon(Icons.people), label: l10n.customers),
          NavigationDestination(icon: const Icon(Icons.qr_code), label: l10n.join),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: l10n.reports),
        ],
      ),
    );
  }
}

class _UpgradePlaceholder extends StatelessWidget {
  final String feature;
  final VoidCallback onUpgrade;
  const _UpgradePlaceholder({required this.feature, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock, size: 48, color: QCutColors.charcoal.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('$feature Locked', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: QCutColors.charcoal.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          Text('Upgrade to Pro or Clinic plan', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: QCutColors.charcoal.withValues(alpha: 0.3))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onUpgrade,
            icon: const Icon(Icons.upgrade),
            label: const Text('Upgrade Now'),
            style: ElevatedButton.styleFrom(backgroundColor: QCutColors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
    );
  }
}
