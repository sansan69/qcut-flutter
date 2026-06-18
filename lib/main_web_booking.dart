import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qcut_flutter/data/services/firebase_options.dart';
import 'package:qcut_flutter/ui/customer/web_booking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WebBookingApp());
}

class WebBookingApp extends StatelessWidget {
  const WebBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QCUT Booking',
      theme: ThemeData(useMaterial3: true),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        return MaterialPageRoute(
          builder: (_) => WebBookingPage(shopSlug: slug),
        );
      },
    );
  }
}
