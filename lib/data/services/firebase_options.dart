import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.web:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFIcL4CvjYDZFw-a1FKHvfJSYalcHguP0',
    appId: '1:62682041153:android:37d9e2544087052723efc0',
    messagingSenderId: '62682041153',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'FILL_FROM_GOOGLE_SERVICE_INFO_PLIST',
    appId: '1:62682041153:ios:FILL',
    messagingSenderId: '62682041153',
    projectId: 'appointment-32f4a',
    storageBucket: 'appointment-32f4a.firebasestorage.app',
    iosBundleId: 'com.kalki.qcut',
  );

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
