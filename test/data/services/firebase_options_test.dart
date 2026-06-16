import 'package:flutter_test/flutter_test.dart';
import 'package:qcut_flutter/data/services/firebase_options.dart';

void main() {
  test('defaultFirebaseOptions returns Android options', () {
    final options = DefaultFirebaseOptions.currentPlatform;
    expect(options.projectId, 'appointment-32f4a');
    expect(options.appId, isNotNull);
  });
}
