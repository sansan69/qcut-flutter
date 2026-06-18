import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/services/fcm_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  late MockFirebaseMessaging messaging;
  late FcmService service;

  setUpAll(() {
    registerFallbackValue(false);
  });

  setUp(() {
    messaging = MockFirebaseMessaging();
    service = FcmService(messaging);
  });

  group('FcmService', () {
    test('getToken returns token from messaging', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'abc-token');
      expect(await service.getToken(), 'abc-token');
    });

    test('getToken returns null when no token available', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => null);
      expect(await service.getToken(), isNull);
    });

    test('onTokenRefresh forwards stream from messaging', () async {
      when(() => messaging.onTokenRefresh).thenAnswer((_) => Stream.value('refreshed'));
      expect(await service.onTokenRefresh().first, 'refreshed');
    });

    test('requestPermission calls messaging with alert, badge, sound', () async {
      when(() => messaging.requestPermission(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
      )).thenAnswer((_) async => const NotificationSettings(
        alert: AppleNotificationSetting.enabled,
        announcement: AppleNotificationSetting.disabled,
        authorizationStatus: AuthorizationStatus.authorized,
        badge: AppleNotificationSetting.enabled,
        carPlay: AppleNotificationSetting.disabled,
        lockScreen: AppleNotificationSetting.enabled,
        notificationCenter: AppleNotificationSetting.enabled,
        showPreviews: AppleShowPreviewSetting.always,
        timeSensitive: AppleNotificationSetting.disabled,
        criticalAlert: AppleNotificationSetting.disabled,
        sound: AppleNotificationSetting.enabled,
      ));

      await service.requestPermission();

      verify(() => messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).called(1);
    });
  });
}
