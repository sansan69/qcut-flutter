import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qcut_flutter/data/repositories/auth_repository.dart';
import 'package:qcut_flutter/data/services/functions_service.dart';

enum AppRole { customer, provider, platformAdmin, unknown }

class AuthRouter extends StatefulWidget {
  final Widget customerHome;
  final Widget providerDashboard;
  final Widget platformAdminDashboard;
  final Widget landingScreen;

  const AuthRouter({
    super.key,
    required this.customerHome,
    required this.providerDashboard,
    required this.platformAdminDashboard,
    required this.landingScreen,
  });

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  AuthRepository? _authRepository;

  @override
  void initState() {
    super.initState();
    try {
      final auth = FirebaseAuth.instance;
      final functions = FunctionsService(FirebaseFunctions.instance);
      _authRepository = AuthRepository(auth, functions);
    } catch (e) {
      _authRepository = null;
    }
  }

  Future<AppRole> _resolveRole(User? user) async {
    if (user == null) return AppRole.unknown;
    final role = await _authRepository!.resolveRole();
    switch (role) {
      case 'provider':
        return AppRole.provider;
      case 'platform_admin':
        return AppRole.platformAdmin;
      case 'customer':
      case null:
      default:
        return AppRole.customer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = _authRepository;
    if (repo == null) return widget.landingScreen;

    return StreamBuilder<User?>(
      stream: repo.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return widget.landingScreen;

        return FutureBuilder<AppRole>(
          future: _resolveRole(user),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data ?? AppRole.customer;
            switch (role) {
              case AppRole.platformAdmin:
                return widget.platformAdminDashboard;
              case AppRole.provider:
                return widget.providerDashboard;
              case AppRole.customer:
              case AppRole.unknown:
                return widget.customerHome;
            }
          },
        );
      },
    );
  }
}
