import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:qcut_flutter/data/services/firebase_options.dart';
import 'package:qcut_flutter/ui/customer/web_booking_page.dart';
import 'package:qcut_flutter/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initError;
  try {
    final params = Uri.base.queryParameters;
    var options = DefaultFirebaseOptions.currentPlatform;
    if (params.containsKey('emulator')) {
      options = options.copyWith(projectId: 'demo-qcut');
    }
    await Firebase.initializeApp(options: options);
    if (params.containsKey('emulator')) {
      const host = 'localhost';
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    }
  } catch (e) {
    initError = e.toString();
  }
  runApp(WebBookingApp(initError: initError));
}

class WebBookingApp extends StatelessWidget {
  final String? initError;
  const WebBookingApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QCUT Booking',
      theme: QCutTheme.dark,
      themeMode: ThemeMode.dark,
      onGenerateRoute: (settings) {
        if (initError != null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: QCutColors.surface,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: QCutColors.error),
                      const SizedBox(height: 16),
                      const Text(
                        'Booking page configuration is incomplete',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: QCutColors.onSurface),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please add the web Firebase configuration in firebase_options.dart.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: QCutColors.onSurfaceVariant, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        initError!,
                        style: const TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        final uri = Uri.parse(settings.name ?? '/');
        final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        return MaterialPageRoute(
          builder: (_) => WebBookingPage(shopSlug: slug),
        );
      },
    );
  }
}
