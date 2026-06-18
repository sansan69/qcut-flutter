import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/services/local_notification_service.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;
  late LocalNotificationService service;

  setUpAll(() {
    registerFallbackValue(0);
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  });

  setUp(() {
    plugin = MockFlutterLocalNotificationsPlugin();
    service = LocalNotificationService(plugin);
  });

  group('LocalNotificationService', () {
    test('init initializes plugin with android and iOS settings', () async {
      when(() => plugin.initialize(any())).thenAnswer((_) async => true);

      await service.init();

      final captured = verify(() => plugin.initialize(captureAny())).captured;
      final settings = captured.single as InitializationSettings;
      expect(settings.android, isA<AndroidInitializationSettings>());
      expect(settings.iOS, isA<DarwinInitializationSettings>());
    });

    test('show displays notification with id 0 and provided title/body', () async {
      when(() => plugin.show(any(), any(), any(), any())).thenAnswer((_) async {});

      await service.show('Token Called', 'Your token is ready');

      final captured = verify(() => plugin.show(
        captureAny(),
        captureAny(),
        captureAny(),
        captureAny(),
      )).captured;
      expect(captured[0], 0);
      expect(captured[1], 'Token Called');
      expect(captured[2], 'Your token is ready');

      final details = captured[3] as NotificationDetails;
      expect(details.android, isA<AndroidNotificationDetails>());
      expect(details.iOS, isA<DarwinNotificationDetails>());
    });

    test('show creates Android channel with high importance and priority', () async {
      when(() => plugin.show(any(), any(), any(), any())).thenAnswer((_) async {});

      await service.show('Title', 'Body');

      final captured = verify(() => plugin.show(
        captureAny(),
        captureAny(),
        captureAny(),
        captureAny(),
      )).captured;
      final details = captured[3] as NotificationDetails;
      final android = details.android as AndroidNotificationDetails;
      expect(android.importance, Importance.high);
      expect(android.priority, Priority.high);
    });
  });
}
