import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class QrShareViewModel extends ChangeNotifier {
  final String tenantSlug;

  QrShareViewModel({required this.tenantSlug});

  String get bookingUrl => 'https://qcut.co.in/s/$tenantSlug';

  Future<void> share() async {
    await Share.share('Book your appointment at $bookingUrl');
  }
}
