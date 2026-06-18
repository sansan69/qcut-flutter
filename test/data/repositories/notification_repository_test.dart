import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qcut_flutter/data/repositories/notification_repository.dart';
import 'package:qcut_flutter/data/services/fcm_service.dart';

class MockFcmService extends Mock implements FcmService {}

void main() {
  late MockFcmService fcm;
  late NotificationRepository repo;

  setUp(() {
    fcm = MockFcmService();
    repo = NotificationRepository(fcmService: fcm);
  });

  group('NotificationRepository', () {
    test('getToken caches token from FcmService on first call', () async {
      when(() => fcm.getToken()).thenAnswer((_) async => 'token-1');

      expect(await repo.getToken(), 'token-1');
      expect(await repo.getToken(), 'token-1');

      verify(() => fcm.getToken()).called(1);
    });

    test('getToken returns null when FcmService returns null', () async {
      when(() => fcm.getToken()).thenAnswer((_) async => null);
      expect(await repo.getToken(), isNull);
    });

    test('onTokenRefresh forwards FcmService stream', () async {
      when(() => fcm.onTokenRefresh()).thenAnswer((_) => Stream.value('refreshed'));
      expect(await repo.onTokenRefresh().first, 'refreshed');
    });

    test('requestPermission delegates to FcmService', () async {
      when(() => fcm.requestPermission()).thenAnswer((_) async {});
      await repo.requestPermission();
      verify(() => fcm.requestPermission()).called(1);
    });

    test('foregroundMessages forwards FcmService onMessage stream', () async {
      final controller = StreamController<RemoteMessage>.broadcast();
      when(() => fcm.onMessage).thenAnswer((_) => controller.stream);

      expectLater(repo.foregroundMessages, emits(isA<RemoteMessage>()));
      controller.add(RemoteMessage());
      await controller.close();
    });
  });
}
