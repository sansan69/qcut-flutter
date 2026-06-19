import 'package:firebase_app_check/firebase_app_check.dart';

class AppCheckService {
  static Future<void> activate() async {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.deviceCheck,
      webProvider: ReCaptchaV3Provider('6Ld...'), // Replace with real key from https://console.firebase.google.com/project/appointment-32f4a/appcheck
    );
  }
}
