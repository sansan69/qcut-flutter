import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/owner/owner_dashboard_screen.dart';
import 'screens/owner/token_queue_screen.dart';
import 'models/shop_models.dart';
import 'models/token_entry.dart';

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
      locale: const Locale('ml'), // Default Malayalam
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

  final Tenant _demoTenant = Tenant(
    id: 'demo-1', name: 'Rajesh Salon', ownerEmail: 'rajesh@demo.com',
    businessType: 'salon', planLevel: 1, bookingMode: 'token',
    phone: '+919****3210', address: 'Near Bus Stand, Kollam',
  );

  final List<TokenEntry> _serving = [
    TokenEntry(id: '1', tokenNumber: 4, name: 'Ramesh Kumar', phone: '+919****3211', status: 'serving', staffName: 'Faisal'),
  ];
  final List<TokenEntry> _waiting = [
    TokenEntry(id: '2', tokenNumber: 5, name: 'Suresh Nair', phone: '+919****3212', status: 'waiting', staffName: 'Faisal'),
    TokenEntry(id: '3', tokenNumber: 6, name: 'Abdul Rahim', phone: '+919****3213', status: 'waiting', staffName: 'Faisal'),
    TokenEntry(id: '4', tokenNumber: 7, name: 'Joseph Mathew', phone: '+919****3214', status: 'waiting', staffName: 'Rajesh'),
    TokenEntry(id: '5', tokenNumber: 2, name: 'Vijay Menon', status: 'waiting', staffName: 'Rajesh'),
  ];
  final List<TokenEntry> _completed = [
    TokenEntry(id: '6', tokenNumber: 1, name: 'Aravind', status: 'completed', staffName: 'Rajesh'),
    TokenEntry(id: '7', tokenNumber: 2, name: 'Deepak', status: 'completed', staffName: 'Faisal'),
    TokenEntry(id: '8', tokenNumber: 3, name: 'Harish', status: 'completed', staffName: 'Faisal'),
  ];

  void _callNext() => setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: [
        OwnerDashboardScreen(
          tenant: _demoTenant,
          onOpenQueue: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TokenQueueScreen(
            serving: _serving, waiting: _waiting, completed: _completed,
            onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel,
          ))),
          onOpenBookings: () {},
          onOpenStaff: () {},
          onOpenSettings: () {},
        ),
        TokenQueueScreen(serving: _serving, waiting: _waiting, completed: _completed, onCallNext: _callNext, onComplete: _complete, onNoShow: _noShow, onCancel: _cancel),
        const Center(child: Text('Customers')),
        const Center(child: Text('Reports')),
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex: _currentIndex, onDestinationSelected: (i) => setState(() => _currentIndex = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.format_list_numbered), label: 'Queue'),
        NavigationDestination(icon: Icon(Icons.people), label: 'Customers'),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
      ]),
    );
  }
}
