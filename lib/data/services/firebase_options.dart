import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

/// Per-platform Firebase configuration.
///
/// Android values are sourced from `android/app/google-services.json`, which is
/// the source of truth for the Android configuration.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        if (_hasPlaceholders(ios)) {
          throw UnsupportedError(
            'iOS Firebase options contain placeholder values. '
            'Fill them from the Firebase Console / GoogleService-Info.plist '
            'before releasing on iOS.',
          );
        }
        return ios;
      case TargetPlatform.web:
        if (_hasPlaceholders(web)) {
          throw UnsupportedError(
            'Web Firebase options contain placeholder values. '
            'Fill them from the Firebase Console before releasing on web.',
          );
        }
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static bool _hasPlaceholders(FirebaseOptions options) =>
      options.apiKey.startsWith('FILL') || options.appId.contains(':FILL');

  // This is a client-side Firebase API key. It is public by design; security
  // is enforced via Firestore Security Rules and Firebase App Check.
  // Source of truth: android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFIcL4CvjYDZFw-a1FKHvfJSYalcHguP0',
    appId: '1:62682041153:android:37d9e2544087052723efc0',
    messagingSenderId: '62682041153',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
  );

  // TODO: Fill iOS values from the Firebase Console / GoogleService-Info.plist
  // before releasing the iOS app.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FILL_FROM_GOOGLE_SERVICE_INFO_PLIST',
    appId: '1:62682041153:ios:FILL',
    messagingSenderId: '62682041153',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
    iosBundleId: 'com.kalki.qcut',
  );

  // TODO: Fill web values from the Firebase Console before releasing the web app.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'FILL_FROM_FIREBASE_CONSOLE',
    appId: '1:62682041153:web:FILL',
    messagingSenderId: '62682041153',
    projectId: 'appointment-32f4a',
    authDomain: 'appointment-32f4a.firebaseapp.com',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
    measurementId: 'FILL',
  );
}
