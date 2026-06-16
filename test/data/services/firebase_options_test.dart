import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/data/services/firebase_options.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('defaultFirebaseOptions returns Android options', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final options = DefaultFirebaseOptions.currentPlatform;
    expect(options.projectId, 'appointment-32f4a');
    expect(options.appId, '1:62682041153:android:37d9e2544087052723efc0');
    expect(options.messagingSenderId, '62682041153');
  });
}
